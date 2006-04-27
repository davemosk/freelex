#!/usr/bin/perl;

package FreelexDB::Qastatus;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "qastatus" );
  
  1;
