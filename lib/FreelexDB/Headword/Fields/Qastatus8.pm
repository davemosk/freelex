sub default_qastatus8 { "1" };

sub format_qastatus8_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->qastatus8) && $self->qastatus8;
   return $self->qastatus8->qastatus;
}

sub format_qastatus8_form {
   my $self = shift;
   my $c = shift;
   my $userqalevel = $c->user_object->qalevel || 0;
   my $field = getfieldnamefromformatsub();
   my $dd;
   
   if ($userqalevel >= 2) {
   
      my $val = (ref $self && defined $self->$field) ? $self->$field->qastatusid : default_qastatus8;
   
      $dd = fldropdown('qastatus','qastatusid','qastatus',$val);
      $dd =~ s/qastatusid/qastatus8/ig;
      
   }
   else {
      $dd = (ref $self && defined $self->$field) ? $self->$field->qastatus : "[none]";
   }
   
   return $dd;
}


1;
      

   
     
      
         