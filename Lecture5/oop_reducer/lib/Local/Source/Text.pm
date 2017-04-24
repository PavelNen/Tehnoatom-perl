package Local::Source::Text;

use strict;
use warnings;

use parent 'Local::Source';

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

Класс, объекты которого отвечают за подачу данных в `Reducer`. Отвечает за получение данных (через интерфейс типа "итератор"), но не за их парсинг.

=cut

sub new {
	my ($class, %params) = @_;
	my $delimiter;

	if (exists $params{delimiter}) {
		$delimiter = $params{delimiter};
	}
	else {
		$delimiter = "\n";
	}

	my @a = split $delimiter, $params{text};
	my %h;
	$h{array} = \@a;

	return bless \%h, $class;
}

1;
