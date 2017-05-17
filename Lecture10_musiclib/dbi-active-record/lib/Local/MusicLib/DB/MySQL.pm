package Local::MusicLib::DB::MySQL;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

sub _build_connection_params {
    my ($self) = @_;
    return ['DBI:mysql:MusicLibDB:localhost', 'user', 'qwerty ' ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
