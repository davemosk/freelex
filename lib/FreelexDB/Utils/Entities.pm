use strict;

package FreelexDB::Utils::Entities;
require Exporter;
our @ISA = ("Exporter");
our @EXPORT = qw(freelex_entities_init entityise utfise stripmacrons collatestring highestchar 
		 %entitiestoutf $macrons %utftoentities %umlautentitiestoutf %utftoumlautentities
                 %doubletstoutf %isotoutf %utftoiso %utfumlauttomacron %utfmacrontoumlaut %plainvowelstomacrons %macronstoplainvowels $plainvowels);

our %entitiestoutf;
our $macrons;
our %utftoentities;
our %umlautentitiestoutf;
our %utftoumlautentities;
our %doubletstoutf;
our %isotoutf;
our %utftoiso;
our %utfumlauttomacron;
our %utfmacrontoumlaut;
our %plainvowelstomacrons;
our %macronstoplainvowels;
our $plainvowels;
our @collate;
our %collatesubs;
our $collatepatstring;
our %seccollatesubs;
our $seccollatepatstring;

use HTML::Entities qw(:DEFAULT encode_entities_numeric);
use Encode;
use Data::Dumper;

sub freelex_entities_init {
   return if defined(%entitiestoutf);
   
	%entitiestoutf = ( 	'&#257;' => "\x{0101}",
				'&#256;' => "\x{0100}",
				'&#275;' => "\x{0113}",
				'&#274;' => "\x{0112}",
				'&#299;' => "\x{012b}",
				'&#298;' => "\x{012a}",
				'&#333;' => "\x{014d}",
				'&#332;' => "\x{014c}",
				'&#363;' => "\x{016b}",
				'&#362;' => "\x{016a}",
				'&#699;' => "\x{02bb}"   );

	$macrons =  join('',values %entitiestoutf );

	%utftoentities =  reverse %entitiestoutf ;

	%umlautentitiestoutf = (	'&#228;' => "\x{0101}",
				'&#196;' => "\x{0100}",
				'&#235;' => "\x{0113}",
				'&#203;' => "\x{0112}",
				'&#239;' => "\x{012b}",
				'&#207;' => "\x{012a}",
				'&#246;' => "\x{014d}",
				'&#214;' => "\x{014c}",
				'&#252;' => "\x{016b}",
				'&#220;' => "\x{016a}",
				'&#255;' => "\x{02bb}"   );

	%utftoumlautentities = reverse %umlautentitiestoutf;


#	%doubletstoutf = ( 	'#a' => "\x{0101}",
#				'#A' => "\x{0100}",
#				'#e' => "\x{0113}",
#				'#E' => "\x{0112}",
#				'#i' => "\x{012b}",
#				'#I' => "\x{012a}",
#				'#o' => "\x{014d}",
#				'#O' => "\x{014c}",
#				'#u' => "\x{016b}",
#				'#U' => "\x{016a}",
#				'\[a' => "\x{0101}",
#				'\[A' => "\x{0100}",
#				'\[e' => "\x{0113}",
#				'\[E' => "\x{0112}",
#				'\[i' => "\x{012b}",
#				'\[I' => "\x{012a}",
#				'\[o' => "\x{014d}",
#				'\[O' => "\x{014c}",
#				'\[u' => "\x{016b}",
#				'\[U' => "\x{016a}"
#				);
        
	if (defined FreelexDB::Globals->character_hacks) {
        	%doubletstoutf = %{FreelexDB::Globals->character_hacks}
        }
        else {                 
	        %doubletstoutf = ();
        }

	%isotoutf = (
				"\xE4" => "\x{0101}",
				"\xC4" => "\x{0100}",
				"\xEB" => "\x{0113}",
				"\xCB" => "\x{0112}",
				"\xEF" => "\x{012b}",
				"\xCF" => "\x{012a}",
				"\xF6" => "\x{014d}",
				"\xD6" => "\x{014c}",
				"\xFC" => "\x{016b}",
				"\xDC" => "\x{016a}",
				"\xFF" => "\x{02bb}"   );

	%utftoiso = reverse %isotoutf;

	%utfumlauttomacron = (
				"\x{00E4}" => "\x{0101}",
				"\x{00C4}" => "\x{0100}",
				"\x{00EB}" => "\x{0113}",
				"\x{00CB}" => "\x{0112}",
				"\x{00EF}" => "\x{012b}",
				"\x{00CF}" => "\x{012a}",
				"\x{00F6}" => "\x{014d}",
				"\x{00D6}" => "\x{014c}",
				"\x{00FC}" => "\x{016b}",
				"\x{00DC}" => "\x{016a}",
				"\x{00FF}" => "\x{02bb}"   );

	%utfmacrontoumlaut = reverse %utfumlauttomacron;


	%macronstoplainvowels = (  "\x{0101}" => 'a',
				"\x{0100}" => 'A',
				"\x{0113}" => 'e',
				"\x{0112}" => 'E',
				"\x{012b}" => 'i',
				"\x{012a}" => 'I',
				"\x{014d}" => 'o',
				"\x{014c}" => 'O',
				"\x{016b}" => 'u',
				"\x{016a}" => 'U',
                                "\x{02bb}" => ''
                                                           );

	$plainvowels = join("",values %plainvowelstomacrons);

#	@collate = (['a',"\x{0101}"],["e","\x{0113}"],["h"],["i","\x{012b}"],['k'],['m'],['n'],['ng'],['o',"\x{014d}"],["p"],["r"],["t"],["u","\x{016b}"],["w"],["wh"]);

	my $i = 1;  # primary collate
	foreach my $c1 (@{FreelexDB::Globals->collate()}) {
		my $priseqchar = sprintf("%03d",$i);
		foreach my $c2 (@$c1) {
		        my $secseqchar = sprintf("%03d",$i++);
			if ($c2 eq ' ' || $c2 eq '-' || $c2 eq '.') {
				$collatesubs{$c2} = ""; # ignore these in primary sort
			} else {
				$collatesubs{$c2} = $priseqchar
			}
			$seccollatesubs{$c2} = $secseqchar;
			my $capsecseqchar = sprintf("%03d",$i++);
			$seccollatesubs{uc($c2)} = $capsecseqchar;  # caps come after lowers
			
		}
	}
        
	$collatepatstring = '^(' . join('|', reverse sort {length $a <=> length $b} keys %collatesubs) . ')';
	$seccollatepatstring = '^(' . join('|', reverse sort {length $a <=> length $b} keys %seccollatesubs) . ')';

}

