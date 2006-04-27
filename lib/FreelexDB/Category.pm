#!/usr/bin/perl;

package FreelexDB::Category;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "category" );

  1;
