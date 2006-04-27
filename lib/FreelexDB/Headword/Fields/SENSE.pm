#
# This is a pseudo-field representing the sense structure
#

sub format_SENSE_plain {
   my $self = shift;
   my $variantno = ref $self && $self->variantno || "";
   my $majsense = ref $self && $self->majsense || "";
   return $variantno . ":" . $majsense;
}

sub format_SENSE_form {
   my $self = shift;
   my $variantno = ref $self && $self->variantno || "";
   my $majsense = ref $self && $self->majsense || "";
   return fltextbox('variantno',$variantno,1) . ':' . fltextbox('majsense',$majsense,1);
}

sub validate_SENSE {
   my $self = shift;
   return (notnumeric($self,'variantno'),notnumeric($self,'majsense'));
}

1;
      

   
     
      
         