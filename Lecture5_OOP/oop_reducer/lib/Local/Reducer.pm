package Local::Reducer;

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

Каждый такой класс имеет префикс `Local::Reducer`. Отвечает за непосредственно схлопывания, но абстрагирован от способа получения и парсинга данных.

Все методы находятся в своих классах

=cut

sub new {
	my $class = shift;
	my $self = bless { @_ }, $class;
    $self->{reduced}  = $self->{initial_value};
	return $self;
}

sub reduced {
	my $self = shift;
	return $self->{reduced};
}

1;
