sub default_borrowedlangid { 1 };

sub format_borrowedlangid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->borrowedlangid && $self->borrowedlangid && $self->borrowedlangid != 1);
   return $self->borrowedlangid->borrowedlang;
}

sub format_borrowedlangid_form {
   my $self = shift;
   my $fieldid = getfieldnamefromformatsub();  
   my $field = $fieldid;
   $field =~ s/id$//; 
   my $val = ref $self ? $self->$fieldid->id : default_borrowedlangid;
   my $dd = fldropdown($field,$fieldid,$field,$val);
   return $dd;
}


1;
 