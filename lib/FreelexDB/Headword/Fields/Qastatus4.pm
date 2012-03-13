sub default_qastatus4 { "1" };

sub format_qastatus4_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus4) && $self->qastatus4;
   return $self->qastatus4->qastatus;
}

sub format_qastatus4_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user->get('qalevel') || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus4;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus4/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         