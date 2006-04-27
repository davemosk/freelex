sub format_exampletranslation_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->exampletranslation && $self->exampletranslation); return sentencise($self->exampletranslation);
}

sub format_exampletranslation_form_type { 'textarea' }

1;
      

   
     
      
         