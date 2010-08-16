sub default_allocateduserid { "" };

sub format_allocateduserid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->allocateduserid) && $self->allocateduserid;
   return undef if $self->allocateduserid eq 'dropdown-first';
   return $self->allocateduserid->matapunauser;
}

sub format_allocateduserid_form {
   my $self = shift;
   my $field = getfieldnamefromformatsub();
   
   my $val = (ref $self && defined $self->allocateduserid) ? $self->allocateduserid->matapunauserid : default_allocateduserid;
   
   my $dd = fldropdown('matapunauser','matapunauserid','matapunauser',$val,'__mlmsg_anyone__');
   $dd =~ s/matapunauserid/allocateduserid/ig;
   
   if (ref $self && defined $self->sentbyuserid && $self->sentbyuserid) {
      $dd .= '(' . '__mlmsg_originally_from__' . ' ' . trim($self->sentbyuserid->matapunauser) . ')';
   }
   
   return $dd;
   
}

sub pre_update_allocateduserid {
  my $self = shift;
  my $c = shift;
  return unless ref $self && $self->allocateduserid;
  if ($self->allocateduserid eq 'dropdown-first') {
     $self->set("allocateduserid",undef);
     $self->set("sentbyuserid",undef);
     $self->set("workqueueposition",undef);
     return;
  }
  # return it to "the pool" if:
  #  - we're sending it to ourselves
  if ($self->allocateduserid eq $c->user_object->matapunauserid)  {
     $self->set("allocateduserid",undef);
     $self->set("sentbyuserid",undef);
     $self->set("workqueueposition",undef);
  }
  else {
     $self->set("sentbyuserid",$c->user_object->matapunauserid);
     $self->set("workqueueposition",1);
  }
}


1;
      

   
     
      
         