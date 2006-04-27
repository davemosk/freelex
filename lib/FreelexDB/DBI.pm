#!/usr/bin/perl -w

package FreelexDB::DBI;
use base "Class::DBI::Pg";

use strict;

my $db_name = FreelexDB::Globals->db_name;
my $db_user = FreelexDB::Globals->db_user;
my $db_password = FreelexDB::Globals->db_password;

__PACKAGE__->connection("dbi:Pg:dbname=$db_name",$db_user,$db_password, {pg_enable_utf8 => 1, PrintError => 1});

1;