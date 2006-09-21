#!/usr/bin/perl;

package FreelexDB::Lifecycle;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "lifecycle" );

  1;
