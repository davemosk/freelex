sub format_definition_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->definition && $self->definition); return sentencise($self->definition);
}

sub format_definition_form_type { 'textarea' }
#sub validate_definition {
#   my $self = shift;
#   return ($self->orthography('definition'));
#}         

1;