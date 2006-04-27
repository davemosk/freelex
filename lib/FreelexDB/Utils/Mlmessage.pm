
package FreelexDB::Utils::Mlmessage;
require Exporter;
our @ISA = ("Exporter");
our @EXPORT = qw($mlmessages mlmessage_init mlmessage mlmessage_block xlateit);

use strict;
use FreelexDB::Globals;
use FreelexDB::Utils::Entities;
freelex_entities_init;

our $mlmessages;

sub mlmessage_init {
#
# load multilingual message table
#
        return if defined($mlmessages);

	open(MESSAGES,FreelexDB::Globals->mlmessage_file_location) || die "Can't open multilingual messages: $!";
	binmode MESSAGES,":utf8";

	my $msgheader = <MESSAGES>; #  first line has languages
	chomp $msgheader;
	next if $msgheader =~ /^\#/;
	my @langs = split("\011",$msgheader);

	while (<MESSAGES>) {
		chomp;
		my @line = split("\011");
		my $id = shift @line;
		$mlmessages->{$id} = {};
		for (my $i = 1; $i <= $#langs; $i++) {
			$mlmessages->{$id}->{$langs[$i]} = shift @line;
		}
	}

	close MESSAGES;
}

sub mlmessage {
	my $messageid = shift;
        my $lang = shift || 'en';
	my @args = (@_, '**overflow in mlmessage**', '**overflow in mlmessage**','**overflow in mlmessage**');
	my $result = $mlmessages->{$messageid}->{$lang} || $mlmessages->{$messageid}->{'en'} || $messageid;
	$result =~ s/__(\d+)__/$args[$1-1]/g;
	return $result;
}

sub mlmessage_block {
        my $block = shift;
        my $lang = shift || 'en';
        $block =~ s/__mlmsg_(.+?)(?:__(?:\:\:(.+))*)?__/&mlmessage($1,$lang,decode_args($2))/ge;
        return $block;
}

sub decode_args {
        my $string = shift || return;
        return split('::',$string);
}

sub xlateit {
   my $str = shift  || return;
   my $lang = shift || "en";
   my $ua = shift || "";
   my $form = shift || "";
   return entityise(mlmessage_block($str,$lang),$ua,$form);
}
	
	
	
	
1;
