#!/usr/bin/perl;

package FreelexDB::Domain;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "domain" );

  1;
