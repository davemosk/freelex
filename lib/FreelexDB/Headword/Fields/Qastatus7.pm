sub default_qastatus7 { "1" };

sub format_qastatus7_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus7) && $self->qastatus7;
   return $self->qastatus7->qastatus;
}

sub format_qastatus7_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user->get('qalevel') || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus7;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus7/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         