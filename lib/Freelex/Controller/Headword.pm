package Freelex::Controller::Headword;

use base qw/Catalyst::Controller/;
use strict;

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
     $c->stash->{fckpath} = FreelexDB::Globals->fckeditor_path;  
     $c->stash->{date} = localtime;
     $c->stash->{workflow} = $c->request->params->{'_wf'} || 0;
     $c->stash->{wf_next_entry} = entityise(mlmessage('wf_next_entry',$c->user_object->{lang}));
     $c->stash->{enable_delete_button_data_entry} = FreelexDB::Globals->enable_delete_button_data_entry;
  }
}

sub display : Path('display') {
  my( $self, $c ) = @_;
  my $h;  # headword entry
    
  $c->stash->{message} = entityise(utfise(($c->request->params->{'_message'})))   if defined $c->request->params->{'_message'}; 
  $c->stash->{template} = 'addedit.tt';
  $c->stash->{display_order} = Freelex::Model::FreelexDB::Headword->display_order_form;
  my $id = $c->request->params->{'_id'};
  $id = 'new'   unless $id;
  $c->stash->{id} = $id;

  $c->stash->{clonable} = 0;
  if ($id ne 'new' && defined FreelexDB::Globals->enable_cloning && FreelexDB::Globals->enable_cloning) {
     $c->stash->{clonable} = 1;
     $c->stash->{clone} = xlateit('__mlmsg_clone__',$c->user_object->lang,$c->request->headers->{'user-agent'});
  }

  if ($id ne 'new') {
     $h = Freelex::Model::FreelexDB::Headword->retrieve($id);
     $c->stash->{title} = mlmessage('edit_headword',$c->user_object->lang,$c->request->headers->{'user-agent'}) . entityise($h->hyphenated);  
     $c->stash->{archivecopy} = $h->rowtohashref;
     #
     # set up history link
     #
     $c->stash->{history} = entityise(mlmessage('history',$c->user_object->lang),$c->request->headers->{'user-agent'});

  } 
  elsif (my $writefailmsg = FreelexDB::Headword->no_write_access($c)) {
     $c->stash->{message} = $writefailmsg;
     $c->stash->{'dont_render_template'} = 1;
     $c->redirect('display?_id='.$id.'&_message=' . uri_escape_utf8($c->stash->{message}));
     return 0;
  } 

  $c->stash->{fields} = {};
  $c->stash->{warnings} = {};
  foreach my $col (@{$c->stash->{display_order}}) {  
     if ($id eq 'new') {
        my $f = Freelex::Model::FreelexDB::Headword->format("",$col,"form",$c);
        $c->stash->{fields}->{$col} = entityise($f);
#        $c->stash->{thispretty}->{$col} = entityise(Freelex::Model::FreelexDB::Headword->format("",$col,"plain"));
     }
     else { 
        $c->stash->{fields}->{$col} = entityise($h->format(trim($col),"form",$c));
        my @warnings = $h->validate($col,$c);
        $c->stash->{warnings}->{$col} = entityise(utfise((join('<br> ',@warnings))))     if @warnings;
     }
  }

  unless ($id eq 'new') {
     foreach my $col (@{FreelexDB::Headword->display_order_print}) {  
        $c->stash->{thispretty}->{$col} = entityise(mlmessage_block($h->format(trim($col),"plain"),$c->user_object->lang));
     }
     $c->stash->{thispretty}->{_variantno} = $h->variantno   if ((defined $h->variantno) && $h->variantno);
     $c->stash->{thispretty}->{_majsense} = $h->majsense   if ((defined $h->majsense) && $h->majsense);
     $c->stash->{headword} = $h->headword;
     $c->stash->{sensestr} = makesensestr($h);
     makeprettyarray($c);
     $h->discard_changes;
  }
}

