package Notes::Controller::Auths;

use strict;
use warnings;
use 5.010;

use Mojo::Base 'Mojolicious::Controller';


sub create {
    my ($self) = @_;

    my $username    = $self->param('username');
    my $password    = $self->param('password');

    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

    if (!$username and !$password) {
        $self->flash( error => "Нужно ввести что-нибудь..." )->redirect_to('index');
        return;
    }

    my $user = Notes::Model::User->select({username => $username, password=>$password});

    if ( $username && $user->{id} ) {
        $self->session(
            user_id    => $user->{id},
            username   => $user->{username},
            firstname  => $user->{firstname},
            lastname   => $user->{lastname}
        )->redirect_to('notes_show');
    }
    else {
        $self->flash( error => "Неправильный пароль, или такого пользователя не существует!" )->redirect_to('index');
    }
}

sub delete {
    shift->session( user_id    => '',
                    username   => '',
                    firstname  => '',
                    lastname   => ''
            )->redirect_to('index');
}

sub check {
    my $self = shift;
    if ($self->session('user_id')) {
        1;
    }
    else {
        $self->redirect_to('index');
    }
}

1;
