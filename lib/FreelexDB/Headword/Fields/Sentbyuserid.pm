sub format_sentbyuserid_plain {
   my $self = shift;  
   if ((ref $self) && defined ($self->sentbyuserid)) {   
      return $self->sentbyuserid->matapunauser
   } 
   else { return '[none]' }
}


1;
      

   
     
      
         