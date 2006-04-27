sub default_wordclassid { 1 };

sub format_wordclassid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->wordclassid) && $self->wordclassid;
   return $self->wordclassid->symbol;
}

sub format_wordclassid_form {
   my $self = shift;
   my $field = getfieldnamefromformatsub();
   
   my $val = (ref $self && defined $self->$field) ? $self->$field->$field : default_wordclassid;
   
   my $dd = fldropdown('wordclass','wordclassid','symbol',$val);
   return $dd;
   
}

sub validate_wordclassid {
#
# Not allowed for a non-base wordclass to take secondary wordclasses
#   
   my $self = shift;
   return ()   if $self->wordclassid <= 6;  #  if it's a base, it's not a problem
   foreach my $v  (grep(/^wcs/, FreelexDB::Headword->all_columns)) {
      return '__mlmsg_nonbase_cant_take_secondary__'  if $self->$v;
   }
   return ();
}

1;
      

   
     
      
         