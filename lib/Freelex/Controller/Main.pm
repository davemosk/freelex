package Freelex::Controller::Main;

use base qw/Catalyst::Controller/;
use strict;

use Data::Dumper;
use FreelexDB::Utils::Entities;
freelex_entities_init;

use FreelexDB::Utils::Mlmessage;
mlmessage_init;

sub begin : Private {
  my ( $self, $c ) = @_;
  unless ($c->user) { 
     $c->request->action(undef);
     $c->detach("/login/login");
     $c->stash->{dont_render_template} = 1; 
  } else {
     $c->stash->{system_name} = entityise(FreelexDB::Globals->system_name);
  }
}

sub freelex : Global {
   my ( $self, $c ) = @_;
      FreelexDB::Matapunauser->commit;  # get rid of any in-train transactions ...
      my $uname = $c->user->get('matapunauser') . ' - ' . $c->user->get('matapunauserfullname');
      $c->stash->{message} = $c->request->parameters->{_message};
      $c->stash->{motd} = entityise(mlmessage('welcome_to_matapuna',$c->user->get('lang'),$c->stash->{system_name}));
      $c->stash->{loggedinas} = entityise(mlmessage('logged_in_as',$c->user->get('lang'),$uname));

      $c->stash->{workq} = "";
      my $wqnum;
      eval { $wqnum = FreelexDB::Headword->sql_count_workq($c->user->get('matapunauserid'))->select_val } ;	
      if (!$@ && defined $wqnum && $wqnum) {
         $c->stash->{workq} = entityise(mlmessage('workq_count',$c->user->get('lang'),$wqnum))
      }

      my $updated_today = FreelexDB::Headword->sql_count_updated_today->select_val;
      my $count_hw = FreelexDB::Headword->sql_count_all->select_val;
      my $distinct = FreelexDB::Headword->sql_count_distinct('headword')->select_val;
      $c->stash->{entrycount} = entityise(mlmessage('there_are_n_entries',$c->user->get('lang'),$distinct,$count_hw,$updated_today));
      $c->stash->{support} = entityise(mlmessage('for_support',$c->user->get('lang'),FreelexDB::Globals->support_contact_name,FreelexDB::Globals->support_contact_email,FreelexDB::Globals->support_contact_phone));

      $c->stash->{template} = 'welcome.tt';

}

sub end : Private {
   my ( $self, $c ) = @_;
   $c->forward('Freelex::View::TT')   unless $c->{'dont_render_template'};
   die "You requested a dump"   if ((defined $c->request->params->{'dump'}) && $c->request->params->{'dump'} eq 1);
}

1;
