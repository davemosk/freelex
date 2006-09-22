package FreelexDB::Utils::Synonyms;

use strict;

use Exporter ();
our @ISA = ("Exporter");
our @EXPORT = qw(getfamily getslaves mshidhtml masterformat masterrecursion extractfinaldigits ismaster format_master_form_proto postdisplay_master_proto post_update_makememaster_proto);

use FreelexDB::Globals ();
use FreelexDB::Utils::Entities;
use FreelexDB::Utils::Format;
use FreelexDB::Utils::Mlmessage;
mlmessage_init;

sub getfamily {
        my $self = shift;
	my $familytype = shift;  #  synonym or variant or deriving
	my $type = shift || '';  # 'html' or 'print'

	my @sibs;
        my $colname = 'master' . $familytype . 'headwordid';
        my $mshid = $self->get($colname);
        my $id = $self->get("headwordid");
        
	if ($mshid) {
#
# we're a slave synonym, look up the other slaves of our master
#
           @sibs = $self->getslaves($mshid,$familytype,$type,$id);
        }
	elsif ( $id ) {
# we're a master, let's get our own slaves
           @sibs = $self->getslaves($id,$familytype,$type,$id);  # get our slaves
	}
        
        return join(", ",@sibs);
}


sub getslaves {
   my $self = shift;
   my $masterheadwordid = shift;
   my $familytype = shift;         #  synonym, variant, etc
   my $type = shift;               #  html or print
   my $skip = shift;               #  our own id to not print in the list
   my @sibs;

   my $colname = 'master' . $familytype . 'headwordid';

   my $mshidsqlwhere = '(' . $colname . ' = ' . $masterheadwordid. ' OR headwordid = ' . $masterheadwordid . ")";
   $mshidsqlwhere .= ($skip ? ' AND headwordid != ' . $skip : "");
   if ($type eq 'html') {
         $mshidsqlwhere .= ' ORDER BY headword'
   }
   else {
         $mshidsqlwhere .= ' ORDER BY collateseq'
   }

   my @family = FreelexDB::Headword->retrieve_from_sql($mshidsqlwhere);
   if (@family) {
      foreach my $s (@family) {
         my $sibstr;
         if ($type eq 'print') {
            next if $s->headwordid == $skip;
            my $variantno = $s->variantno ? '<sup>' . $s->variantno . '</sup>' : "";
            $variantno .= $s->majsense ? ' (' . $s->majsense . ')' : "";
            $sibstr = $s->headword . $variantno;
         } else {
            $sibstr = mshidhtml($s->headword,$s->headwordid);
         }
         if ($s->headwordid == $masterheadwordid) { $sibstr = '<b>' . $sibstr . '</b>' }
         push @sibs, $sibstr;
      }
   }
   return @sibs;
}
        
sub mshidhtml {
   my $hw = shift;
   my $hwid = shift;
        
   my $result = '';
   $result .= qq{<a href="display?_id=} . $hwid . qq{" onClick="window.open('display?_id='} . $hwid . qq{&_nav=no','editwin', 'toolbar=no, directories=no, location=no, status=yes, menubar=no, resizable=yes, scrollbars=yes, width=700, height=400'; return false">} . entityise(utfise($hw)) . '-' . $hwid . '</a>';
   return $result;
}

sub masterformat {
	my $self = shift;
	my $type = shift || return ();

	my $colname = 'master' . $type . 'headwordid';
        my $t = $self->$colname || return ();
	
	if ($t =~ /(\d+)$/) { # they put in a number or something followed by a number
		my $mshid = $1;
		if ( my $msht = FreelexDB::Headword->retrieve($mshid) ) {
                        $self->set($colname,$mshid)     if $mshid ne $t;
			return ();
		} else {
			$self->set($colname,undef);
			return ('__mlmsg_no_headword_with_id__::'.$mshid);
		}
	}

	else {
        
        	my @choices = FreelexDB::Headword->search( headword => $t);
                if (scalar @choices == 0) {
			$self->set($colname,undef);
			return ('__mlmsg_no_entries_for_headword__::'.$t.'__');
		}
		elsif (scalar @choices == 1) {
			$self->set($colname,$choices[0]->headwordid);
			return ();
		}
		else {
			my @alternatives = ();
			foreach my $choice (@choices) {
				push @alternatives,  mshidhtml($choice->headword, $choice->headwordid);
			}
			$self->set($colname,undef);
			return ('__mlmsg_choose_one_of__::'.join(', ',@alternatives).'__');
		}
	}
}

