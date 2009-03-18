use Data::Dumper;

sub format_HEADWORDTAGS_plain {
   my $self = shift;   
   my $c = shift;
   my @hwtags;

   if (my @headwordtags = $self->headwordtags) {
      foreach my $ht (@headwordtags) {
         push @hwtags, $ht->tagid->tag;
      }
   }
   return join(',', sort @hwtags);
}

sub format_HEADWORDTAGS_form {
   my $self = shift;   
   my $c = shift;
   my $selected;
   
   if ( defined $c && defined $c->{request}->{parameters}->{tagid} && $c->{request}->{parameters}->{tagid}) {
      $selected = $c->{request}->{parameters}->{tagid};
   }
   else {
   
      $selected = [];
      if (ref $self) {
         if (my @headwordtags = $self->headwordtags) {
            foreach my $ht (@headwordtags) {
               push @$selected, $ht->tagid;
            }
         }
      }
   }
   
   my $dd = fldropdown('tag','tagid','tag',$selected,undef,5); 
   return $dd;
}

sub validate_HEADWORDTAGS {
   my $self = shift;
   my $c = shift || return ();
   return ()  unless (exists &{"FreelexDB::Globals::tags_should_have_at_least_one"} &&
                  defined FreelexDB::Globals->tags_should_have_at_least_one &&
                  FreelexDB::Globals->tags_should_have_at_least_one);
   return ()  if $c->request->{parameters}->{tagid};
   return ()  if $self->headwordtags;
   return ('__mlmsg_should_have_at_least_one_tag__');
}

sub post_update_HEADWORDTAGS {
   my $self = shift;
   my $c = shift;

   $formtags = $c->{request}->{parameters}->{tagid};
   
   my %fthash = ();
   if (defined $formtags) {
      if (ref $formtags) {
         foreach my $f (@$formtags) {
            $fthash{$f} = 1
         }
      } 
      else { $fthash{$formtags} = 1 }
   }
      
   my @dbtags = $self->headwordtags;
   my %dbthash = ();
      
   foreach my $ht (@dbtags) {
      my $httagid = $ht->tagid;
      
      if ($httagid && $fthash{$httagid}) { 
      # don't worry about tags that were selected and are still in the db
         delete $fthash{$httagid} 
      } 
      # if it's in the db but wasn't selected, we need to delete it from the db
      else {
         $ht->delete()
      }
   }
   
   # now go through the remainder of the tags that were selected, but weren't yet in the database, and insert them.
   
   foreach my $ft (keys %fthash) {
      FreelexDB::Headwordtag->insert( { headwordid => $self->headwordid, tagid => $ft });
   }
   return;
}
   
   
   

1;
      

   
     
      
         