package Freelex::Controller::Search;

use base qw/Catalyst::Controller/;
use strict;

use Data::Dumper;

use FreelexDB::Utils::Format;
use FreelexDB::Utils::Entities;
freelex_entities_init;

use FreelexDB::Utils::Mlmessage;
mlmessage_init;

sub begin : Private {
  my ( $self, $c ) = @_;
  unless ($c->user_object ) { 
     $c->request->action(undef);
     $c->redirect("login");
     $c->stash->{dont_render_template} = 1; 
  } else {
     $c->stash->{system_name} = entityise(FreelexDB::Globals->system_name);
     $c->stash->{user_object} = $c->user_object;
     $c->stash->{display_nav} = 1  unless defined $c->request->params->{'_nav'} && $c->request->params->{'_nav'} eq 'no'; 
     $c->stash->{date} = localtime;
  }
}


sub search : Path('/search') {
   my ($self, $c) = @_;
   $c->stash->{template} = 'search.tt';  
   my $date = localtime;
   my @rows = ();
   $c->stash->{searchform} = setup_search_form($self, $c);
   if ($c->request->params->{'_s'}) {
      
      my $whereclause;
      my $lowertext = $c->request->params->{'_text'} ? " '%" . lc(utfise($c->request->params->{'_text'})) . "%' " : "";
      my $include = $c->request->params->{'_include'} || "";
      if ($include eq 'other') {
         $whereclause = " WHERE ( headword ILIKE " . $lowertext;
         foreach my $otherfield (@{Freelex::Model::FreelexDB::Headword->search_include_other_cols}) {  
            $whereclause .= ' OR ' . $otherfield . " ILIKE " . $lowertext
         }
         $whereclause .= ') ';
         
      } elsif ($include eq 'partial') {
         $whereclause = $lowertext ? (" WHERE ( headword ILIKE " . $lowertext . " OR headword ILIKE " . $lowertext . ") ") : "";
      } else { # exact match
         $whereclause = $lowertext ? (" WHERE ( headword ILIKE " . FreelexDB::DBI->db_Main->quote(lc(utfise($c->request->params->{'_text'}))) . ") ") : "";
      }
      if ($c->request->params->{'matapunauserid'} ne 'dropdown-first') {
         $whereclause = ($whereclause ? $whereclause . ' AND ' : " WHERE ") . ' (createuserid=' . $c->request->params->{'matapunauserid'} . ' OR updateuserid=' . $c->request->params->{'matapunauserid'} . ' OR owneruserid=' . $c->request->params->{'matapunauserid'} . ')';
      }
      
      if ($c->request->params->{'categoryid'} && $c->request->params->{'categoryid'} ne 'dropdown-first') {
         $whereclause = ($whereclause ? $whereclause . ' AND ' : " WHERE ") . ' (categoryid=' . $c->request->params->{'categoryid'}  . ')';
      }
      
      if ($c->request->params->{'tagid'} && $c->request->params->{'tagid'} ne 'dropdown-first') {
         $whereclause = ($whereclause ? $whereclause . ' AND ' : " WHERE ") . ' headwordid IN (SELECT headwordid FROM headwordtag WHERE headwordtag.headwordid=headword.headwordid AND tagid=' . $c->request->params->{'tagid'}  . ')';
      }
      if ($c->request->params->{'_searchdate'}) {
         $whereclause = ($whereclause ? $whereclause . ' AND ' : " WHERE ") . " (createdate > current_date + interval '1 day' - interval '" . $c->request->params->{'_searchdate'} . " days' OR updatedate > current_date + interval '1 day' - interval '" . $c->request->params->{'_searchdate'} . " days')";
      }

      unless ($whereclause) {
         $c->stash->{message} .= entityise(mlmessage('enter_some_search_criteria',$c->user_object->lang));
         return 0;
      }
         
      
      $whereclause .= " AND (invisible ISNULL or NOT invisible)";
#
# minor hack-ette: if it's just a number in the text field, treat it as an id, and search for that
#
      if ($c->request->params->{'_text'} =~ /^\d+$/) { $whereclause = " WHERE headwordid = " . $c->request->params->{'_text'} }
      
      $whereclause .= ' ORDER BY collateseq, headword, variantno, majsense, wordclassid, headwordid   LIMIT 200';
      
      $c->stash->{message} = "\n<!-- " . $whereclause . "-->\n" ;
      
      if (@rows = Freelex::Model::FreelexDB::Headword->retrieve_from_sql($whereclause)) {
         $c->stash->{message} .= entityise(mlmessage('your_search_produced_matches',$c->user_object->lang,$c->request->params->{_text},scalar @rows));
                    
         my @hitlist = ();
         foreach my $row (@rows) {
            my $rowresults = {};
            foreach my $col (@{Freelex::Model::FreelexDB::Headword->search_result_cols}) {
               $rowresults->{$col} = $row->format($col,"html");
            }
            push @hitlist, $rowresults;
         } 
        $c->stash->{hitlist} = \@hitlist;
     }
     else {
        $c->stash->{message} .= entityise(mlmessage('your_search_produced_no_matches',$c->user_object->lang,$c->request->params->{_text}));
     }
     FreelexDB::Activityjournal->insert( {
       activitydate => $date,
       matapunauserid => $c->user_object->matapunauserid,
       verb => 'search',
       object => $c->request->params->{_text},
       description => scalar @rows
       });
     FreelexDB::Activityjournal->dbi_commit;  
   }
}


