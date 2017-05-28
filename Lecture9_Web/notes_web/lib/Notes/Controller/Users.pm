package Notes::Controller::Users;

use strict;
use warnings;
use 5.010;
use DDP;

use Mojo::Base 'Mojolicious::Controller';
#use Mail::Sender;

# функция для представления карточек с данными пользователей в Ленте и Мире

sub show {
    my $self = shift;
    my $favadd = $self->param('favadd');
    my $favdel = $self->param('favdel');
    my $favmode = $self->param('fav');

    if ($favadd and $favadd =~ /^\d+$/) {
        favadd($self, $favadd);
    }
    if ($favdel and $favdel =~ /^\d+$/) {
        favdel($self, $favdel);
    }

    my $h = {};
    $h = Notes::Model::User->selectall( {}, 'empty' );
    my $a = {};
    $a = Notes::Model::Favorites->select({userid => $self->session('user_id')});

    if ($favmode) {
        my $f = {};
        for my $id (keys %$h) {
            if ($a->{'users'} and $a->{'users'} =~ /\Q$h->{$id}->{'id'}\E/) {
                $f->{$id} = $h->{$id};
                $f->{$id}->{'favorite'} = 1;
            }
        }
        $self->render( list => $f, page => 'Подписки' );
    }
    else {
        for my $id (keys %$h) {
            if ($a->{'users'} and $a->{'users'} =~ /\Q$h->{$id}->{'id'}\E/) {
                $h->{$id}->{'favorite'} = 1;
            }
            else {
                $h->{$id}->{'favorite'} = 0;
            }
        }
        #p $h;
        $self->render( list => $h, page => 'Мир');
    }
}

# Добавляет человека в подписки
sub favadd {
    my $self = shift;

    my $favid = shift;

    my $user = Notes::Model::Favorites->select( {
        userid => $self->session('user_id'),
    } );
    say "user = $user";
    if ($user) {
        unless ($user->{'users'} =~ /$favid/) {
            Notes::Model::Favorites->update(
                    {users  => $user->{users} . "$favid,"},
                    {userid => $self->session('user_id'),}
                                            );
        }
    }
    else {
        Notes::Model::Favorites->insert( {
            userid => $self->session('user_id'),
            users => "$favid,"
        } );
    }

    return 1;
}
# Убирает человека из подписок
sub favdel {
    my $self = shift;

    my $favid = shift;

    my $user = Notes::Model::Favorites->select( {
        userid => $self->session('user_id'),
    } );
    say "user = $user";
    if ($user) {
        $user->{'users'} =~ s/\Q$favid\E,//g;
            Notes::Model::Favorites->update(
                    {users => $user->{users}},
                    {userid => $self->session('user_id'),}
                                            );

    }

    return 1;
}

# Регистрация нового пользователя
sub create {
    my $self = shift;

    my $username   = $self->param('username');
    my $firstname  = $self->param('firstname');
    my $lastname   = $self->param('lastname');
    my $password   = $self->param('password');
    my $password2  = $self->param('password2');
    my $email      = $self->param('email');

    # Validation

    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

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
        user_id    => $user_id,
        username   => $username,
        firstname  => $firstname,
        lastname   => $lastname
    )->redirect_to('notes_show') if $user_id #TODO ;
}

# Страница настроек аккаунта
sub settings {
    my $self = shift;
    my $noteid = $self->param('noteid');

    my $h = Notes::Model::User->select( {id => $self->session('user_id')} );

    $self->render( forms => $h );
}

# Обновление данных пользователя
sub update {
    my $self = shift;
    my $username      = $self->param('username');
    my $firstname     = $self->param('firstname');
    my $lastname      = $self->param('lastname');
    my $password      = $self->param('password');
    my $newpassword   = $self->param('newpassword');
    my $newpassword2  = $self->param('newpassword2');
    my $email         = $self->param('email');

    # Validation
    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

    my $err_msg;
CHECK: {

        unless ( $username && $password && $email ) {
            $err_msg = 'Пожалуйста, заполните все поля слева! ';
            last CHECK;
        }

        my $user = Notes::Model::User->select({username => $username});

        if ( $user->{id} and $user->{username} ne $self->session('username') ) {
            $err_msg = 'Такое имя пользователя уже занято!';
            last CHECK;
        }

        unless ( $email =~ /^[a-z0-9.-]+\@[a-z0-9.-]+$/i ) {
            $err_msg = 'Некорректный адресс электронной почты!';
            last CHECK;
        }

        $user = Notes::Model::User->select({email => $email});

        if ( $user->{id} and $user->{id} ne $self->session('user_id') ) {
            $err_msg = 'Такая электронная почта уже зарегистрированна!';
            last CHECK;
        }

        if ( $newpassword ne $newpassword2 ) {
            $err_msg = 'Пароли не совпадают!';
            last CHECK;
        }
        elsif ($newpassword ne '') {
            $password = $newpassword;
        }

    }

    # Show error
    if ($err_msg) {
        $self->flash(
            error        => $err_msg,
        )->redirect_to('users_settings');

        return;
    }

    # Save User
    my %user = (
        username     => $username,
        firstname    => $firstname,
        lastname     => $lastname,
        password     => $password,
        email        => $email
    );

    $self->session(
        username   => $username,
        firstname  => $firstname,
        lastname   => $lastname
    );
    my $user_id = Notes::Model::User->update(\%user, { id => $self->session('user_id') } );

    $self->redirect_to('notes_show');
}

# Уничтожение аккаунта и его заметок, кроме 'w'
sub delete {
    my $self = shift;
    my $username      = $self->param('username');
    my $firstname     = $self->param('firstname');
    my $lastname      = $self->param('lastname');
    my $password      = $self->param('password');
    my $email         = $self->param('email');

    # Validation
    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

    my $err_msg;

    unless ( $password ) {
        $err_msg = "Пожалуйста, введите текущий пароль!";
    }


    # Show error
    if ($err_msg) {
        $self->flash(
            error        => $err_msg,
        )->redirect_to('users_settings');

        return;
    }

    # Удаляем аккаунт и все записки пользователя

    Notes::Model::User->delete({id => $self->session('user_id')});
    Notes::Model::Note->delete({userid => $self->session('user_id'),
                                rights => 'r'});

    #TODO Сохранять ник в записках, а то они все привязаны только к userid

    # Разлогиниваем
    $self->Notes::Controller::Auths::delete();
}

1;
