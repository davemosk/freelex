sub default_qastatus3 { "1" };

sub format_qastatus3_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus3) && $self->qastatus3;
   return $self->qastatus3->qastatus;
}

sub format_qastatus3_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user_object->qalevel || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus3;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus3/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         