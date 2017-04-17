package Local::Row;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

Класс, объекты которого отвечают за парсинг строк из источника.

=cut

sub get {
    my $self    = shift;
    my $name    = shift;
    my $default = shift;

    if (exists $self->{$name}) {
        return $self->{$name};
    }
    else {
        return $self->{$default};
    }
}

1;
