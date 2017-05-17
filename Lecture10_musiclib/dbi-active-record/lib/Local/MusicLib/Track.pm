package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;

use DateTime;

db "Local::MusicLib::DB::SQLite";

table 'tracks';

DBI::ActiveRecord::has_field (id =>
    isa => 'Int',
    auto_increment => 1,
    index => 'primary')
;

DBI::ActiveRecord::has_field (name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100
));

DBI::ActiveRecord::has_field (extension => (
    isa => 'Str'
));

DBI::ActiveRecord::has_field (create_time => (
    isa => 'DateTime',
    serializer => sub { $_[0]->epoch },
    deserializer => sub { DateTime->from_epoch(epoch => $_[0]) }
));

DBI::ActiveRecord::has_field (album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100
));

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;
