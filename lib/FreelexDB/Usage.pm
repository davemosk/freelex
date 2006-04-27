#!/usr/bin/perl;

package FreelexDB::Usage;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "usage" );

  1;
