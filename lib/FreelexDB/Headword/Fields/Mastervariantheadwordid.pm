sub format_mastervariantheadwordid_form {
   my $self = shift;
   if (ref $self) {
      return $self->format_master_form_proto('variant')
   }
   else { return fltextbox("mastervariantheadwordid","") }
}

sub postdisplay_mastervariantheadwordid {
   my $self = shift;
   return postdisplay_master_proto($self,'variant');
}

sub validate_mastervariantheadwordid {
   my $self = shift;
   return ($self->masterformat('variant'),$self->masterrecursion('variant'))
}

1;
      

   
     
      
         