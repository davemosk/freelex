
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
      my $usagemethod = 'usage' . $usage->usageid;
      if (defined $self->$usagemethod && $self->$usagemethod) {
         push @result, $usage->symbol
      }
   }
   return join('/',@result);
}

sub pre_update_USAGE {
   my $self = shift;
   my $c = shift;
   foreach my $usage  (FreelexDB::Usage->retrieve_all) {
      my $usagemethod = 'usage' . $usage->usageid;
      if (exists $c->request->parameters->{$usagemethod}  && !$c->request->parameters->{$usagemethod}) {
         $self->set($usagemethod,0);
      }
   }
}


1;