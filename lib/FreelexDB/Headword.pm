#!/usr/bin/perl;

package FreelexDB::Headword;
  
  use FreelexDB::Globals;
  use base 'FreelexDB::Headword::Base';
  use strict;
 
  
  __PACKAGE__->set_up_table( "headword" );
  __PACKAGE__->has_a( owneruserid => "FreelexDB::Matapunauser" );
  __PACKAGE__->has_a( wordclassid => "FreelexDB::Wordclass" );
  __PACKAGE__->has_a( categoryid => "FreelexDB::Category" );
  __PACKAGE__->has_a( domainid => "FreelexDB::Domain" );
  __PACKAGE__->has_a( mastersynonymheadwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a( mastervariantheadwordid => "FreelexDB::Headword" );
  __PACKAGE__->has_a( allocateduserid => "FreelexDB::Matapunauser");
  __PACKAGE__->has_a( updateuserid => "FreelexDB::Matapunauser");
  __PACKAGE__->has_a( createuserid => "FreelexDB::Matapunauser");  
  __PACKAGE__->has_a( examplesourceid => "FreelexDB::Examplesource");
  __PACKAGE__->has_a( borrowedlangid => "FreelexDB::Borrowedlang") ;
  __PACKAGE__->has_many( editorialcomment => "FreelexDB::Editorialcomment", {order_by => "editorialcommentdate DESC"}); 
  __PACKAGE__->has_many( headwordtags => "FreelexDB::Headwordtag" );
  
  __PACKAGE__->columns(TEMP => qw/neweditorialcomment/);
  
  __PACKAGE__->set_sql( count_all => "SELECT COUNT(*) FROM __TABLE__");
  __PACKAGE__->set_sql( count_distinct => "SELECT COUNT(DISTINCT %s) from __TABLE__" );
  __PACKAGE__->set_sql( count_updated_today => "SELECT COUNT(headword) AS hw FROM headword WHERE createdate > 'today' OR updatedate > 'today'" );
                   
   
  __PACKAGE__->use_headword_fields();


  1;
