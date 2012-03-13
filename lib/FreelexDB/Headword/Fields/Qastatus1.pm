sub default_qastatus1 { "1" };

sub format_qastatus1_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus1) && $self->qastatus1;
   return undef if $self->qastatus1 eq 'dropdown-first';
   return $self->qastatus1->qastatus;
}

sub format_qastatus1_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user->get('qalevel') || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 1) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus1;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus1/ig;
      
   }
   else {
      $dd = $self->$field->qastatus;
   }
   
   return $dd;
}


1;
      

   
     
      
