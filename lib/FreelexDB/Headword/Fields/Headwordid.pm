sub format_headwordid_plain {
   my $self = shift;  
   return "[new]" unless ref $self && defined $self->headwordid; 
   return $self->headwordid;
}


1;
      

   
     
      
         