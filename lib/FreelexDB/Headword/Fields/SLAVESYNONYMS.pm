sub format_SLAVESYNONYMS_plain {
   my $self = shift;
   return unless ref $self;
   my @synlist = ();
   foreach my $entry ( FreelexDB::Headword->search( mastersynonymheadwordid => $self->headwordid, { order_by => 'collateseq, variantno, majsense, minsense' } ) ) {
      push @synlist, $self->printedreference($entry->headwordid);
   }
   if (@synlist) { 
      return FreelexDB::Globals->slave_synonym_ref_chars->[0] . join(', ', @synlist) . FreelexDB::Globals->slave_synonym_ref_chars->[1];
   }
   else { return "" }
}


1;
