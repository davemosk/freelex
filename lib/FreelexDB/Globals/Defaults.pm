package FreelexDB::Globals::Defaults;

use strict;

use Exporter ();
our @ISA = ("Exporter");
our @EXPORT = qw(textarearows textareacols permittedchars punctuation);

sub collate { [ [' ','-'], ['a',"\x{0101}"],["e","\x{0113}"],["h"],["i","\x{012b}"],['k'],['m'],['n'],['ng'],['o',"\x{014d}"],["p"],["r"],["t"],["u","\x{016b}"],["w"],["wh"] ] };

# my $macrons = join("","\x{0100}","\x{0101}","\x{0113}","\x{0112}","\x{012b}","\x{012a}", "\x{014d}","\x{014c}","\x{016b}","\x{016a}");
#my $maoricharslc = 'aeioughkmnprtw';
#my $maorichars = $maoricharslc . uc($maoricharslc) . $macrons . '0123456789';
#my $okchars =  $maorichars . $punctuation . '\s';


sub textarearows { 4 };
sub textareacols { 45 };
#sub permittedchars { $okchars };
sub punctuation { return qq(.;:'"!\\?) . "()" . "," };

sub print_allow_xref { 0 };

sub fckeditor_path { '../static/FCKeditor' }
sub fckeditor_height { 200 };

sub search_default_type { "" }
sub search_select_category { "" }
sub search_select_tag      { "" }

sub qa_levels { 0 };

sub character_hacks { return undef };

1;