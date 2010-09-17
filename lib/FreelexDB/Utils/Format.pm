package FreelexDB::Utils::Format;

use strict;
use Data::Dumper;

use Exporter ();
our @ISA = ("Exporter");
our @EXPORT = qw(fltextarea fltextbox flcheckbox fldropdown getfieldnamefromformatsub makecheckboxtable hyphenated flfckeditor trim sentencise printedreference);

use FreelexDB::Globals ();
use FreelexDB::Utils::Entities;

FreelexDB::Utils::Entities->freelex_entities_init;

  
sub fltextarea {
   my $name = shift;
   my $val = shift;
   $val = entityise($val);

   my $rows = shift || FreelexDB::Globals->textarearows;
   my $cols = shift || FreelexDB::Globals->textareacols;
   my $flt = '<textarea name="'.$name.'" id="'.$name.'" rows="'.$rows.'" cols="'.$cols.'">'.$val.'</textarea>';
   return $flt;
}

sub fltextbox {
   my $name = shift;
   my $val = shift;
   $val = entityise($val);

   my $cols = shift || FreelexDB::Globals->textareacols;
   my $flt = '<input type="text" name="'.$name.'" size="'.$cols.'" value="'.$val.'">';
   return $flt;
}

sub flcheckbox {
   my $name = shift;
   my $val = shift;
   $val = entityise($val);
   my $s = shift || "";
   my $checked = $s ? " CHECKED" : "";

   my $flt = '<input type="checkbox" name="'.$name.'" value="'.$val.'"' . $checked . '>' .
             '<input type="hidden" name="_process_' . $name . '" value="1">';
   return $flt;
}



sub fldropdown {
#
# Construct an HTML multiple-choice dropdown box from a table.  Typically used for selecting
# a user or part of speech etc. from a normailsed table.
#
	my $table = shift;
	my $valuecol = shift;
	my $labelcol = shift;
	my $default = shift;
	my $nulllabel = shift;
        my $multiple = shift;
        
        my @result;
        my %ddvalues;

	$default = ""   if(!defined($default));
        
        if (defined $nulllabel) {
	   $ddvalues{$nulllabel} = 'dropdown-first';
	}
       
        my $tableclass = "FreelexDB::" . ucfirst($table);
        
        my $i = $tableclass->retrieve_all;
        
        while (my $row = $i->next) {
           my $l = $row->$labelcol;
           $ddvalues{$l} = $row->$valuecol;
        }
        
        $multiple = $multiple ? ' MULTIPLE SIZE="' . $multiple . '"' : "";
        
        push @result, '<select name="' . $valuecol . '"' . $multiple . '>';
        
        foreach my $label (sort { lc $a cmp lc $b } keys %ddvalues) {
           my $selected = "";
           if ($default) {
              if (ref $default) {
                 foreach my $e (@$default) {
                    if ($e eq $ddvalues{$label}) {
                       $selected = 'selected';
                       last;
                    }
                 }
              }
              else {
                 $selected = 'selected'   if ($default eq $ddvalues{$label})
              }
           }
           
           push @result, '<option ' . $selected . ' value="' . $ddvalues{$label} . '">' . entityise(stripmacrons($label),'form') . "</option>";
        }
        
        push @result, "</select>";
        
        return join("\n",@result);
   }

sub getfieldnamefromformatsub  {
   my @caller = caller(1);
   my $subname = $caller[3];
   (my $fieldname) = $subname =~ /\:\:format_(.*?)(?:_[^_]+)?$/;
   return $fieldname;
}

sub makecheckboxtable {
	my $self = shift;
	my $type = shift || return;
	my $tvalues = shift || return;
	if ($tvalues) {
		my $wcsrnum = 0;
		my @wcsrtable = ();
		push @wcsrtable, '<input type="hidden" name="_process_' . $type . '" value="1">';
		push @wcsrtable, '<table>';
		foreach my $wcsr (sort keys %{$tvalues}) {
			$wcsrnum++;
			push @wcsrtable, '<tr>'     if $wcsrnum % 3 == 1;
			my $wcsrsym = $wcsr;
                        my $wcsrid = $tvalues->{$wcsr};
			my $wcschecked;
			if (ref $self && (defined ($self->get($type.$wcsrid)) && (($self->get($type.$wcsrid) eq '1') || ($self->get($type.$wcsrid) eq 't')))) {
				$wcschecked = ' CHECKED'
			} else {
				$wcschecked = ''
			}
			push @wcsrtable,'<td><input type="checkbox" name="' . $type . $wcsrid . '" value="1"' . $wcschecked . '></td><td>' . $wcsrsym . '&nbsp;&nbsp;&nbsp;</td>';
			push @wcsrtable, '</tr>'    if $wcsrnum % 3 == 0;
		}
		push @wcsrtable, '</tr>'    unless $wcsrnum % 3 == 0;
		push @wcsrtable, '</table>';
		return join("",@wcsrtable);
	}
}

sub flfckeditor {
   my $col = shift;
   my $val = shift;
   my $height = shift || FreelexDB::Globals->fckeditor_height;
   my $path = FreelexDB::Globals->fckeditor_path;
   my $nr = '\n\r';
   my $rn = '\r\n';
   my $prefix = 'R' . int(rand(10000));
 
#   $val = s/\n\r/$nr/sg;
#   $val = s/\r\r/$rn/sg;

   $val =~ s/\'/\&#39/sg;
   $val =~ s/<div><\/div>//sg;
   $val =~ s/\n\r<div>/<br \/><div>/sg;
   $val =~ s/\r\n<div>/<br \/><div>/sg;
   $val =~ s/\n\r//sg;
   $val =~ s/\r\n//sg;
   $val =~ s/<\/div>(<br \/>)+<div>/<\/div><div>/sg;
   $val =~ s/(<br \/>)+/<br \/>/sg;

   
#   $val =~ s/(<br(\s\/)?>)?\n\r/<br \/>/sg;
#   $val =~ s/(<br(\s\/)?>)?\r\n/<br \/>/sg;

   return <<EOM
<script type="text/javascript">
<!--
var sBasePath = '$path/' ;

var ${prefix}FCKeditor = new FCKeditor( '$col' ) ;
${prefix}FCKeditor.ToolbarSet = 'Freelex' ;
${prefix}FCKeditor.BasePath	= sBasePath ;
${prefix}FCKeditor.Height	= $height ;
${prefix}FCKeditor.Value	= '$val' ;
${prefix}FCKeditor.Create() ;
//-->
</script>
EOM
;
}


sub hyphenated {
   my $self = shift;
   return $self->headword . '-' . $self->headwordid
}


sub trim {
#
# Get rid of any leading or trailing spaces on a string
#
  my $x = shift || return "";
  $x =~ s/^\s+//;
  $x =~ s/\s+$//;
  return $x;
}

sub sentencise {
#
# Capitailse the first letter of a string, and add a full stop if required
#
	my $st = shift || return;
	$st = trim(ucfirst($st));
	$st .= '.'    unless $st =~ /\p{IsPunct}$/;
	return $st;
}


sub printedreference {
   my $self = shift;
   my $refhid = shift || die "printedreference: no refhid supplied";
   my $referred = FreelexDB::Headword->retrieve($refhid);
   my $result = $referred->headword;
   if ($referred->variantno) {
      $result .= '<sup>' . $referred->variantno . '</sup>';
   }
   if ($referred->subentry) {
      $result .= ' (' . $referred->subentry . ') ';
   }
   elsif ($referred->majsense) {
      $result .= ' (' . $referred->majsense . ')';
   }
   return $result;
}


1;
