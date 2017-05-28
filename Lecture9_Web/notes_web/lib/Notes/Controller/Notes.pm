package Notes::Controller::Notes;

use 5.010;
use Mojo::Base 'Mojolicious::Controller';
use DDP;
use utf8;
binmode(STDOUT,':utf8');
no warnings 'layer';

sub onenote {
    my $self = shift;
    my $noteid = $self->param('noteid');

    my $h = Notes::Model::Note->select({id => $noteid});

    my $idtoname = Notes::Model::User->select( {
                id => $h->{userid},
            } );
    $h->{username} = $idtoname->{username};
    $h->{firstname} = $idtoname->{firstname};
    $h->{lastname} = $idtoname->{lastname};

    #TODO Оформить историю, в таблице уже созданы поля под неё

    $self->render( note => $h );
}

sub wall {
    my $self = shift;
    my $a = {};

    #say "Start selecting";
    $a = Notes::Model::Note->selectall(
            {userid => $self->session('user_id')} );

    #say "Finish selecting";
    $self->render( fewnotes => $a );
}

sub lenta {
    my $self = shift;
    my $id = $self->param('id');
    if ($id and $id == $self->session('user_id')) {
        $self->redirect_to('notes_show');
    }
    my $m = {};
    #say "Start selecting id => " .$self->session('user_id');
    if (!$id) {
    # Ищем свои записки по колонке userid в таблице notes
    $m = Notes::Model::Note->selectall(
        { userid => $self->session('user_id') }
        );
    }

    # Ищем доступные мне записки по колонке users в таблице notes
    my $b = Notes::Model::Note->selectall(
        { favid => $self->session('user_id') },
        'lenta', $id
        );
    # Ищем доступные всем записки по колонке users
    my $c = Notes::Model::Note->selectall(
        { favid => 'ALL' },
        'lenta', $id
        );

    my $d = Notes::Model::Favorites->select( {userid => $self->session('user_id')} );
    my %subscr = map {($_ => 1)} (split(/,/, $d->{users}));
    #p %subscr;
    # Объединяем хэши
    my %a = (%$m, %$b, %$c);
    my %willshow = ();

    my $who = '';
    my $firstname = '';
    my $lastname = '';
    for (keys %a) {
        if ($id or exists $subscr{$a{$_}->{userid}}  ) {
            my $idtoname = Notes::Model::User->select( {
                id => $a{$_}->{userid},
            } );
            $willshow{$_} = $a{$_};
            $willshow{$_}->{username} = $idtoname->{username};
            if ($id) {
                $who = $idtoname->{username};
                $firstname = $idtoname->{firstname};
                $lastname = $idtoname->{lastname}
            }
        }
    }

    #say "Finish selecting";

    $self->render( fewnotes  => \%willshow,
                   who       => $who,
                   firstname => $firstname,
                   lastname  => $lastname);
}

sub create_form {
    my $self = shift;

    #    Этот кусок для отображения в списке только людей из подписок
    #    my $user = Notes::Model::Favorites->select( {
    #        userid => $self->session('user_id'),
    #    } );
    #
    #    my @a = ();
    #    @a = split /,/, $user->{users} if $user->{users};

    my $f = {};
    $f = Notes::Model::User->selectall( {}, 'empty' );
    my @a = ();
       @a = map {$f->{$_}->{username} if $f->{$_}->{username} ne $self->session('username')}
                    sort {$b cmp $a} keys %$f;

    $self->render( favorites => \@a );

}

sub create {
    my ($self) = @_;

    my $title     = $self->param('title');
    my $text      = $self->param('text');
    my $users     = $self->param('users');
    my $rights    = $self->param('rights');
    my @favorites = $self->req->params->every_param('favs');

    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

    my $err_msg = '';
    my $notice = '';

    if ($title eq '' and $text eq '') {
        $err_msg = "Заметка пуста!" ;
    }
    elsif ($text eq '') {
        $notice = "Мысль озаглавлена, но не изложена.." ;
    } elsif ($title eq '') {
        $notice = "Безымяннная цитата.." ;
    }

    if ($err_msg) {
        $self->flash(
            error        => $err_msg,
        )->redirect_to('notes_form');

        return;
    }

    for (@{$favorites[0]}) {
        if ($_ eq 'ALL') { $users .= "ALL,"; }
        else {
            my $nicktoid = Notes::Model::User->select({username => $_});
            $users .= "$nicktoid->{id},";
        }
    }

    #$users =~ s/\s// if $users;
    my @time;
    #my ($sec,$min,$hour,$mday,$mon,$year)
    @time[5,4,3,2,1,0] = map {
        if ($_ < 10) {
            sprintf ("%02d", $_);
        } else {
            $_
        }} localtime(time);

    $time[0] += 1900;
    #print "Создаю заметку за @time -> ";
    my $note_id = Notes::Model::Note->insert({
        title   => $title,
        text    => $text,
        users   => $users,
        userid  => $self->session('user_id'),
        time    => join('', @time),
        rights  => $rights,
    });
    say "Заметка создана";

    $self->flash(notice => $notice)->redirect_to('notes_show');
}

