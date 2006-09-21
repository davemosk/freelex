sub default_domainid { 1 }

sub format_domainid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->domainid) && $self->domainid;
   return $self->domainid->domain;
}

sub format_domainid_form {
   my $self = shift;
   my $fieldid = getfieldnamefromformatsub();  
   my $field = $fieldid;
   $field =~ s/id$//; 
   my $val = ref $self ? $self->$fieldid->$fieldid : default_domainid;
   my $dd = fldropdown($field,$fieldid,$field,$val);
   return $dd;
}


1;
 