sub commit : Path('commit') {
  my ( $self, $c ) = @_;
  my $id = $c->request->params->{'_id'} || die "no id supplied";
  $c->stash->{id} = $id;
  $c->stash->{matapunauserid} =  $c->user_object->matapunauserid;
  if ($c->request->params->{_delete}) { $c->detach('/headword/del') }
  my $ignore_warnings = $c->request->params->{'_ignorewarn'} || 0;
  
  my $h;

  $c->stash->{cloning} = $c->request->params->{_clone} || 0;

  $c->stash->{clonable} = 0;
  if ($id ne 'new' && defined FreelexDB::Globals->enable_cloning && FreelexDB::Globals->enable_cloning) {
     $c->stash->{clonable} = 1;
     $c->stash->{clone} = xlateit('__mlmsg_clone__',$c->user_object->lang,$c->request->headers->{'user-agent'});
  }

  if ($c->stash->{cloning}) {  
     $c->stash->{clonedfrom} = $c->request->params->{_clonedfrom} || 0; 
  }
  
  if ($id eq 'new' || $c->request->params->{_clone}) {
     $h = Freelex::Model::FreelexDB::Headword->construct( {} )
  }
  else {
     $h = Freelex::Model::FreelexDB::Headword->retrieve($id);
     #
     # make an archival copy
     #
     $c->stash->{archivecopy} = $h->rowtohashref;
     #
     # set up history link
     #
     $c->stash->{history} = entityise(mlmessage('history',$c->user_object->lang),$c->request->headers->{'user-agent'});
  }
  if (my $writefailmsg = $h->no_write_access($c)) {
     $c->stash->{message} = entityise($writefailmsg,$c->request->headers->{'user-agent'});
     $c->stash->{'dont_render_template'} = 1;
     $c->redirect('display?_id='.$id.'&_message=' . uri_escape_utf8($c->stash->{message}));
     return 0;
  }

  #
  # Slurp in the form fields
  #
  
  foreach my $col (keys %{$c->request->params}) {
    if (ref $h->find_column($col)) {
       my $currentval = $h->$col || "";
       my $newval = trim(utfise($c->request->params->{$col}))  || "";
       if ($currentval ne $newval) {
          if ($newval) { $h->$col($newval) }
          else { $h->$col(undef) }
       } 
       $h->postdisplay($col);
    }
  }
 
  $c->stash->{headword} = $h->headword;
  
  #
  # validate them ... 
  #
  
  unless ($ignore_warnings) {
    $c->stash->{warnings} = {};
    $c->stash->{thispretty} = {};
    $c->stash->{display_order} = Freelex::Model::FreelexDB::Headword->display_order_form;
    foreach my $col (@{$c->stash->{display_order}}) {   
        my @warnings = $h->validate($col,$c);
        my @other_args = ();
        my $external_fields = Freelex::Model::FreelexDB::Headword->external_fields;
#        if (grep { $col eq $_ } @$external_fields) {
#           @other_args = ($c)
#        }
        $c->stash->{fields}->{$col} = entityise($h->format($col,"form",$c));
           
        if (@warnings) {
           $c->stash->{have_warnings} = 1;
           $c->stash->{warnings}->{$col} = entityise(utfise(join('<br> ',@warnings)));
        }
     }
     
     foreach my $col (@{FreelexDB::Headword->display_order_print}) {
       $c->stash->{thispretty}->{$col} = entityise($h->format($col,"plain",$c));
     }
     
     
     $c->stash->{thispretty}->{_variantno} = $h->variantno   if ((defined $h->variantno) && $h->variantno);
     if ($c->stash->{have_warnings}) {
        $c->stash->{sensestr} = makesensestr($h);
        $h->discard_changes;
        $c->stash->{message} = xlateit('__mlmsg_not_saved_warnings__',$c->user_object->lang,$c->request->headers->{'user-agent'});
        $c->stash->{ignore_warnings_message} = xlateit('__mlmsg_ignore_warnings__',$c->user_object->lang,$c->request->headers->{'user-agent'});
        $c->stash->{template} = 'addedit.tt';
        makeprettyarray($c);
        return;
     }
  }
  
  
  #
  # archive the copy
  #
  
  $c->stash->{archivecopy}->{'archiveuserid'} = $c->user_object->matapunauserid;
  $c->stash->{archivecopy}->{'archivedate'} = $c->stash->{date};
  my $archive = FreelexDB::Hwarchive->insert($c->stash->{archivecopy});
  
# do any required pre-update processing
  
  foreach my $col (FreelexDB::Headword->all_columns, FreelexDB::Headword->columns("TEMP"),FreelexDB::Headword->pseudo_cols) {
     $h->preupdate($col,$c)
  }
  
#  foreach my $col (FreelexDB::Headword->all_columns) {
#
#     next unless ref $h->find_column($col);
#     next unless $h->$col =~ /\#\#/;
#     my $deref = FreelexDB::Headword->dereference($h->$col);
#     $h->set($col,$deref)  unless $h->$col eq $deref;
#  }

   
  if (defined $h->headwordid && !($c->request->params->{_clone})) { 
  
     #
     # Update the row
     #
  
     $h->set('updateuserid',$c->stash->{matapunauserid});
     $h->set('updatedate',$c->stash->{date});
  
     $h->update();
     $c->stash->{message} = mlmessage_block("__mlmsg_successfully_updated__::headword::" . $h->hyphenated . '__');
     $c->stash->{verb} = 'edit';

  }
  else {
  
     # create the row
     $h->set('createuserid',$c->stash->{matapunauserid});
     $h->set('createdate',$c->stash->{date});
     $h->set('owneruserid',$c->stash->{matapunauserid});
     my $inserted_row = $h->copy;
     $h->discard_changes;
     $h = $inserted_row;
     $id = $h->headwordid;
     $c->stash->{id} = $id;
     $c->stash->{message} = mlmessage_block("__mlmsg_successfully_added__::headword::" . $h->hyphenated . '__');
     $c->stash->{verb} = $c->request->params->{_clone} ? 'clone' : 'add';

  }
  # do any required post-update processing
  
  foreach my $col (FreelexDB::Headword->all_columns, FreelexDB::Headword->columns("TEMP"),FreelexDB::Headword->pseudo_cols) {
     $h->postupdate($col,$c)
  }
 
  #
  # Add a row to the activity journal
  #
  
  FreelexDB::Activityjournal->insert( {
     activitydate => $c->stash->{date},
     matapunauserid => $c->stash->{matapunauserid},
     verb => $c->stash->{verb},
     object => 'headword',
     description => $h->hyphenated
     });
     
  
  #
  # finish up
  #  
  $h->dbi_commit;

  if ($c->request->params->{_clone}) {
     foreach my $col (FreelexDB::Headword->all_columns, FreelexDB::Headword->columns("TEMP"),FreelexDB::Headword->pseudo_cols) {
        $h->clone($col,$c)
     }
  }
  
  if ($c->request->params->{'_nextwf'}) {
    $c->stash->{'dont_render_template'} = 1; 
    do_workflow($c);
    return;
  }
  else {  
     my $wfindicator = $c->stash->{workflow} ? '&_wf=1' : "";
     $c->redirect('display?_id=' . $id . $wfindicator . '&_message=' . uri_escape_utf8($c->{stash}->{message}));
     $c->stash->{'dont_render_template'} = 1; 
  }
  
}

