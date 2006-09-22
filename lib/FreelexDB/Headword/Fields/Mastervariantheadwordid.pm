sub format_mastervariantheadwordid_form {
   my $self = shift;
   my $c = shift;
   if (ref $self) {
      return $self->format_master_form_proto($c,'variant')
   }
   else { return fltextbox("mastervariantheadwordid","") }
}

sub format_mastervariantheadwordid_plain {
   my $self = shift;
   if (ref $self) {
      return "" unless $self->mastervariantheadwordid;
      return FreelexDB::Globals->master_variant_ref_chars->[0] . $self->printedreference($self->mastervariantheadwordid->headwordid) . FreelexDB::Globals->master_variant_ref_chars->[1];
   }
}

sub postdisplay_mastervariantheadwordid {
   my $self = shift;
   return postdisplay_master_proto($self,'variant');
}

sub validate_mastervariantheadwordid {
   my $self = shift;
   return ($self->masterformat('variant'),$self->masterrecursion('variant'))
}

sub post_update_mastervariantheadwordid {
   my $self = shift;
   my $c = shift;
   my $type = 'variant';

   $self->post_update_makememaster_proto($c, $type);
   return;
}

1;

1;
      

   
     
      
         