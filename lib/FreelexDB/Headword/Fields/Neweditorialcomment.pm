sub format_neweditorialcomment_form {
   my $self = shift;
   return fltextarea("neweditorialcomment","")   unless ref $self;
   my $val = $self->get("neweditorialcomment") || "";
   my @result = ();
   push @result, (fltextarea("neweditorialcomment",$val));
   foreach my $ec ($self->editorialcomment) {
      my $ecd = $ec->editorialcommentdate || "";
      my $mu = $ec->matapunauserid->matapunauser || "";
      my $ecc = $ec->editorialcomment || "";
      push @result, '<b>'. $ecd . ' ' . $mu . '</b> ' . $ecc
   }
   return join("<br>\n",@result);
} 

sub post_update_neweditorialcomment {
   my $self = shift;
   my $c = shift || return;
   return  unless my $newec = $c->{request}->{parameters}->{neweditorialcomment};
   my $user = $c->{'stash'}->{'matapunauserid'};
   my $date = $c->{'stash'}->{'date'};
   my $headwordid = $self->headwordid;
   my $ec = $newec;
   $self->add_to_editorialcomment( { headwordid => $headwordid, matapunauserid => $user, 'editorialcommentdate' => $date, editorialcomment => $ec } );
   return;
};



1;