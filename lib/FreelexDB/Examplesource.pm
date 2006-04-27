#!/usr/bin/perl;

package FreelexDB::Examplesource;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "examplesource" );

  1;
