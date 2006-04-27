package Freelex::Controller::Print;

use base qw/Catalyst::Controller/;
use strict;

use List::Util qw/ maxstr /;
use Data::Dumper;
use FreelexDB::Utils::Entities;
freelex_entities_init;

use FreelexDB::Utils::Mlmessage;
mlmessage_init;

use FreelexDB::Utils::Format;

use URI::Escape qw(uri_escape_utf8);

sub begin : Private {
  my ( $self, $c ) = @_;
  unless ($c->user_object ) { 
     $c->request->action(undef);
     $c->redirect("../login");
     $c->stash->{dont_render_template} = 1; 
  } else {
     $c->stash->{system_name} = entityise(FreelexDB::Globals->system_name);
     $c->stash->{user_object} = $c->user_object;
     $c->stash->{display_nav} = 1  unless defined $c->request->params->{'_nav'} && $c->request->params->{'_nav'} eq 'no';
     $c->stash->{start_prompt} = entityise(mlmessage('print_start_prompt',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{end_prompt} = entityise(mlmessage('print_end_prompt',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{format_prompt} =
     entityise(mlmessage('format',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{print_prompt} = entityise(mlmessage('print',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{tag_prompt} = entityise(mlmessage('headwordtags',$c->user_object->{'lang'}),$c->request->headers->{'user-agent'});
     $c->stash->{date} = localtime;
     $c->stash->{print_allow_xref} = FreelexDB::Globals->print_allow_xref || 0;
     
  }
}

sub detail : Path('detail') {
  my( $self, $c ) = @_;
  my $h;  # headword entry
  my @subclauses;
    
  $c->stash->{message} = entityise(utfise(($c->request->params->{'_message'})))   if defined $c->request->params->{'_message'}; 
  $c->stash->{display_order} = Freelex::Model::FreelexDB::Headword->display_order_print;
  
  if (!defined $c->request->params->{'_detail'}  && (!$c->stash->{print_allow_xref} || !defined $c->request->params->{'_xref'})) {
     # 
     # just print out the input form
     #
     my $catdefault = $c->request->params->{tagid} || 'dropdown-first';
     $c->stash->{tagbox} =  xlateit(fldropdown('tag','tagid','tag',$catdefault,'__mlmsg_any_tag__'),$c->user_object->{'lang'},$c->request->headers->{'user-agent'},"form");


     $c->stash->{template} = 'printdetailreqform.tt';
     $c->detach('Freelex::View::TT')  
   }
   else {
      my $start = utfise($c->request->params->{'_start'}) || "";
      my $startcollate = collatestring($start);
      if ($startcollate =~ /^\!\!\!error/i) {
         bail($c,'__mlmsg_start_field_has_funny_characters__');
         return;
      }
      push @subclauses, "collateseq >= " . FreelexDB::DBI->db_Main->quote($startcollate)    if $startcollate;

      my $end = utfise($c->request->params->{'_end'}) || "";
      my $endcollate = collatestring($end);
      if ($endcollate =~ /^\!\!\!error/i) {
         bail($c,'__mlmsg_end_field_has_funny_characters__');
         return;
      }
      
      $end = $start unless $end;
      
# add final character one higher than highest character to end of end str
      $endcollate = collatestring($end . (highestchar() x 50));
      push @subclauses, "collateseq <= " . FreelexDB::DBI->db_Main->quote($endcollate)      if $endcollate;
      if ($endcollate lt $startcollate) {
         bail($c,'__mlmsg_end_is_before_start__');
         return;
      }
     
      if ($c->request->params->{'tagid'} && $c->request->params->{'tagid'} ne 'dropdown-first') {
         push @subclauses, ' (headwordid IN (SELECT headwordid FROM headwordtag WHERE headwordtag.headwordid=headword.headwordid AND tagid=' . $c->request->params->{'tagid'}  . '))';
      }

#      if ($c->request->params('categoryid') && ($c->request->params('categoryid') ne 'dropdown-first')) {
#         push @subclauses, ' categoryid = ' . $c->request->params('categoryid');
#      }
      
      my $whereclause = join(' AND ',@subclauses); 
      $whereclause = ' WHERE ' . $whereclause    if $whereclause;
      $c->stash->{whereclause} = $whereclause;
      
      $c->stash->{'printrows'} = Freelex::Model::FreelexDB::Headword->retrieve_from_sql($whereclause . ' ORDER BY  collateseq, headword, variantno');
      if (defined $c->request->params->{'_detail'}) {   
      # print detail    
         my @entries = ();
         while (my $r = $c->stash->{printrows}->next) {
            my $entry = {};
            foreach my $c (@{$c->stash->{display_order}}) {
               my $val = $r->$c || "";
               if ($val =~ /<div>|<span>/) {
#                   $val =~ s/<(?:\/)?(?:p|div)>//sig;
                    $val =~ s/<(?:p|div)>//sig;
                    $val =~ s/<\/(?:p|div)>/<br>/sig;
               } else {
                   $val =~ s/\n/\n<br>\n/sig;
               }
               $entry->{$c} = entityise($val);
            }
            push @entries,$entry;
         }
         $c->stash->{'entries'} = \@entries;
         
         $c->stash->{'template'} = 'printdetail.tt';
         
           FreelexDB::Activityjournal->insert( {
              activitydate => $c->stash->{date},
              matapunauserid => $c->user_object->matapunauserid,
              verb => 'print',
              object => 'detail',
              description => $start . ' - ' . $end
            });
            
           FreelexDB::Activityjournal->dbi_commit;

      }
      else { # print xref
         my %cshash;
         my $fentries = {}; # forward direction (eg maori->english)
         my $rentries = {}; # reverse direction
         while (my $xre = $c->stash->{printrows}->next) {
            next unless $xre->gloss;
            my @glosses = map {trim($_)} split(/\,/, $xre->{gloss});
            my $hw = $xre->headword;
            if (!defined $fentries->{$hw}) {
               $fentries->{$hw} = [];
            }
            my $cs = collatestring($hw);
            $cshash{$hw} = $cs;
            push @{$fentries->{$hw}}, {gloss=> $xre->gloss, id=> $xre->headwordid};
            foreach my $g (@glosses) {
               next unless $g;
               if (!defined $rentries->{$g}) {
                  $rentries->{$g} = [];
               }
               push @{$rentries->{$g}}, {headword=> $xre->headword, collateseq => $cs, id=> $xre->headwordid};
            }
         }
         my $fearray = [];
         foreach my $fek (sort {$cshash{$a} cmp $cshash{$b}} keys %$fentries) {
            my @fe = sort {lc(ignoreleadingbrackets($a->{gloss})) cmp lc(ignoreleadingbrackets($b->{gloss}))}  @{$fentries->{$fek}};
            if (scalar @fe > 1) {
               my $i = 1;
               foreach my $ff (@fe) {
                  $ff->{index} = $i++;
               }
            }
            push @$fearray, {headword => entityise($fek), entries=>[@fe]};
         }
         my $rearray = [];
         foreach my $rek (sort {lc(ignoreleadingbrackets($a)) cmp lc(ignoreleadingbrackets($b))} keys %$rentries) {
            my @re = sort {$a->{collateseq} cmp $b->{collateseq}}  @{$rentries->{$rek}};
            if (scalar @re > 1) {
               my $j=1;
               foreach my $rr (@re) {
               $rr->{index} = $j++;
               $rr->{headword} = entityise($rr->{headword});
               }
            }
            push @$rearray, { gloss=> $rek, entries=>[@re]};
         }

         $c->stash->{template} = 'printxref.tt';
         $c->stash->{forward_entries} = $fearray;
         $c->stash->{reverse_entries} = $rearray;
         
         FreelexDB::Activityjournal->insert( {
              activitydate => $c->stash->{date},
              matapunauserid => $c->user_object->matapunauserid,
              verb => 'print',
              object => 'xref',
              description => $start . ' - ' . $end
            });
            
         FreelexDB::Activityjournal->dbi_commit;
      }
      $c->detach('Freelex::View::TT');  
   }
}


sub end : Private {
   my ( $self, $c ) = @_;
   die "You requested a dump"   if ((defined $c->request->params->{'_dump'}) && $c->request->params->{'_dump'} eq 1);
}

sub bail {
   my $c = shift;
   my $m = shift;
   $c->stash->{'message'} = mlmessage_block($m,$c->user_object->{lang});
   $c->stash->{template} = 'printdetailreqform.tt';
   $c->forward('Freelex::View::TT');
   return 0;
}

sub ignoreleadingbrackets {
   my $x = shift || return;
   $x =~ s/\s*\([^\)]+\)\s*//sig;
   return $x;
}
   
   

1;
