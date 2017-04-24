package Local::Reducer::MinMaxAvg;

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

sub new {
	my $class = shift;
	my $self = bless { @_ }, $class;
	$self->{reducedMax} = $self->{initial_value};
	$self->{reducedMin} = $self->{initial_value};
	return $self;
}

sub get_max {
	my $self = shift;
	return $self->{reducedMax};

}

sub get_min {
	my $self = shift;
	return $self->{reducedMin};


}
sub get_avg {
	my $self = shift;
	if ( exists $self->{Sum} && exists $self->{count}) {
		my $div = $self->{Sum} / $self->{count};
		return $div;
	}
	else {
		return undef;
	}
}

sub reduce_n {
	my $self = shift;
	my $n 	 = shift;

	my $val;

	my $i = 0;
	my $str;
	while ($i++ < $n and $str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		if ( $hashed ) {
			$val = $hashed->{$self->{field}};

			if ( looks_like_number($val) ) {
				# Max
				if ( exists $self->{reducedMax} and $val > $self->{reducedMax}) {
					$self->{reducedMax} = $val;
				}
				elsif (! exists $self->{reducedMax} ) {
					$self->{reducedMax} = $val;
				}
				# Min
				if ( exists $self->{reducedMin} and $val < $self->{reducedMin}) {
					$self->{reducedMin} = $val;
				}
				elsif (! exists $self->{reducedMin} ) {
					$self->{reducedMin} = $val;
				}
				# Avg
				$self->{Sum} += $val;
				$self->{count} += 1 ;
			}
		}
	}
	return $self;
}

sub reduce_all {
	my $self = shift;

	my $str;
	my $val;

	while ($str = $self->{source}->next() and defined $str) {
		my $hashed = $self->{row_class}->new(str => $str);
		if ( $hashed ) {
			$val = $hashed->{$self->{field}};

			if ( looks_like_number($val) ) {
				# Max
				if ( exists $self->{reducedMax} and $val > $self->{reducedMax}) {
					$self->{reducedMax} = $val;
				}
				elsif (! exists $self->{reducedMax} ) {
					$self->{reducedMax} = $val;
				}
				# Min
				if ( exists $self->{reducedMin} and $val < $self->{reducedMin}) {
					$self->{reducedMin} = $val;
				}
				elsif (! exists $self->{reducedMin} ) {
					$self->{reducedMin} = $val;
				}
				# Avg
				$self->{Sum} += $val;
				$self->{count} += 1;
			}
		}
	}
	return $self;
}

1;
