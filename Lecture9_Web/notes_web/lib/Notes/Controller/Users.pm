package Notes::Controller::Users;

use strict;
use warnings;
use 5.020;

use Mojo::Base 'Mojolicious::Controller';

sub create {
    my $self = shift;

    my $username   = $self->param('username');
    my $firstname  = $self->param('firstname');
    my $lastname   = $self->param('lastname');
    my $password   = $self->param('password');
    my $password2  = $self->param('password2');
    my $email      = $self->param('email');

    # Validation
    my $err_msg;
CHECK: {

        unless ( $username && $password && $password2 && $email ) {
            $err_msg = 'Пожалуйста, заполните все поля!';
            last CHECK;
        }

        my $user = Notes::Model::User->select({username => $username});

        if ( $user->{id} ) {
            $err_msg = 'Такое имя пользователя уже занято!';
            last CHECK;
        }

        unless ( $email =~ /^[a-z0-9.-]+\@[a-z0-9.-]+$/i ) {
            $err_msg = 'Некорректный адресс электронной почты!';
            last CHECK;
        }

        $user = Notes::Model::User->select({email => $email});

        if ( $user->{id} ) {
            $err_msg = 'Такая электронная почта уже зарегистрированна!';
            last CHECK;
        }

        if ( $password ne $password2 ) {
            $err_msg = 'Пароли не совпадают!';
            last CHECK;
        }

    }

    # Show error
    if ($err_msg) {
        $self->flash(
            error        => $err_msg,
            username     => $username,
            email        => $email,
        )->redirect_to('index');

        return;
    }

    # Save User
    my %user = (
        username  => $username,
        firstname => $firstname,
        lastname  => $lastname,
        password  => $password,
        email     => $email
    );

    my $user_id = Notes::Model::User->insert(\%user);

    # Login User
    $self->session(
        user_id => $user_id,
        username   => $username
    )->redirect_to('users_wall') if $user_id #TODO ;
}

sub wall {
    my $self = shift;

    $self->render(msg => "Привет!"  );
}

1;
