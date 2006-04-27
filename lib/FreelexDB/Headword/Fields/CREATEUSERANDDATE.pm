sub format_CREATEUSERANDDATE_plain {
   my $self = shift;   
   unless ((ref $self) && (defined $self->createuserid)) { return '[none]' }
   my $username = $self->createuserid->matapunauser;
   my $date = $self->createdate ? ' ' . $self->createdate :  "";
   return $username . $date;
}

1;
      

   
     
      
         