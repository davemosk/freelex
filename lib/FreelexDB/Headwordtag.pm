#!/usr/bin/perl;

package FreelexDB::Headwordtag;
  use base 'FreelexDB::DBI';
  use strict;

  __PACKAGE__->set_up_table( "headwordtag" );
  __PACKAGE__->has_a ( headwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a ( tagid => "FreelexDB::Tag" );
  
  1;
