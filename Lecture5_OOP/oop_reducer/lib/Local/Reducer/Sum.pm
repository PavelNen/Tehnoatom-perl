package Local::Reducer::Sum;

use 5.020;
use strict;
use warnings;
use DDP;

use parent 'Local::Reducer';

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


sub reduce_n {
	my $self = shift;
	my $n 	 = shift;
	my $all  = shift;

	my $i = 0;
	my $str;

	while ( ($all or $i++ < $n) and $str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		my $num = $hashed->{$self->{field}};
		if ( $hashed && looks_like_number($num) ) {
			$self->{reducedSum} += $num;
		}
	}

	return $self->{reducedSum};
}

sub reduce_all {
	my $self = shift;
	reduce_n($self, 0, 1);
}

1;
