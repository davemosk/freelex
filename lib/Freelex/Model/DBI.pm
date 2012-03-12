package Freelex::Model::DBI;
        
use base 'Catalyst::Model::DBI';
        
        __PACKAGE__->config(
                dsn           => 'dbi:Pg:dbname=' . FreelexDB::Globals->db_name,
                password      => FreelexDB::Globals->db_password,
                username      => FreelexDB::Globals->db_user,
                options       => { AutoCommit => 1 }
        );
        
        1;