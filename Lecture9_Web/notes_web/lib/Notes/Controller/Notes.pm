package Notes::Controller::Notes;

use 5.020;
use Mojo::Base 'Mojolicious::Controller';
use DDP;
use utf8;

sub wall {
    my $self = shift;
    my $a = {};
    #say "Start selecting";
    $a = Notes::Model::Note->selectall( {
        userid => $self->session('user_id')
    } );

    #say "Finish selecting";
    $self->render( fewnotes => $a );
}

sub lenta {
    my $self = shift;
    #say "Start selecting id => " .$self->session('user_id');

    # Ищем свои записки по колонке users
    my $m = Notes::Model::Note->selectall(
        { userid => $self->session('user_id') }
        );
    # Ищем доступные мне записки по колонке
    my $b = Notes::Model::Note->selectall(
        { username => $self->session('username') },
        'lenta'
        );
    # Ищем доступные всем записки по колонке
    my $c = Notes::Model::Note->selectall(
        { username => 'ALL' },
        'lenta'
        );
    # Объединяем хэши
    my %a = (%$m, %$b, %$c);

    for (keys %a) {
        my $idtoname = Notes::Model::User->select( {
            id => $a{$_}->{userid},
        } );
        $a{$_}->{username} = $idtoname->{username};
    }

    say "Finish selecting";

    $self->render( fewnotes => \%a );
}

sub create_form {
    my $self = shift;

    my $user = Notes::Model::Favorites->select( {
        userid => $self->session('user_id'),
    } );

    my @a = ();
    @a = split /,/, $user->{users} if $user->{users};

    $self->render( favorites => \@a );

}

sub create {
    my ($self) = @_;

    my $title   = $self->param('title');
    my $text  = $self->param('text');
    my $users   = $self->param('users');
    my @favorites = $self->req->params->every_param('favs');

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
        $users .= "$_,";
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
    print "Создаю заметку за @time -> ";
    my $note_id = Notes::Model::Note->insert({
        title => $title,
        text => $text,
        users => $users,
        userid => $self->session('user_id'),
        time    => join '', @time
    });
    say "Заметка создана";
    $self->flash(notice => $notice)->redirect_to('notes_show');
}

sub update {
    my $self = shift;
    my %where = (
        userid => $self->session('user_id'),
        id => $self->param('id')
    );

    Notes::Model::Note->update( text => $self->req->json , \%where);

    $self->render(json => Notes::Model::Note->select(\%where) );
}

sub delete {
    my $self = shift;

    Notes::Model::Note->delete( {
        user_id => $self->session('user_id'),
        id => $self->param('id')
    } );

    $self->render(json => 1);
}

1;
