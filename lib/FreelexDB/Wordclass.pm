#!/usr/bin/perl;

package FreelexDB::Wordclass;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "wordclass" );

  1;
