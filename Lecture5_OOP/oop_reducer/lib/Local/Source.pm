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


sub next {
    my $self = shift @_;
    my $array = $self->{array};

    $self->{whoIsNow} += 1;

    if ( defined $array->[$self->{whoIsNow} - 1] ) {
        return $array->[$self->{whoIsNow} - 1];
    }
    else {
        return undef;
    }
}

1;
