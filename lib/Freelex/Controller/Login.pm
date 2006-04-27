package Freelex::Controller::Login;

use base qw/Catalyst::Controller/;
use strict;

use URI::Escape qw(uri_escape_utf8);

use FreelexDB::Utils::Mlmessage;
mlmessage_init;

use FreelexDB::Utils::Entities;
freelex_entities_init;

sub login : Regex('login$') {
   my ( $self, $c ) = @_;
   my $date = localtime;
   $c->stash->{template} = 'login.tt';
   $c->stash->{systemname} = FreelexDB::Globals->system_name;
   if ($c->request->params->{username}) {
      $c->login($c->request->params->{username}, $c->request->params->{password} );
 
      if ($c->request->{user}) {
        #
  # Add a row to the activity journal
  #
        FreelexDB::Activityjournal->insert( {
           activitydate => $date,
           matapunauserid => $c->user_object->matapunauserid,
           verb => 'login',
           object => $c->user_object->matapunauserfullname,
           description => $c->request->headers->as_string
           });
           FreelexDB::Activityjournal->dbi_commit;  
   
            $c->detach('/main/freelex');
      }  
      else { 
         $c->stash->{message} = "Login failed"; 
          FreelexDB::Activityjournal->insert( {
              activitydate => $date,
              matapunauserid => $c->request->user,
              verb => 'loginfail',
              object => '',
              description => $c->request->headers->as_string
           });
          FreelexDB::Activityjournal->dbi_commit;  

      }
   }
   else { $c->stash->{message} = "Please enter your user details" }
}


sub logout : Regex('logout$') {
   my ( $self, $c ) = @_;
   my $date = localtime;
   $c->stash->{template} = 'login.tt';
   $c->stash->{message} = 'See ya later';
   FreelexDB::Activityjournal->insert( {
      activitydate => $date,
      matapunauserid => $c->user_object->matapunauserid,
      verb => 'logout',
      object => '',
      description => ''
   });
   FreelexDB::Activityjournal->dbi_commit;    
   $c->logout;
   $c->delete_session("logged out");
}


sub end : Private {
   my ( $self, $c ) = @_;
   $c->forward('Freelex::View::TT')   unless $c->{'dont_render_template'};
   die "You requested a dump"   if ((defined $c->request->params->{'dump'}) && $c->request->params->{'dump'} eq 1);
}

1;
