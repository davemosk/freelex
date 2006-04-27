package Freelex::Controller::Search;

use base qw/Catalyst::Controller/;
use strict;

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
  }
}


sub search : Path {
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

1;