sub searchandreplace : Path('/searchandreplace') {
   my ($self, $c) = @_;
   my $lang = $c->user_object->lang;
   my $ua = $c->request->headers->{'user-agent'};
   $c->redirect('search')   unless FreelexDB::Globals->enable_search_and_replace;
   if (!$c->request->params->{'_s'}) {
     $c->stash->{template} = 'searchandreplace1.tt';  
     $self->setup_search_and_replace_form($c);
   }
   elsif ($c->request->params->{'_s'} eq 'review') {
     $c->stash->{template} = 'searchandreplace2.tt';  
     $self->setup_replace_review_form($c);
   }
   elsif ($c->request->params->{'_s'} eq 'commit') {
     $c->stash->{template} = 'searchandreplace3.tt';  
     $self->commit_search_replace($c);
   }
   else { die "unknown function requested" }
}
      
      
sub end : Private {
   my ( $self, $c ) = @_;
   return  if $c->stash->{'dont_render_template'};
   $c->stash->{lang} = $c->user_object->lang;     
   die "You requested a dump"   if ((defined $c->request->params->{'_dump'}) && $c->request->params->{'_dump'} eq 1);
   $c->forward('Freelex::View::TT')  
}


sub setup_search_form {
   my ( $self, $c ) = @_;
   
   my $lang = $c->user_object->lang;
   my $ua = $c->request->headers->{'user-agent'};
   
   my @result = (); 
   push @result, '<form action="search" method="get">';
   push @result, '<input type="hidden" name="_s" value="1">';
   push @result, entityise(mlmessage('search_prompt',$lang));
   push @result,'<br>';
   my $w_default = $c->request->params->{_text} || "";
   push @result, fltextbox('_text',$w_default);
   push @result, '<br>';
   
   push @result, mlmessage('worked_on_by',$lang);
   my $wobdefault = $c->request->params->{matapunauserid} || 'dropdown-first';
   push @result, xlateit(fldropdown('matapunauser','matapunauserid','matapunauser',$wobdefault,'__mlmsg_anyone__'),$lang,$ua,"form");
   
   my $sdddropdown = qq{
   <select name="_searchdate">
   <option value="0" selected="selected">__mlmsg_at_any_time__</option>
   <option value="1">__mlmsg_today__</option>
   <option value="2">__mlmsg_in_the_last_two_days__</option>
   <option value="7">__mlmsg_in_the_last_7_days__</option>
   <option value="30">__mlmsg_in_the_last_30_days__</option>
   </select>
   };
   push @result,xlateit($sdddropdown,$lang,$ua,"form");
   push @result,'<br>';

   if (FreelexDB::Globals->search_select_category) {
      push @result, mlmessage('in_category',$lang);
      my $catdefault = $c->request->params->{categoryid} || 'dropdown-first';
      push @result, xlateit(fldropdown('category','categoryid','category',$catdefault,'__mlmsg_any_category__'),$lang,$ua,"form");
      push @result,'<br>';
   }

   if (FreelexDB::Globals->search_select_tag) {
      push @result, mlmessage('in_tag',$lang);
      my $tagdefault = $c->request->params->{tagid} || 'dropdown-first';
      push @result, xlateit(fldropdown('tag','tagid','tag',$tagdefault,'__mlmsg_any_tag__'),$lang,$ua,"form");
      push @result,'<br>';
   }
   
   my $inctype = $c->request->params->{'_include'} || FreelexDB::Globals->search_default_type || "";
   my @incradiobut = ();
   push @incradiobut, qq{<input type="radio" name="_include" value="" } . ($inctype eq "" ? 'CHECKED' : "") . qq{>__mlmsg_only_headwords__};
   push @incradiobut, qq{<input type="radio" name="_include" value="partial" } . ($inctype eq "partial" ? 'CHECKED' : "") . qq{>__mlmsg_partial_headwords__};
   push @incradiobut, qq{<input type="radio" name="_include" value="other" } . ($inctype eq "other" ? 'CHECKED' : "") . qq{>__mlmsg_include_other_cols__};
   
   push @result,xlateit(join('<br>',@incradiobut),$lang,$ua,"form");
          
#   push @result, flcheckbox('_dump',1) . ' dump';
   push @result, '<br>';
   push @result, '<input type="submit" value="' . mlmessage('search',$lang) . '">';
   push @result, '<br>';
   return join("\n",@result);
}   

