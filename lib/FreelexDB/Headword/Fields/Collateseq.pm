sub pre_update_collateseq {
  my $self = shift;
  $self->set("collateseq",collatestring($self->headword));
}


1;
 