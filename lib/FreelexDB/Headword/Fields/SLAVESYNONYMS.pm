sub format_SLAVESYNONYMS_plain {
   my $self = shift;
   return unless ref $self;
   my @synlist = ();
   foreach my $entry ( FreelexDB::Headword->search( mastersynonymheadwordid => $self->headwordid, { order_by => 'collateseq, variantno, majsense, minsense' } ) ) {
      push @synlist, $self->printedreference($entry->headwordid);
   }

   if (@synlist) { 
      my $left = exists &{"FreelexDB::Globals::slave_synonym_ref_chars"} && 
                 defined FreelexDB::Globals->slave_synonym_ref_chars->[0] ? FreelexDB::Globals->slave_synonym_ref_chars->[0] : "";
      my $right = exists &{"FreelexDB::Globals::slave_synonym_ref_chars"} &&
                  defined FreelexDB::Globals->slave_synonym_ref_chars->[1] ? FreelexDB::Globals->slave_synonym_ref_chars->[1] : "";
      return $left . join(', ', @synlist) . $right;
   }
   else { return "" }
}


1;
