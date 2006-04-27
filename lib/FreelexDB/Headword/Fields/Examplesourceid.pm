sub default_examplesourceid { 1 };

sub format_examplesourceid_plain {
   my $self = shift;
   return "" unless (ref $self && defined $self->examplesourceid) && $self->examplesourceid;
   return $self->examplesourceid->symbol;
}

sub format_examplesourceid_form {
   my $self = shift;
   my $field = getfieldnamefromformatsub();
  
   my $val = (ref $self && defined $self->$field) ? $self->$field->$field : default_examplesourceid;

   my $dd = fldropdown('examplesource','examplesourceid','examplesource',$val);
   return $dd;
}

sub validate_examplesourceid {
   my $self = shift;

   return ($self->have_example_but_no_source(), $self->have_source_but_no_example())
}

sub have_example_but_no_source {
   my $self = shift;
   if ($self->example && (!defined $self->examplesourceid || !$self->examplesourceid || $self->examplesourceid eq 1)) { return ('__mlmsg_example_has_no_source__') }
   else { return () };
}

sub have_source_but_no_example {
   my $self = shift;
   return ()  if ((defined $self->example) && $self->example);
   return ()  unless ((defined $self->examplesourceid) && $self->examplesourceid && ($self->examplesourceid != 1));
   return ('__mlmsg_have_source_but_no_example__');
}
   

1;
      

   
     
      
         