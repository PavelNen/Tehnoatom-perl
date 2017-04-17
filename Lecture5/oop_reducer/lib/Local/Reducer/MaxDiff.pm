package Local::Reducer::MaxDiff;

use 5.020;
use strict;
use warnings;
use DDP;

use Scalar::Util qw(looks_like_number);

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

sub new {
	my $class = shift;
	my $self = bless { @_ }, $class;
}

sub reduce_n {
	my $self = shift;
	my $n 	 = shift;

	my $sum  = 0;

	my $i = $self->{initial_value};
	my $str;
	while ($i < $n and $str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		my $num = $hashed->{$self->{field}};
		if ( $hashed && looks_like_number($num) ) {
			$sum += $num;
		}
		$i++;
	}
	$self->{reduced} += $sum;
	return $sum;
}

sub reduced {
	my $self = shift;
	return $self->{reduced};
}

sub reduce_all {
	my $self = shift;

	$self->{reduced} += 0;

	my $sum = $self->{reduced};
	my $str;

	while ($str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		my $num = $hashed->{$self->{field}};
		if ( $hashed && looks_like_number($num)) {
			$sum += $num;
		}
	}

	$self->{reduced} = $sum;
	return $sum;
}

1;