sub highestchar {
   my $collate = FreelexDB::Globals->collate();
   my $chararray = pop @{$collate};
   my $hc = shift @{$chararray};
   return $hc;
}

sub entityise {
#
# Turn UTF into nice HTML entities
#
  my $x = shift || return "";
  my $context = shift || "";
  my $eua = $ENV{'HTTP_USER_AGENT'} || "";

  # change 'smart' apostrophies to normal ones
  $x =~ s/\x{2018}/\'/g;
  $x =~ s/\x{2019}/\'/g;

  foreach my $dub (keys %doubletstoutf) {
	$x =~ s/$dub/$doubletstoutf{$dub}/g;
  }

#if ($context eq 'form') {
if (($context eq 'form') && ($eua =~ /MSIE.+Mac_/)) {
#
#  Mac Hack Attack - there seems to be a problem on Mac IE where macron entities are not
#  properly displayed.  For these guys, we do umlauts instead.
#

      foreach my $utfi (keys %utftoumlautentities) {
#        $x =~ s/$utfi/$utftoumlautentities{$utfi}/g;
	$x =~ s/$utfi/$utftoumlautentities{$utfi}/g;
     }
  }
  else {
	foreach my $utf (keys %utftoentities) {
	$x =~ s/$utf/$utftoentities{$utf}/g;
	}
  }

$x = encode_entities_numeric($x,"\x{80}-\x{fa00}");

  return $x;
}

sub utfise {
#
# translate funny representations to utf
# currently handles:
# - "doublets" = #a #e etc
# - umlauts (both iso-8859-1 and UTF)
# - HTML entities
#
  my $x = shift || return "";

  eval {Encode::is_utf8($x,1)};
  if ($@ || !Encode::is_utf8($x)) {
     $x = Encode::decode("utf8", $x);
  }

#  $x = decode_entities($x);

  foreach my $entity (keys %entitiestoutf) {
     $x =~ s/$entity/$entitiestoutf{$entity}/g;
  }
  foreach my $dub (keys %doubletstoutf) {
     $x =~ s/$dub/$doubletstoutf{$dub}/g;
  }

  foreach my $utfumlaut (keys %utfumlauttomacron) {
     $x =~ s/$utfumlaut/$utfumlauttomacron{$utfumlaut}/g;
  }

  foreach my $umlaut (keys %umlautentitiestoutf) {
     $x =~ s/$umlaut/$umlautentitiestoutf{$umlaut}/g;
  }


  return $x;
}
use Data::Dumper;
sub stripmacrons {
	my $str = shift;
        $str = utfise($str);
	$str =~ s/([$macrons])/$macronstoplainvowels{$1}/g;
	return $str;
}

sub collatestring {
	my $str3 = shift;
	$str3 .= ' ';
	my $str2 = lc $str3;
	my $str = $str2;
        $str =~ s/^\s*\([^\)]*\)\s*//; # get rid of anything in parenthesis on the left of the string
	$str =~ tr/,()//d;
	my @priresult = ();
	my @secresult = ();
	my @triresult = ();
	while ($str =~ s/$collatepatstring//oi) {
		push @priresult,$collatesubs{$1};
	}
	if ($str) { print STDERR "collatestring error: residual characters in " . $str3 . ": " . $str }
	my $primary = join("",@priresult);
	while ($str2 =~ s/$seccollatepatstring//oi) {
		push @secresult,$seccollatesubs{$1};
	}
	my $secondary = join("",@secresult);
	while ($str3 =~ s/$seccollatepatstring//o) { 
	        push @triresult,$seccollatesubs{$1};
	}
	my $tertiary = join("",@triresult);
	return $primary . '000' . $secondary . '000' . $tertiary;
}

1;

