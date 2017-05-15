package Notes::Controller::Notes;

use 5.020;
use Mojo::base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    my $notes = Notes::Model::Note->select( {
        user_id => $self->session('user_id')
    } );

    $self->render(json => $notes);
}

sub create {
    my $self = shift;

    my $note_id = Notes::Model::Note->insert({
        %{$self->req->json},
        user_id => $self->session('user_id'),
        date    => time()
    });

    $self->render(
        json   => scalar Notes::Model::Note->select( { note_id => $note_id } )->hash,
        status => 201
    );
}

sub update {
    my $self = shift;
    my %where = (
        user_id => $self->session('user_id'),
        note_id => $self->param('id')
    );

    Notes::Model::Note->update( $self->req->json , \%where);

    $self->render(json => Notes::Model::Note->select(\%where)->hash );
}

sub delete {
    my $self = shift;

    Notes::Model::Note->delete( {
        user_id => $self->session('user_id'),
        note_id => $self->param('id')
    } );

    $self->render(json => 1);
}

1;