sub setup_search_and_replace_form {
  my ($self, $c) = @_;
  my $lang = $c->user_object->lang;
  my $ua = $c->request->headers->{'user-agent'};
  $c->stash->{search_prompt} = entityise(mlmessage('search_prompt',$lang));
  $c->stash->{search_text_box} = fltextbox('_text',"");
  $c->stash->{replace_prompt} = entityise(mlmessage('replace_prompt',$lang));
  $c->stash->{replace_text_box} = fltextbox('_replacetext',"");
  $c->stash->{include_columns_prompt} = entityise(mlmessage('include_columns_prompt',$lang));
  $c->stash->{review_changes_button} = entityise(mlmessage('review_changes_button',$lang));
  my $cols = FreelexDB::Headword->search_and_replace_cols;
  $c->stash->{search_and_replace_cols} = []; 
  foreach my $f (@{$cols}) {
    push @{$c->stash->{search_and_replace_cols}}, { col =>$f, colname=> entityise(mlmessage($f,$lang),$ua,"form") } ;
  }
}

sub setup_replace_review_form {
  my ($self, $c) = @_;
  my $lang = $c->user_object->lang;
  my $ua = $c->request->headers->{'user-agent'};
  $c->stash->{search_prompt} = entityise(mlmessage('search_prompt',$lang));
  $c->stash->{search_text_box} = $c->request->params->{'_text'};
  $c->stash->{replace_prompt} = entityise(mlmessage('replace_prompt',$lang));
  $c->stash->{replace_text_box} = $c->request->params->{'_replacetext'};
  $c->stash->{include_columns_prompt} = entityise(mlmessage('include_columns_prompt',$lang));
  $c->stash->{make_changes_button} = entityise(mlmessage('make_changes_button',$lang));
  $c->stash->{no_entries_met_criteria} = entityise(mlmessage('no_entries_met_criteria',$lang));
  setup_search_and_replace_cols($c);
# restrict to word boundaries
#  my $term = "'" . '\\b' . $c->request->params->{'_text'} . '\\b' . "'";
  my $perlmatchtext = '\b(' . $c->request->params->{'_text'} . ')\b';
  my $sqlmatchtext = "'"  . $c->request->params->{'_text'}  .  "'";
# I'm not happy about the above - I can't get any of the word-boundary matching mechanisms to work. :-(
  my @wheresubclauses = ();
  foreach my $col (@{$c->stash->{search_and_replace_cols}}) {
    push @wheresubclauses, $col->{col} . ' ~* ' . $sqlmatchtext;
  }
  my $whereclause = join(' OR ', @wheresubclauses);
  $whereclause .= ' ORDER BY collateseq, headword, variantno, majsense, wordclassid, headwordid';

  if (my @rows = Freelex::Model::FreelexDB::Headword->retrieve_from_sql($whereclause)) {
    $c->stash->{message} .= entityise(mlmessage('your_search_produced_matches',$c->user_object->lang,$c->request->params->{_text},scalar @rows));
              
    my @hitlist = ();
    foreach my $row (@rows) {
      my $matchingcols = [];
      foreach my $srcol (@{$c->stash->{search_and_replace_cols}}) {
          my $col = $srcol->{col};
          next unless $row->$col =~ /$perlmatchtext/i;
          my $val = $row->$col;
          $val =~ s/$perlmatchtext/<font color="#CC3333"><b>$1<\/b><\/font>/ig;
          push @$matchingcols, { name => $col, label => entityise(mlmessage($col,$lang)), value => entityise($val) };
          $c->stash->{hits}++;
      }
      next unless @$matchingcols;
      my $rowresults = { headword => $row->headword, headwordid => $row->headwordid, hitcols => $matchingcols, nowriteaccess => $row->no_write_access($c) };
      push @hitlist, $rowresults;
    } 
  $c->stash->{hitlist} = \@hitlist;
  }
  else {
    $c->stash->{message} .= entityise(mlmessage('your_search_produced_no_matches',$c->user_object->lang,$c->request->params->{_text}));
  }

}

