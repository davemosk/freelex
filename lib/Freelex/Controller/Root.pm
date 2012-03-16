package Freelex::Controller::Root;

use base qw/Catalyst::Controller/;
use strict;

    __PACKAGE__->config( namespace => '');


sub auto : Private {
     my ( $self, $c ) = @_;
     if ($c->request->address =~ /^127\.0\./ || $c->request->headers->{"x-forwarded-server"} =~ /^127\.0\./ ) {
         return 1;
     }
     else {
         $c->response->status( 404 );
         $c->stash->{template} = '404.tt';
         $c->response->headers->header( 'X-Catalyst' => undef );
         $c->detach('Freelex::View::TT');
         return 0;
      }
}


sub default : Private {
    my ( $self, $c ) = @_;

# default method if no path specified

     if ($c->user) {
        $c->forward('/main/freelex');
     }
     else {
        $c->forward('/login/login');
     }
     $c->detach('Freelex::View::TT');
#    $c->response->body( "Sorry, we can't service your request." );
#    $c->response->status(404);
}



1;
