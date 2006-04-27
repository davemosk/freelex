#!/usr/bin/perl;

package FreelexDB::Editorialcomment;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "editorialcomment" );
  __PACKAGE__->has_a ( headwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a ( matapunauserid => "FreelexDB::Matapunauser" );
  
  1;
