package Notes::Model::Base;

use 5.020;
use Mojo::Base;

#### Class Methods ####

sub select {
    my $class = shift;
    my $h = shift;
    Notes::Model->db->selectrow_hashref(
        "SELECT * FROM " . $class->table_name . " WHERE "
            . join (' AND ', map {"$_ = '$h->{$_}'"; } keys %$h), undef) or undef;
}

sub insert {
    my $class = shift;
    my $h = shift;
    my $db = Notes::Model->db;
    my @a = keys %$h;
    $db->do(
        "INSERT INTO " . $class->table_name . " ("
            . join(', ', @a ) . ") VALUES ( "
                . join(', ',  map {"'$h->{$_}'"} @a) . " )" ) or die $db->errstr;
    $db->last_insert_id('','','','')  or die $db->errstr;
}

sub update {
    my $class = shift;
    my $db = Notes::Model->db;
    $db->update($class->table_name, @_) or die $db->errstr;
}

sub delete {
    my $class = shift;
    my $db = Notes::Model->db;
    $db->delete($class->table_name, @_) or die $db->errstr;
}

1;
