#!/usr/bin/perl;

package FreelexDB::Matapunauser;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "matapunauser" );
  __PACKAGE__->has_a( workflowschemeid => "FreelexDB::Workflowscheme" );
  
  1;
