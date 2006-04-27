sub format_example_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->example && $self->example); return sentencise($self->example);
} 
sub format_example_html_type { '<i>' }
sub format_example_form_type { 'textarea' }
sub validate_example {
   my $self = shift;
   return ($self->orthography('example'));
}

1;
      

   
     
      
         