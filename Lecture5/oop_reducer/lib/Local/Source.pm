package Local::Source;

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

Класс, объекты которого отвечают за подачу данных в `Reducer`. Отвечает за получение данных (через интерфейс типа "итератор"), но не за их парсинг.

=cut

sub next {

}

sub Array {

}

sub Text {

}

1;