sub del : Path('delete')  {
   my ( $self, $c ) = @_;
   $c->stash->{id} = $c->request->params->{_id};
   my $h = Freelex::Model::FreelexDB::Headword->retrieve($c->stash->{id});
   if ($c->request->params->{'_delabandon'}) { 
      $c->stash->{dont_render_template} = 1;
      $c->redirect('display?_id=' . $c->stash->{id});
      return 0;
   }
   if ($c->request->params->{'_delconfirm'}) {
     my $date = localtime;
     $c->stash->{archivecopy} = $h->rowtohashref;
     $c->stash->{archivecopy}->{archivedate} = $date;
     $c->stash->{archivecopy}->{archiveuserid} = $c->user_object->{matapunauserid};
     my $arc = FreelexDB::Hwarchive->insert($c->stash->{archivecopy});
     FreelexDB::Activityjournal->insert( {
        activitydate => $date,
        matapunauserid => $c->user_object->{matapunauserid},
        verb => 'delete',
        object => 'headword',
        description => $h->hyphenated
     });
     $h->delete;
     $arc->dbi_commit;
     $c->stash->{message} = entityise(mlmessage('entry_deleted',$c->user_object->lang),$c->request->headers->{'user-agent'});
     $c->stash->{dont_render_template} = 1;
     $c->redirect('../freelex');
     return 0;
   }
   else {
      $c->stash->{message} = entityise(mlmessage('delete_confirm',$c->user_object->lang,$h->hyphenated),$c->request->headers->{'user-agent'});
      $c->stash->{confirm} = entityise(mlmessage('confirm_delete',$c->user_object->lang),$c->request->headers->{'user-agent'});
      $c->stash->{abandon} = entityise(mlmessage('dont_delete',$c->user_object->lang),$c->request->headers->{'user-agent'});
      my $rowresults = {};
      foreach my $col (@{Freelex::Model::FreelexDB::Headword->search_result_cols}) {
         $rowresults->{$col} = $h->format($col,"html");
      }
      $c->stash->{hitlist} = [ $rowresults ];
      $c->stash->{template} = 'delconfirm.tt'; 
      $c->detach('Freelex::View::TT');
   }
}   

