sub default_qastatus9 { "1" };

sub format_qastatus9_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus9) && $self->qastatus9;
   return $self->qastatus9->qastatus;
}

sub format_qastatus9_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user_object->qalevel || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus9;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus9/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         