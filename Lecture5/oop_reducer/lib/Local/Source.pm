package Local::Source;

use strict;
use warnings;

=encoding utf8
=head1 NAME
Local::Source - base abstract source
=head1 VERSION
Version 1.00
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
=cut

# Создаём объект класса
sub new {
    my ($class, %params) = @_;
    return bless \%params, $class;
}


sub next {
    my $self = shift @_;
    my $array = $self->{array};

    #
    if (@$array) {
        my $item = shift @$array;
        $self->{array} = $array;
        return $item;
    }
    else { return undef; }
}

1;
