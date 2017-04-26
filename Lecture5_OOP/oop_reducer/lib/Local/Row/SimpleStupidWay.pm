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

    if ( $param{str} eq "" ) { return {}; }
    else
    {
        my $now = ''; # последний попавшийся "," или ":"
        my $key = '';
        my $value = '';
        my $h = {};
        my $ln = length($param{str});

        for my $i ( 0..$ln ) {
            my $c = substr $param{str}, $i, 1;

            # Проверка отсутствия значения ключа
            if ($now eq ',' || $now eq '' and $i == $ln) {
                return undef;
            }

            # Проверка чередования "," и ":"
            if ($c =~ /^[,:]$/
                  and $c ne $now) {
                $now = $c;
            }
            elsif ($c eq $now) {
                return undef;
            }

            # Чтение ключа или зачения и запись их в хэш
            if ($c =~ /^[^,:]$/) {
                if ($now ne ':') {
                    $key .= $c;
                }
                if ($now eq ':') {
                    $value .= $c;
                }
            }
            elsif ($c eq ',' || $i == $ln) {
                $h->{$key} = $value;
                $key = '';
                $value = '';
            }
        }

        return bless $h, $class;
    }

}



1;
