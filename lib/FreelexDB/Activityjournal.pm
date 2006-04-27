#!/usr/bin/perl;

package FreelexDB::Activityjournal;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "activityjournal" );

  1;
