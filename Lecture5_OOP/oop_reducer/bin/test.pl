#!/usr/bin/env perl

use 5.020;

use strict;
use warnings;
use FindBin; use lib "$FindBin::Bin/../lib";

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

Каждый такой класс имеет префикс `Local::Reducer`. Отвечает за непосредственно схлопывания, но абстрагирован от способа получения и парсинга данных.

=cut


sub reduce_n {
	my $self = shift;
}

sub reduce_all {
	my $self = shift;

}

sub reduced {}

1;
