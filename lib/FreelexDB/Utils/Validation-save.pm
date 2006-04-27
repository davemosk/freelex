package FreelexDB::Utils::Validation;

use strict;

use Exporter ();
our @ISA = ("Exporter");
our @EXPORT = qw(isblank orthography containspunctuation containsuc notnumeric definingvocab);
  
sub isblank {
   my $self = shift;
   my $col = shift;
   my $t = $self->$col || "";
   if ($t =~ /^\s*$/s) { return ('__mlmsg_is_blank__') }
   else { return () }
}

sub orthography {
	my $self = shift;
	my $col = shift;
        my $t = $self->$col  || return ();
        my $pc = '^[' . FreelexDB::Globals->permittedchars() . '\-]*$';
	if ($t =~ /$pc/o) { return () }
	else { return ('__mlmsg_has_funny_characters__') }
}

sub containspunctuation {
	my $self = shift;
        my $col = shift;
	my $t = $self->$col  || return ();
	my $punctuation = '[' . FreelexDB::Globals->punctuation() . ']';
	if ($t =~ /$punctuation/o) { return  ('__mlmsg_has_punctuation_characters__') }
	else { return () }
}

sub containsuc {
	my $self = shift;
        my $col = shift;
	my $t = $self->$col;
	if ($t eq lc($t)) { return () }
	else { return ('__mlmsg_has_uc_characters__') }
}

sub notnumeric {
	my $self = shift;
        my $col = shift;
	my $t = $self->$col || return ();
	if ($t !~ /^\s*\d*\s*$/) { return ('__mlmsg_non_numeric__') }
	else { return () }
}

sub definingvocab {
	my $self = shift;
        my $col = shift;
        my $t = lc($self->$col);
	$t =~ s/[\d|\_]+//sg; # get rid of digits and underscores
	$t =~ s/[[:punct:]]+//sg; # get rid of puctuation
	my @words = split(/\W/,$t) ; # get an array of words;
	return unless @words;
	my %whashnotdv;
	my %whashundef;
        my @warns = ();
#
# construct a list of words
#        
	foreach my $w (@words) { $whashnotdv{$w} = 1; $whashundef{$w} = 1 };
# db-quote them, and get rid of any dupes
        @words = map { FreelexDB::DBI->db_Main->quote($_) } keys %whashundef;
       
	my $whereclause_headword_in_db = "headword=" . join(" OR headword=",@words) ;
        foreach my $hw (FreelexDB::Headword->retrieve_from_sql($whereclause_headword_in_db)) {
           delete $whashundef{$hw->headword};
        }
        if (scalar %whashundef) { push @warns, '__mlmsg_undefined_words__' . ': ' . join(' ', sort keys %whashundef); }

#
# don't recheck the undefined words ...
#
        foreach my $uw (keys %whashundef) { 
           delete $whashnotdv{$uw};  
        }     

        return @warns    unless %whashnotdv;
        
        @words = map { FreelexDB::DBI->db_Main->quote($_) } keys %whashnotdv;

        my $whereclause_headword_in_defining_vocab = "definingvocab='t' AND ( headword=" . join(" OR headword=",@words) . ")";
        foreach my $hw (FreelexDB::Headword->retrieve_from_sql($whereclause_headword_in_defining_vocab)) {
# cross these words of lists of undefined words and words not in defining vocab
         delete $whashnotdv{$hw->headword};
       }
        if (scalar %whashnotdv) { push @warns, '__mlmsg_words_not_in_defining_vocab__' . ': ' . join(' ', sort keys %whashnotdv); }

        
	return @warns;
}

 

1;
