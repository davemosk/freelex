
sub format_SECONDARYWORDCLASS_form {
   my $self = shift;
   my @result = ();
   my $wcstable = {};
   
   foreach my $wordclass  (FreelexDB::Wordclass->search( canbesecondary => 't', { order_by => 'wordclass' }  )) {
      $wcstable->{$wordclass->symbol} = $wordclass->wordclassid
   }
   
   if (ref $self) {
      return $self->makecheckboxtable('wcs',$wcstable)
   }
   else {
      return makecheckboxtable("",'wcs',$wcstable);
   }
}

sub format_SECONDARYWORDCLASS_plain {
   my $self = shift;
   my @result = ();
   return "" unless ref $self;
   
   foreach my $wordclass  (FreelexDB::Wordclass->search( canbesecondary => 't', { order_by => 'wordclass' }  )) {
      $wcsmethod = 'wcs' . $wordclass->wordclassid;
      if (defined $self->$wcsmethod && $self->$wcsmethod) {
         push @result, $wordclass->symbol
      }
   }
   return join('/',@result);
};

1;