sub default_qastatus5 { "1" };

sub format_qastatus5_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus5) && $self->qastatus5;
   return $self->qastatus5->qastatus;
}

sub format_qastatus5_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user->get('qalevel') || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus5;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus5/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         