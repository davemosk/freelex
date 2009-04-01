sub default_qastatus6 { "1" };

sub format_qastatus6_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus6) && $self->qastatus6;
   return $self->qastatus6->qastatus;
}

sub format_qastatus6_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user_object->qalevel || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus6;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus6/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         