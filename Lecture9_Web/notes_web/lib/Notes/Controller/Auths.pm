package Notes::Controller::Auths;

use strict;
use warnings;
use 5.020;

use Mojo::Base 'Mojolicious::Controller';


sub create {
    my ($self) = @_;

    my $username    = $self->param('username');
    my $password    = $self->param('password');

    my $user = Notes::Model::User->select({username => $username, password=>$password});

    if ( $username && $user->{id} ) {
        $self->session(
            user_id => $user->{id},
            username   => $user->{username}
        )->redirect_to('users_wall');
    }
    else {
        $self->flash( error => "Неправильный пароль, или такого пользователя не существует!" . (%$user) )->redirect_to('index');
    }
}

sub delete {
    shift->session( user_id => '', username => '' )->redirect_to('index');
}

sub check {
    shift->session('user_id') ? 1 : 0;
}

1;
