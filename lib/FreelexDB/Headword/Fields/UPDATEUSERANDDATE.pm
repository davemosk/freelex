sub format_UPDATEUSERANDDATE_plain {
   my $self = shift;
   unless ((ref $self) && (defined $self->updateuserid)) { return '[none]' }
   my $username = $self->updateuserid->matapunauser;   
   my $date = $self->updatedate ? ' ' . $self->updatedate :  "";
   return $username . $date;
}


1;
      

   
     
      
         