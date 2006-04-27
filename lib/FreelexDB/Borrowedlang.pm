#!/usr/bin/perl;

package FreelexDB::Borrowedlang;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "borrowedlang" );

  1;
