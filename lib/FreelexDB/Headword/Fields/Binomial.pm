sub format_binomial_html_type { '<tt>' }
sub format_binomial_form_type { 'textbox' }

sub validate_binomial {
   my $self = shift;
   my $t = $self->binomial;
   return ()    unless $t;
   if ($t !~ /\w+\s+\w+/) { return ('__mlmsg_too_few_for_binomial__') }
   else { return () }
}

1;
      

   
     
      
         