sub history : Path('history') {
  my( $self, $c ) = @_;
  $c->stash->{message} = entityise(utfise(($c->request->params->{'_message'})))   if defined $c->request->params->{'_message'}; 
  $c->stash->{template} = 'history.tt';
  $c->stash->{display_order} = Freelex::Model::FreelexDB::Headword->display_order_form;
  my $id = $c->request->params->{'_id'};

  my $hwrow = Freelex::Model::FreelexDB::Headword->retrieve($id);
  my @hwarchiverows = Freelex::Model::FreelexDB::Hwarchive->search( headwordid => $id, { order_by => 'archivedate' });
  $c->stash->{hwhistory} = [];
  my @totalhistory = ();
  my $prev = {};
  my $h;
  my $i = 0;
  my @rowresult;
  my $rowr;
  foreach my $row (@hwarchiverows, $hwrow) {
     $i++;
     my $curr = {};
     @rowresult = ();
     if ((ref $row) =~ /hwarchive$/i) {
        my $murow = Freelex::Model::FreelexDB::Matapunauser->retrieve($row->archiveuserid);
        push @rowresult, {label => '<b>archived by</b>', value =>'<b>' . $murow->matapunauser . ' on ' . $row->archivedate . '</b>'};

 #      die Dumper($row) .  'xxx' . Dumper($h)     if ($i eq 3);
     } else {
        push @rowresult, {label => '<b>current entry</b>', value =>''};
     }
     foreach my $col (@{$c->stash->{display_order}}) {
        next if $col eq 'neweditorialcomment';
        $rowr = "";
        next if (grep { $col eq $_ } @{Freelex::Model::FreelexDB::Headword->external_fields} );
        $c->stash->{working_on} = $col;
        my $val = FreelexDB::Headword->format($row,$col,"plain");
        $val =~ s/^<p>//;
        $curr->{$col} = $val;
        $rowr = entityise(mlmessage_block($val,$c->user_object->lang))   if $val;
        if ((!exists $curr->{$col} || !defined $curr->{$col} || !$curr->{$col}) && exists $prev->{$col} && defined $prev->{$col} && $prev->{$col}) {
           $rowr = '<font color="red">[deleted]</font>';
        }
        elsif (!exists $prev->{$col} || !defined $prev->{$col} || (exists $curr->{$col} && defined $curr->{$col} && $curr->{$col} ne $prev->{$col})) {
           $rowr = '<font color="red">' . $rowr . '</font>'   unless $i == 1;
        }
        
        push @rowresult, { label => entityise(mlmessage(lc($col),$c->user_object->lang)), 
        value => $rowr }   if $rowr; 
     }
 #            die Dumper(@rowresult)  if $i == 4;
     $prev = $curr;    
     
     push @totalhistory, [@rowresult];
     $c->stash->{hwhistory} = \@totalhistory;
 #         die Dumper(\@totalhistory) if $i == 4;
   }
   my @revtotalhistory = reverse @totalhistory;
   $c->stash->{hwhistory} = \@revtotalhistory;       
#   @{$c->stash->{hwhistory}} = reverse @{$c->stash->{hwhistory}};
 #       die dumper(\@hwarchiverows);
 
   FreelexDB::Activityjournal->insert( {
              activitydate => $c->stash->{date},
              matapunauserid => $c->user_object->matapunauserid,
              verb => 'history',
              object => $hwrow->hyphenated,
              description => $i
            });
            
   FreelexDB::Activityjournal->dbi_commit;
         

}

