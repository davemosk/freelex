#!/usr/bin/perl;

package FreelexDB::Hwarchive;
  use base 'FreelexDB::Headword::Base';
  use strict;

  __PACKAGE__->set_up_table( "hwarchive" );
  __PACKAGE__->has_a( owneruserid => "FreelexDB::Matapunauser" );
  __PACKAGE__->has_a( wordclassid => "FreelexDB::Wordclass" );
  __PACKAGE__->has_a( categoryid => "FreelexDB::Category" );
  __PACKAGE__->has_a( domainid => "FreelexDB::Domain" );
  __PACKAGE__->has_a( mastersynonymheadwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a( mastervariantheadwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a( updateuserid => "FreelexDB::Matapunauser" );
  __PACKAGE__->has_a( createuserid => "FreelexDB::Matapunauser" );  
  __PACKAGE__->has_a( examplesourceid => "FreelexDB::Examplesource" );
  __PACKAGE__->has_a( borrowedlangid => "FreelexDB::Borrowedlang" );
  __PACKAGE__->has_a( qastatus1 => "FreelexDB::Qastatus" );
  __PACKAGE__->has_a( qastatus2 => "FreelexDB::Qastatus" );
  __PACKAGE__->has_a( allocateduserid => "FreelexDB::Matapunauser" );
  __PACKAGE__->has_a( sentbyuserid => "FreelexDB::Matapunauser" );

  1;
