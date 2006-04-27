sub default_categoryid { 1 };

sub format_categoryid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->categoryid) && $self->categoryid;
   return $self->categoryid->category;
}

sub format_categoryid_form {
   my $self = shift;
   my $field = getfieldnamefromformatsub();
   
   my $val = (ref $self && defined $self->$field) ? $self->$field->$field : default_categoryid;

   my $dd = fldropdown('category','categoryid','category',$val);
   return $dd;
}


1;
 