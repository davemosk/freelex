
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
      my $wcsmethod = 'wcs' . $wordclass->wordclassid;
      if (defined $self->$wcsmethod && $self->$wcsmethod) {
         push @result, $wordclass->symbol
      }
   }
   return join(FreelexDB::Globals->wordclass_join_char,@result);
};


sub pre_update_SECONDARYWORDCLASS {
   my $self = shift;
   my $c = shift;
   foreach my $wordclass  (FreelexDB::Wordclass->search( canbesecondary => 't', { order_by => 'wordclass' }  )) {
      my $wcsmethod = 'wcs' . $wordclass->wordclassid;
      if (exists $c->request->parameters->{$wcsmethod}  && !$c->request->parameters->{$wcsmethod}) {
         $self->set($wcsmethod,0)
      }
   }
}

1;