sub commit_search_replace {
   my $self = shift;
   my $c = shift;
   my $lang = $c->user_object->lang;
   my $ua = $c->request->headers->{'user-agent'};

   $c->stash->{search_prompt} = entityise(mlmessage('search_prompt',$lang));
   $c->stash->{search_text_box} = $c->request->params->{'_text'};
   $c->stash->{replace_prompt} = entityise(mlmessage('replace_prompt',$lang));
   $c->stash->{replace_text_box} = $c->request->params->{'_replacetext'};
   $c->stash->{include_columns_prompt} = entityise(mlmessage('include_columns_prompt',$lang));
   my $date = localtime;


   my $searchtext = $c->request->params->{'_text'};
   my $ucsearchtext = uc($searchtext);
   my $ucfirstsearchtext = ucfirst($searchtext);

   my $replacetext = $c->request->params->{'_replacetext'};
   my $ucreplacetext = uc($replacetext);
   my $ucfirstreplacetext = ucfirst($replacetext);

   my $updates = {};

  setup_search_and_replace_cols($c);

#
# get our queued updates 
#
   foreach my $p (keys %{$c->request->params}) {
      next unless $p =~ /^replace/;
      my ($replace, $headwordid, $col) = split(/\|/,$p);
      unless ($updates->{$headwordid}) { $updates->{$headwordid} = [] };
      push @{$updates->{$headwordid}}, $col;
   }

# now process them

   my $entrycount = 0;
   my @hyphenated_changed_entries = ();
   foreach my $p (keys %$updates) {
      my $headword = FreelexDB::Headword->retrieve($p);
      $c->stash->{archivecopy} = $headword->rowtohashref;
      my $entrychanged = 0;
      foreach my $col (@{$updates->{$p}}) {
         my $colchanged = 0;
         my $val = $headword->$col;
         $colchanged = 1   if  $val =~ s/\b$searchtext\b/$replacetext/sg ;
         $colchanged = 1   if  $val =~ s/\b$ucsearchtext\b/$ucreplacetext/sg ;
         $colchanged = 1   if  $val =~ s/\b$ucfirstsearchtext\b/$ucfirstreplacetext/sg;

         unless ($colchanged) {
            $colchanged = 1   if  $val =~ s/\b$searchtext\b/$replacetext/sgi;
         }

         if ($colchanged) {
            $headword->set($col,$val)   ;
            $entrychanged = 1 ;
         }

      }
      if ($entrychanged) {
        $headword->add_to_editorialcomment( {
                editorialcommentdate => $c->stash->{date},
                matapunauserid => $c->user_object->matapunauserid,
                editorialcomment => 'Search-and-replace changed "' . $searchtext . '" to "' . $replacetext . '" in ' . join(',', @{$updates->{$p}})
              });
        $headword->set('updatedate',$c->stash->{date});
        $headword->set('updateuserid',$c->user_object->matapunauserid);

        push @hyphenated_changed_entries, $headword->hyphenated;

        $headword->update;
        $headword->dbi_commit;

        $c->stash->{archivecopy}->{'archiveuserid'} = $c->user_object->matapunauserid;
        $c->stash->{archivecopy}->{'archivedate'} = $c->stash->{date};
        my $archive = FreelexDB::Hwarchive->insert($c->stash->{archivecopy});
        $archive->dbi_commit;

        $entrycount++;
      }
   }
   
   my $description = $searchtext . ' to ' . $replacetext . "..." . $entrycount . " entries updated: " . join(', ',@hyphenated_changed_entries);


   FreelexDB::Activityjournal->insert( {
       activitydate => $date,
       matapunauserid => $c->user_object->matapunauserid,
       verb => 'searchandreplace',
       object => 'headword',
       description => $description
       });
     FreelexDB::Activityjournal->dbi_commit;  

   $c->stash->{num_entries_updated} = entityise(mlmessage('num_entries_updated',$c->user_object->lang,$entrycount));

}

sub setup_search_and_replace_cols {
  my $c = shift;
  my $cols = FreelexDB::Headword->search_and_replace_cols;
  $c->stash->{search_and_replace_cols} = []; 
  foreach my $f (@{$cols}) {
    next unless $c->request->params->{$f};
    push @{$c->stash->{search_and_replace_cols}}, { col =>$f, colname=> entityise(mlmessage($f,$c->user_object->lang),$c->request->headers->{'user-agent'},"form") } ;
  }
}


1;
