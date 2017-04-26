package Local::Row::Simple;

use 5.020;
use strict;
use warnings;
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
    my %h = ();
    map {
            if ($_ =~ /^(\w+):(\w+)$/) {
                $h{$1} = $2;
            }
            else {
                return undef;
            }
        }
        (split /,/, $param{str});
    return bless \%h, $class;
}



1;
