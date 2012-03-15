package Freelex::Controller::Root;

use base qw/Catalyst::Controller/;
use strict;

    __PACKAGE__->config( namespace => '');


sub default : Private {
    my ( $self, $c ) = @_;

# default method if no path specified
     $c->forward('/main/freelex');
     $c->detach('Freelex::View::TT');
#    $c->response->body( "Sorry, we can't service your request." );
#    $c->response->status(404);
}



1;