sub myediting : Path('myediting') {
   my( $self, $c ) = @_;
   if ( defined FreelexDB::Headword->workflow_list_cols ) {
      my $wfitems = [];
      my @wfhits = FreelexDB::Headword->sth_to_objects(FreelexDB::Headword->sql_all_wf($c->user_object->{matapunauserid}));
      unless (@wfhits) {
        $c->stash->{dont_render_template} = 1; 
	my $finished_redirect = '../freelex?_message=' . uri_escape_utf8(mlmessage('no_more_work_today'));
	$c->redirect($finished_redirect);
	return 0;
      }
      
      foreach my $wfhit (@wfhits) {
         my $pretty = {};
         foreach my $col (@{FreelexDB::Headword->workflow_list_cols}) {   
             $pretty->{$col} = entityise($wfhit->format($col,"plain",$c));
          }
         push @$wfitems, $pretty;
      }
      $c->stash->{wfitems} = $wfitems;
      $c->stash->{template} = 'workflowlist.tt';
   }

   else {
      $c->stash->{dont_render_template} = 1; 
      do_workflow($c);
      return 0;
   }

}

sub end : Private {
   my ( $self, $c ) = @_;
   unless ($c->stash->{'dont_render_template'}) {
      $c->stash->{fieldnamexlated} = {};  
      foreach my $f (keys %{$c->stash->{fields}}) {
         $c->stash->{fieldnamexlated}->{$f} = entityise(mlmessage(lc($f),$c->user_object->lang),$c->request->headers->{'user-agent'});
         $c->stash->{fields}->{$f} = xlateit($c->stash->{fields}->{$f},$c->user_object->lang,$c->request->headers->{'user-agent'},"form"); 
         $c->stash->{warnings}->{$f} = xlateit($c->stash->{warnings}->{$f},$c->user_object->lang,$c->request->headers->{'user-agent'}); 
      }      
      $c->forward('Freelex::View::TT')   
   }
   die "You requested a dump"   if ((defined $c->request->params->{'dump'}) && $c->request->params->{'dump'} eq 1);
}



