package Notes::Model::Base;

use 5.010;
use Mojo::Base;

#### Class Methods ####

sub select {
    my $class = shift;
    my $h = shift;
    #say "select";
    my $query = "SELECT * FROM " . $class->table_name . " WHERE "
        . join (' AND ', map {"$_ = '" . quotemeta($h->{$_}) ."'"; } keys %$h);
    #say "$query";
    Notes::Model->db->selectrow_hashref($query, undef) or undef;
}

sub selectall {
    my $class = shift;
    my $h = shift;
    my $mode = shift;
    my $id = shift;
    #say "selectall";
    my $query = "SELECT * FROM " . $class->table_name;
    if ($mode eq 'lenta') {
        $query .= " WHERE users LIKE '\%$h->{username}\%'";
    }
    elsif ($mode ne 'empty') {
        $query .= " WHERE ";
        $query .= join (' AND ', map {"`$_` = '" . quotemeta($h->{$_}) ."'"; } keys %$h);
    }
    if ($mode eq 'lenta' and $id) {
        $query .= " AND `userid` = '" . quotemeta($id) . "'";
    }
    #say "$query";
    Notes::Model->db->selectall_hashref( $query , 'id') or undef;

}

sub insert {
    my $class = shift;
    my $h = shift;
    my $db = Notes::Model->db;
    my @a = keys %$h;
    $db->do(
        "INSERT INTO `" . $class->table_name . "` ("
            . join(', ', @a ) . ") VALUES ( "
                . join(', ',  map {"'" . quotemeta($h->{$_}) . "'"} @a) . " )" )
                        or die $db->errstr;
    $db->last_insert_id('','','','')  or die $db->errstr;
}

sub update {
    my $class = shift;
    my $new = shift;
    my $fields = shift;

    my $db = Notes::Model->db;
    my $query = "UPDATE " . $class->table_name . " SET "
            . join(', ',  map {"$_ = '" . quotemeta($new->{$_}) . "'"} keys %$new)
            . " WHERE " .
                join(' AND ',  map {"$_ = '" . quotemeta($fields->{$_}) . "'"} keys %$fields);
    say "$query";
    $db->do($query) or die $db->errstr;
}

sub delete {
    my $class = shift;
    my $h = shift;
    my $db = Notes::Model->db;
    $db->do("DELETE FROM "  . $class->table_name . " WHERE  "
            . join(' AND ',  map {"$_ = '" . quotemeta($h->{$_}) . "'"} keys %$h) )
                or die $db->errstr;
}

1;
