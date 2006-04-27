sub default_qastatus2 { "1" };

sub format_qastatus2_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus2) && $self->qastatus2;
   return $self->qastatus2->qastatus;
}

sub format_qastatus2_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user_object->qalevel || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus2;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus2/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         