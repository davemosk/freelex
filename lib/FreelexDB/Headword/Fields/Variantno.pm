sub format_variantno_form {
   my $self = shift;
   my $variantno = ref $self && $self->variantno || "";
   return fltextbox('variantno',$variantno,1);
}

sub validate_variantno {
   my $self = shift;
   return (notnumeric($self,'variantno'));
}

1;
      

   
     
      
         