
sub format_USAGE_form {
   my $self = shift;
   my @result = ();
   my $usagetable = {};
   
   foreach my $usage  (FreelexDB::Usage->retrieve_all) {
      $usagetable->{$usage->usage} = $usage->usageid
   }
   
   if (ref $self) {
      return $self->makecheckboxtable('usage',$usagetable)
   }
   else {
      return makecheckboxtable("",'usage',$usagetable);
   }
}

sub format_USAGE_plain {
   my $self = shift;
   my @result = ();
   return "" unless ref $self;
   
   foreach my $usage  (FreelexDB::Usage->retrieve_all) {
      $usagemethod = 'usage' . $usage->usageid;
      if (defined $self->$usagemethod && $self->$usagemethod) {
         push @result, $usage->usage
      }
   }
   return join('/',@result);
};

1;