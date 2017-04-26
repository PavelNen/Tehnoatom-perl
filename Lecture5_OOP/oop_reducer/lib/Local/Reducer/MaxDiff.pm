package Local::Reducer::MaxDiff;

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

	# $self->{maxtop} максимальное значение среди полей top
	# $self->{minbottom} минимальное значение среди полей bottom

	my ($top, $bottom);
	my $i = 0;
	my $str;

	while ( ($all || $i++ < $n) and $str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		if ( $hashed ) {
			$top = $hashed->{$self->{top}};
			$bottom = $hashed->{$self->{bottom}};

			if ( looks_like_number($top) && looks_like_number($bottom) ) {
				my $diff = $top - $bottom;
				if ( exists $self->{reducedDiff} and $diff > $self->{reducedDiff}) {
					$self->{reducedDiff} = $diff;
				}
				elsif (! exists $self->{reducedDiff} ) {
					$self->{reducedDiff} = $diff;
				}
			}
		}
	}

	return $self->{reducedDiff};
}

sub reduce_all {
	my $self = shift;

	reduce_n($self, 0, 1)
}

1;
