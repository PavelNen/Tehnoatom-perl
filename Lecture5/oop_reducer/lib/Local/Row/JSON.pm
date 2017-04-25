package Local::Row::JSON;

use 5.020;
use strict;
use warnings;

use JSON::XS;
use DDP;
use parent 'Local::Row';

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
    my ($class, %param) = @_;

    if ( my $h = eval{ JSON::XS::decode_json($param{str}) } ) {
        if (ref $h eq 'HASH') {
            return bless $h, $class;
        }
        else { return undef; }
    }
    else { return undef; }
}

1;