sub masterrecursion {
	my $self = shift;
	my $type = shift;
	my $colname = 'master' . $type . 'headwordid';
        my $master = $self->$colname || return ();
        my $t = $master->headwordid || return ();
        
        return ()   unless $self->headwordid;  # don't check if this is a new entry
#
# don't allow self-referential circularity
#
        my $mshid = extractfinaldigits($t);
        if ($mshid && ($mshid == $self->headwordid)) {
           $self->set($colname,undef);
           return ('__mlmsg_cant_assign_self_as_master__')
        } 
#
# don't allow assignment of a master to a master
#
	if (ismaster($self,$type)) {
			$self->set($colname,undef);
			return ('__mlmsg_cant_assign_master_because_i_am_a_master__::'.$type.'__');
	}
#
# check to see if the master synonym we're trying to assign is itself a slave
#

	if ($mshid) {
           if (my $ourmaster = FreelexDB::Headword->retrieve($mshid)) {
              if ($ourmaster->$colname) {
                 my $ourmasterhyphen = $ourmaster->headword . '-' . $ourmaster->headwordid;
                 my $ourmastersmasterhyphen = $ourmaster->$colname->headword . '-' . $ourmaster->$colname->headwordid;
                 $self->set($colname,undef);
                 return ('__mlmsg_cant_assign_master_because_master_is_a_slave__::'.$ourmasterhyphen.'::'.$ourmastersmasterhyphen.'::'.$type.'__');
              }
            }
         }
	return ();
}


sub ismaster {
   my $self = shift;
   my $type = shift;
   my $colname = 'master' . $type . 'headwordid';
   
   if (FreelexDB::Headword->search( $colname => $self->headwordid )) {
      return 1
   }
   else {
      return 0
   }
}


sub extractfinaldigits {
   my $x = shift || return;
   (my $digits) = $x =~ /\-?(\d+)$/;
   return $digits;
}

sub format_master_form_proto {
  my $self = shift;
  my $c = shift;
  my $type = shift;
  my $colname = 'master' . $type . 'headwordid';
  my $makemastername = 'MAKEMEMASTER'.$type;
   
   my $masterheadwordstr;
    
   if ($self->$colname) {
      $masterheadwordstr = $self->$colname->headword . '-' . $self->$colname->headwordid
   }
   else { $masterheadwordstr = "" }
      
   my $mstextbox = fltextbox($colname,$masterheadwordstr);
   
   my $msfamily = $self->getfamily($type,'html') || "";

   my $mmchecked = ($c && $c->{request}->{parameters}->{$makemastername}) ? ' CHECKED' : ''; 

   my $makemasterckbox = $msfamily ? qq(<br><input type="checkbox" name="$makemastername" value="1" $mmchecked>) . '&nbsp;' . entityise(mlmessage('make_me_master_'.$type,$c->user_object->{lang})) : ""; 

   return $mstextbox . '<br>' . $msfamily . $makemasterckbox;
}

sub postdisplay_master_proto {
   my $self = shift;
   my $type = shift;
   my $colname = 'master' . $type . 'headwordid';
   
   return unless defined $self->$colname;
   my $mshiddigits = extractfinaldigits($self->$colname) || return;
   $self->set($colname,$mshiddigits);
   return;
}

sub post_update_makememaster_proto {
   my $self = shift;
   my $c = shift;
   my $type = shift;

   my $searchcol = 'master'.$type.'headwordid';
   my $oldmasterval = $self->$searchcol->headwordid;
   my $newmasterval = $self->headwordid;

   my @family = FreelexDB::Headword->search( $searchcol => $oldmasterval );

   foreach my $e (@family) {
      if ($e->headwordid eq $self->headwordid) {
      # if it's us, change ours to blank as we're the new master
         $self->set($searchcol,undef);
         $self->update();
      }
      else {
      # change other slaves to point to us
         $e->set($searchcol,$newmasterval);
         $e->update();
      }
    }

    # change original master to point to us
    my $oldmaster = FreelexDB::Headword->retrieve($oldmasterval);
    $oldmaster->set($searchcol,$newmasterval);
    $oldmaster->update();     

}


1;