sub makeprettyarray {
   my $c = shift;
   my $prettyarray = [];
   my $headword = $c->stash->{headword};
   my $sensestr = $c->stash->{sensestr};
   my $lastsensestr;
   my $thissensestr = "";
   my $lastvariantno;
   my $thisvariantno = "";
   my $lastmajsense;
   my $thismajsense = "";
   $c->stash->{thisprinted} = 0;
   $c->stash->{wordclass_join_char} = FreelexDB::Globals->wordclass_join_char;
   my @headwords = FreelexDB::Headword->search(  headword => $headword, { order_by => 'variantno, majsense, minsense' } );
   foreach my $hw (@headwords) {
      next if $hw->{headwordid} == $c->stash->{id};
      my $pretty = {};
      $lastsensestr = $thissensestr;
      $thissensestr = makesensestr($hw);
      $pretty->{'_sensestr'} = $thissensestr;
      if (!$c->stash->{thisprinted} && ($c->stash->{sensestr} ge $lastsensestr) && ($c->stash->{sensestr} lt $thissensestr)) {
         $lastvariantno = $thisvariantno;
         $thisvariantno = $c->stash->{thispretty}->{_variantno};
         $lastmajsense = $thismajsense;
         $thismajsense = $c->stash->{thispretty}->{_majsense};
         $c->stash->{thispretty}->{'_variantno'} = $thisvariantno;
         $c->stash->{thispretty}->{'newvariantno'} = ($thisvariantno ne $lastvariantno) ? 1 : 0; 
         $c->stash->{thispretty}->{'_majsense'} = $thismajsense;
         $c->stash->{thispretty}->{'newmajsense'} = ($thismajsense ne $lastmajsense) ? 1 : 0;
         $c->stash->{thispretty}->{'newheadword'} = 1;
         push @{$prettyarray}, $c->stash->{thispretty};    
         $c->stash->{thisprinted} = 1;    
      }
      $lastvariantno = $thisvariantno;
      $thisvariantno = (defined $hw->variantno && $hw->variantno) ? $hw->variantno : "";
      $pretty->{'_variantno'} = $thisvariantno;
      $pretty->{'newvariantno'} = ($thisvariantno ne $lastvariantno) ? 1 : 0;
      $lastmajsense = $thismajsense;
      $thismajsense = (defined $hw->majsense && $hw->majsense) ? $hw->majsense : "";
      $pretty->{'_majsense'} = $thismajsense;
      $pretty->{'newmajsense'} = ($thismajsense ne $lastmajsense) ? 1 : 0;
      foreach my $col (@{FreelexDB::Headword->display_order_print}) {   
         $pretty->{$col} = entityise($hw->format($col,"plain",$c));
      }
      push @{$prettyarray}, $pretty;
   }
   if ((!$c->stash->{thisprinted}) && ($c->stash->{sensestr} ge $thissensestr)) {
      $lastvariantno = $thisvariantno || "";
      $thisvariantno = $c->stash->{thispretty}->{_variantno} || "";
      $c->stash->{thispretty}->{'_variantno'} = $thisvariantno;
      $c->stash->{thispretty}->{'newvariantno'} = ($thisvariantno ne $lastvariantno) ? 1 : 0; 
      $c->stash->{thispretty}->{'_majsense'} = $thismajsense;
      $c->stash->{thispretty}->{'newmajsense'} = ($thismajsense ne $lastmajsense) ? 1 : 0;
      $c->stash->{thispretty}->{'newheadword'} = 1;
      push @{$prettyarray}, $c->stash->{thispretty};
   }
   $c->stash->{prettyarray} = $prettyarray;
#   die Dumper($prettyarray);
}

sub makesensestr {
   my $hw = shift;
   my $s1 = defined $hw->variantno? $hw->variantno : 0;
   my $s2 = defined $hw->majsense ? $hw->majsense : 0;
   my $s3 = defined $hw->minsense ? $hw->minsense : 0;
   my $ss = sprintf("%05d:%05d:%05d",$s1,$s2,$s3);
   return $ss;
#   return $hw->format("SENSE","plain");
#   return (defined ($hw->variantno && $hw->variantno) ? $hw->variant : "") . ':' .
#           (defined ($hw->majsense && $hw->majsense) ? $hw->majsense : "") . ':' .
#           (defined ($hw->minsense && $hw->minsense) ? $hw->minsense : "");
}

sub do_workflow {
	my $c = shift;
	my $nextid = getnextwfid($c);
	unless ($nextid) {
		my $finished_redirect = '../freelex?_message=' . uri_escape_utf8(mlmessage('no_more_work_today'));
		$c->redirect($finished_redirect);
		return 0;
	}
	my $redirect =  'display?_id=' . $nextid . '&_wf=1';
	$c->redirect($redirect);
        return 0;
}


sub getnextwfid {
#
# get the headwordid of the next entry to edit in our QA workflow
#
	my $c = shift;
	my $u = $c->user_object->{matapunauserid};
        return FreelexDB::Headword->sql_next_wf($u)->select_val;        
}


1;