sub edit_form {
    my $self = shift;
    my $noteid = $self->param('noteid');

    #    my $f = Notes::Model::Favorites->select( {
    #    userid => $self->session('user_id'),
    #    } );
    #
    #    my @a = ();
    #    @a = split /,/, $f->{users} if $f->{users};

    my $f = {};
    $f = Notes::Model::User->selectall( {}, 'empty' );
    my @a = grep { $_ ne $self->session('username') }
                map { $f->{$_}->{username} }
                    sort {$b cmp $a} keys %$f;
    my $h = Notes::Model::Note->select( {id => $noteid} );
    my %b = ();
    %b = map { if ($_ eq 'ALL') {$_ => 1}
                else { $f->{$_}->{username} => 1 }
        } split /,/, $h->{users} if $h->{users};
    $h->{favs} = \%b;
    $h->{username} = $f->{$h->{userid}}->{username};
    #p @a;
    my $warning = '';
    if ($h->{editing} eq '') {
        Notes::Model::Note->update(
            {editing => $self->session('username') . ", "},
            {id => $noteid});
    }
    else {
        my $un = $self->session('username');
        if (! ($h->{editing} =~ /$un/) ) {
            Notes::Model::Note->update(
                {editing => $h->{editing} . $self->session('username') . ", "},
                {id => $noteid} );
        }
        substr $h->{editing}, -2, 2, '';
        $warning = "Пользователи " . $h->{editing} . " редактируют сейчас эту заметку";
    }

    $self->render( favorites => \@a, forms => $h, noteid => $noteid, warning => $warning );

    #TODO Добавить стирание пользователя из списка редактирующих заметку,
    # в случае ухода со страницы редактирования любым спсобом,
    # не только после сохранения изменений

}

sub update {
    my ($self) = @_;

    my $title     = $self->param('title');
    my $text      = $self->param('text');
    my $users     = $self->param('users');
    my @favorites = $self->req->params->every_param('favs');
    my $noteid    = $self->param('nid');
    my $rights    = $self->param('rights');

    my $validation = $self->validation;
    return $self->render(text => 'Bad CSRF token!', status => 403)
    if $validation->csrf_protect->has_error('csrf_token');

    my $err_msg = '';
    my $notice  = '';

    if ($title eq '' and $text eq '') {
        $err_msg = "Заметка пуста!" ;
    }
    elsif ($text eq '') {
        $notice = "Мысль озаглавлена, но не изложена.." ;
    } elsif ($title eq '') {
        $notice = "Безымяннная цитата.." ;
    }

    if ($err_msg) {
        $self->flash(
            title => $title,
            text  => $text,
            users => $users,
            error => $err_msg,
            rights => $rights,
        )->redirect_to('edit_form');

        return;
    }

    for (@{$favorites[0]}) {
        if ($_ eq 'ALL') {$users .= "ALL,";}
        else {
            my $nicktoid = Notes::Model::User->select({username => $_});
            $users .= "$nicktoid->{id},";
        }
    }

    my $h = Notes::Model::Note->select( {id => $noteid} );
    my $un = $self->session('username');
    $h->{editing} =~ s/\Q$un\E,\s//g;

    if ( Notes::Model::Note->update({
        title   => $title,
        text    => $text,
        users   => $users,
        rights  => $rights,
        editing => $h->{editing},
    }, { id => $noteid }) ) {
        $notice = join "\n" , ($notice, "Заметка обновлена");
    }
    say "Заметка обновлена $noteid";

    $self->flash(notice => $notice)->redirect_to('notes_show');
}

sub delete {
    my $self = shift;
    my $noteid = $self->param('noteid');

    Notes::Model::Note->delete( {id => $noteid} );

    $self->flash(notice => 'Записка удалена')->redirect_to('notes_show');
}

1;
