#!/usr/bin/perl;

package FreelexDB::Tag;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "tag" );

  1;
