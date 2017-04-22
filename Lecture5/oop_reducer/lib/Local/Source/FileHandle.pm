package Local::Source::FileHandle;
use 5.020;

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

# Создаём объект класса
sub new {
    my ($class, %params) = @_;
    return bless \%params, $class;
}

sub next {
    my $self = shift @_;
    my $fh = $self->{fh};

    my $str;

    # При каждом запросе функции будет заново читать

    $str = <$fh>;
    if ( $str ) {
        chomp $str ;
    }
    
    return $str;
}

1;
