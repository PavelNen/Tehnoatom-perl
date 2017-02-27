#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Шифр Цезаря https://ru.wikipedia.org/wiki/%D0%A8%D0%B8%D1%84%D1%80_%D0%A6%D0%B5%D0%B7%D0%B0%D1%80%D1%8F

=head1 encode ($str, $key)

Функция шифрования ASCII строки $str ключем $key.
Пачатает зашифрованную строку $encoded_str в формате "$encoded_str\n"

Пример:

encode('#abc', 1) - печатает '$bcd'

=cut

sub encode {
    my ($str, $key) = @_;
    my $encoded_str = '';

    # ...
    # Алгоритм шифрования
    # ...
    
    my $l = length $str;
    my $a = '';
    
    for (my $i = 0; $i<$l; $i++) {
     $a = ord(substr $str, $i, 1);   #Посимвольно считываем строку и
     $a = ($a + $key) % 128;                 #"сдвигаем" аски код каждого символа
     $encoded_str = $encoded_str . chr($a);
    }
    
    print "$encoded_str\n";
}

#encode("Hello world!",3 );

=head1 decode ($encoded_str, $key)

Функция дешифрования ASCII строки $encoded_str ключем $key.
Пачатает дешифрованную строку $str в формате "$str\n"

Пример:

decode('$bcd', 1) - печатает '#abc'

=cut

sub decode {
    my ($encoded_str, $key) = @_;
    my $str = '';

    # ...
    # Алгоритм дешифрования
    # ...
    
    my $l = length $encoded_str;
    my $a = '';
    
    for (my $i = 0; $i<$l; $i++) {
     $a = ord(substr $encoded_str, $i, 1);
     $a = ($a - $key + 128) % 128;
     $str = $str . chr($a);
    }
    print "$str\n";
}

#decode("aBCcd!",1 );
1;
