sub format_mastersynonymheadwordid_form {
   my $self = shift;
   if (ref $self) {
      return $self->format_master_form_proto('synonym')
   }
   else { return fltextbox("mastersynonymheadwordid","") }
}

sub postdisplay_mastersynonymheadwordid {
   my $self = shift;
   return $self->postdisplay_master_proto('synonym');
}


sub validate_mastersynonymheadwordid {
   my $self = shift;
   return ($self->masterformat('synonym'),$self->masterrecursion('synonym'))
}

1;
      

   
     
      
         