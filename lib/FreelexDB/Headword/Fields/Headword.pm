sub format_headword_html_type { '<b>' }
sub format_headword_form_type { 'textbox' }
sub validate_headword {
   my $self = shift;
   return (orthography($self,'headword'),containspunctuation($self,'headword'),isblank($self,'headword'),containsuc($self,'headword'),dupheadword($self,'headword'));

}

sub dupheadword {
   my $self = shift;
   my $field = shift;
   # only perform this check if it's a new headword
   return () if defined $self->headwordid  &&  $self->headwordid;
   
   my $headword = trim($self->headword);
   my @dups = FreelexDB::Headword->search( headword => $headword, { order_by => 'collateseq, headword, headwordid'} );
   
   return () unless @dups;
   
   my @duplist;
   
   foreach my $dup (@dups) {
      push @duplist, '<a href="display?_id=' . $dup->headwordid . '&_nav=no" target="_new">' . $dup->hyphenated . '</a>';
   }
   return ('__mlmsg_duplicate_entries__:&nbsp;' . join(', ',@duplist))
}

1;
      

   
     
      
         