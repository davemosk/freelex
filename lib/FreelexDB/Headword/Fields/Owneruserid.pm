sub format_owneruserid_plain {
   my $self = shift;  
   if ((ref $self) && defined ($self->owneruserid)) {   
      return $self->owneruserid->matapunauser
   } 
   else { return '[none]' }
}


1;
      

   
     
      
         