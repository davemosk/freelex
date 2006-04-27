#!/usr/bin/perl;

package FreelexDB::Workflowscheme;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "workflowscheme" );

  1;
