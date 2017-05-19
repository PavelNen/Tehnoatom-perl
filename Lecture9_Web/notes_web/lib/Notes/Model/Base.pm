package Notes::Model::Base;

use 5.020;
use Mojo::Base;

#### Class Methods ####

sub select {
    my $class = shift;
    my $h = shift;
    say "select";
    my $query = "SELECT * FROM " . $class->table_name . " WHERE "
        . join (' AND ', map {"$_ = '$h->{$_}'"; } keys %$h);
    say "$query";
    Notes::Model->db->selectrow_hashref($query, undef) or undef;
}

sub selectall {
    my $class = shift;
    my $h = shift;
    my $mode = shift;
    say "selectall";
    my $query = "SELECT * FROM " . $class->table_name;
    if ($mode eq 'lenta') {
        $query .= " WHERE users LIKE '\%$h->{username}\%'";
    }
    elsif ($mode ne 'empty') {
        $query .= " WHERE ";
        $query .= join (' AND ', map {"$_ = '$h->{$_}'"; } keys %$h);
    }
    say "$query";
    Notes::Model->db->selectall_hashref( $query , 'id') or undef;

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
    my $key = shift;
    my $value = shift;
    my $h = shift;

    my $db = Notes::Model->db;
    $db->do("UPDATE " . $class->table_name . " SET $key = '$value' "
                . " WHERE " . join(', ',  map {"$_ = '$h->{$_}'"} keys %$h))
                    or die $db->errstr;
}

sub delete {
    my $class = shift;
    my $h = shift;
    my $db = Notes::Model->db;
    $db->do("DELETE FROM "  . $class->table_name . " WHERE  "
            . join(' AND ',  map {"$_ = '$h->{$_}'"} keys %$h) ) or die $db->errstr;
}

1;
