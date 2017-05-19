package Notes::Controller::Users;

use strict;
use warnings;
use 5.020;
use DDP;

use Mojo::Base 'Mojolicious::Controller';
#use Mail::Sender;

sub show {
    my $self = shift;
    my $favadd = $self->param('favadd');
    my $favdel = $self->param('favdel');

    if ($favadd and $favadd =~ /^\w+$/) {
        favadd($self, $favadd);
    }
    if ($favdel and $favdel =~ /^\w+$/) {
        favdel($self, $favdel);
    }

    my $h = {};
    $h = Notes::Model::User->selectall( {}, 'empty' );
    my $a = {};
    $a = Notes::Model::Favorites->select({userid => $self->session('user_id')});

    for my $id (keys %$h) {
        if ($a->{'users'} and $a->{'users'} =~ /\Q$h->{$id}->{'username'}\E/) {
            $h->{$id}->{'favorite'} = 1;
        }
        else {
            $h->{$id}->{'favorite'} = 0;
        }
    }
    p $h;
    $self->render( list => $h );
}

sub favadd {
    my $self = shift;

    my $favname = shift;

    my $user = Notes::Model::Favorites->select( {
        userid => $self->session('user_id'),
    } );
    say "user = $user";
    if ($user) {
            unless ($user->{'users'} =~ /$favname/) {
                Notes::Model::Favorites->update(
                    'users', $user->{users} . "$favname,",
                        {userid => $self->session('user_id'),}
            );
        }
    }
    else {
        Notes::Model::Favorites->insert( {
            userid => $self->session('user_id'),
            users => "$favname,"
        } );
    }

    return 1;
}

sub favdel {
    my $self = shift;

    my $favname = shift;

    my $user = Notes::Model::Favorites->select( {
        userid => $self->session('user_id'),
    } );
    say "user = $user";
    if ($user) {
            $user->{'users'} =~ s/,?\Q$favname\E,?//g;
                Notes::Model::Favorites->update(
                    'users', $user->{users},
                        {userid => $self->session('user_id'),}
            );

    }

    return 1;
}

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
    )->redirect_to('notes_show') if $user_id #TODO ;
}



1;
