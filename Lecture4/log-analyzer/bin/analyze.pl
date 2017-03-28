#!/usr/bin/perl
use 5.010;

use strict;
use warnings;
use Time::Local;

#use diagnostics;
use DDP;
use Switch;
use POSIX;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

# Функция замены названия месяца на его номер

=head1 parse_file(file)
  Функция записывает результат парса в хеш %{$result}.
  Ключом является total или IP адресс. Значениями - названия столбцов будущей таблицы.
  Но под ключём total есть одно отличие. Под ключом $data_code есть ещё хеш,
  в котором ключи это коды ошибок, а значения - килобайты. Это нужно для сортировке по кодам при выводе.
=cut

sub parse_file {
    my $file = shift;

    my %abbr =
      qw(Jan 0 Feb 1 Mar 2 Apr 3 May 4 Jun 5 Jul 6 Aug 7 Sep 8 Oct 9 Nov 10 Dec 11);

    my $result;    # Ссылка на хеш
    my $time;
    my $timemin;
    my $timemax;
    my (
        $IP,       $day,      $mon,   $year, $hh,
        $mm,       $ss,       $tzone, $req,  $code,
        $nofbytes, $refferer, $uagent
    );
    my $cratio;

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

    while ( my $log_line = <$fd> ) {

        # Парсим строку
        # В строке 9465 лога ошибка формата в поле refferer, поэтому
        # пришлось одну регулярку оставить не в идеальном виде
        (
            $IP,       $day,      $mon,    $year, $hh,
            $mm,       $ss,       $tzone,  $req,  $code,
            $nofbytes, $refferer, $uagent, $cratio
        )
          = $log_line =~
/^(\d+\.\d+\.\d+\.\d+) \[(\d{2})\/(\w{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2}) (\+\d{4})\] "([^"]+?)" (\d{3}) (\d+) "(.+)" "([^"]+?)" "([^"]+?)"$/;

        if ( $cratio eq '-' ) { $cratio = 1; }

        $time = ceil(
            timelocal( 0 + $ss, 0 + $mm, 0 + $hh, 0 + $day, $abbr{$mon},
                0 + $year ) / 60 );    #Время в минутах

        $result->{'total'}{'count'} += 1;
        $result->{$IP}{'count'} += 1;

        # Записываем в какие минуты был запрос
        # Это нужно, так как в логе запросы
        # могут располагаться не по порядку времени.
        # А также считаем количество этих минут.
        if ( !(exists $result->{'total'}{'TIME'}{$time}) ) {
            $result->{'total'}{'TIME'}{$time} = 1;
            $result->{'total'}{'TIME'}{'count_of_min'} += 1;
        }

        if ( !(exists $result->{$IP}{'TIME'}{$time}) ) {
            $result->{$IP}{'TIME'}{$time} = 1;
            $result->{$IP}{'TIME'}{'count_of_min'} += 1;
        }

        # Подсчёт байтов по кодам
        if ( $code == 200 ) {
            $result->{'total'}{'data'} += int( $nofbytes * $cratio );
            $result->{$IP}{'data'} += int( $nofbytes * $cratio );
        }

        $result->{'total'}{'data_code'}{$code} += $nofbytes;
        $result->{$IP}{$code} += $nofbytes;

    }

    close $fd;

    # Расчёт среднего, время в минутах
    for my $keyIP ( keys %{$result} ) {

        $result->{$keyIP}{'avg'} =
          $result->{$keyIP}{'count'} /
            $result->{$keyIP}{'TIME'}{'count_of_min'};

    }

    return $result;
}

sub report {
    my $result = shift;

    say join "\t", qw/IP count avg data/, sort keys %{ $result->{'total'}{'data_code'} };
    my $i = 0;

    for my $key ( sort { $result->{$b}{'count'} <=> $result->{$a}{'count'} }
        keys %{$result} )
    {
        $i++;

        #IP count avg data
        print "$key\t" . $result->{$key}{'count'} . "\t";
        printf "%.2f", $result->{$key}{'avg'};
        if ( exists $result->{$key}{'data'} ) {
            print "\t" . int( $result->{$key}{'data'} / 1024 );
        }
        else { print "\t0"; }

        #data_xxx data_xxx data_xxx....
        for my $data_key ( sort keys %{ $result->{'total'}{'data_code'} } ) {
            if ( exists $result->{$key}{$data_key} ) {
                print "\t" . int( $result->{$key}{$data_key} / 1024 );
            }
            elsif ( exists $result->{$key}{'data_code'}{$data_key} ) {
                print "\t" . int( $result->{$key}{'data_code'}{$data_key} / 1024 );
            }
            else { print "\t0"; }
        }
        print "\n";
        last if $i == 11;
    }

}
