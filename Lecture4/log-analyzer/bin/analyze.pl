#!/usr/bin/perl
use 5.010;

use strict;
use warnings;
use Time::Local;
use diagnostics;
use DDP;
use Switch;


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

# Функция замены названия месяца на его номер
sub mtod {
  switch (shift){
    case 'Jan' {return 1;}
    case 'Feb' {return 2;}
    case 'Mar' {return 3;}
    case 'Apr' {return 4;}
    case 'May' {return 5;}
    case 'Jun' {return 6;}
    case 'Jul' {return 7;}
    case 'Aug' {return 8;}
    case 'Sep' {return 9;}
    case 'Oct' {return 10;}
    case 'Nov' {return 11;}
    case 'Dec' {return 12;}
  }
}

=head1 parse_file(file)
  Функция записывает результат парса в хеш %{$result}.
  Ключом является total или IP адресс. Значениями - названия столбцов будущей таблицы.
  Но под ключём total есть одно отличие. Под ключом $data_code есть ещё хеш,
  в котором ключи это коды ошибок, а значения - килобайты. Это нужно для сортировке по кодам при выводе.
=cut

sub parse_file {
    my $file = shift;

    my $result; # Ссылка на хеш
    my $time; my $timemin; my $timemax;
    my ($IP, $day, $mon, $mo, $year, $hh, $mm, $ss, $tzone, $req, $code, $nofbytes,$refferer, $uagent);
    my $cratio = 1;

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";


    while (my $log_line = <$fd>) {
      # Парсим строку
      ($IP,
		    $day, $mon, $year,
		      $hh, $mm, $ss, $tzone,
		        $req, $code, $nofbytes,
		          $refferer, $uagent, $cratio) =
		  $log_line =~ /^(\d+\.\d+\.\d+\.\d+) \[(\d{2})\/(\w{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2}) (\+\d{4})\] "(.+)" (\d{3}) (\d+) "(.+)" "(.+)" "(.+)"$/;
      if ($cratio eq '-') {$cratio = 1;}

      $mo = mtod($mon);
      #$day = 0 + $day;
      say join " ", (0 + $hh, 0 + $mm, 0+$ss, 0+$day, 0+$mo, $year);
      $time = timelocal($ss, $mm, $hh, $day, $mo, $year);

      $result->{'total'}{'count'} += 1;
    #  p $result->{'total'}{'count'};
      $result->{$IP}{'count'} += 1;

      if ($result->{'total'}{'count'} == 1) {
        $timemin = $time; $timemax = $time;
        $result->{'total'}{'avg'} = 0;
        $result->{$IP}{'avg'} = 0;
      }
      else {
        if ($time < $timemin) {$timemin = $time;}
        if ($time > $timemax) {$timemax = $time;}
        if ($timemax == $timemin) {
          $result->{'total'}{'avg'} = 0;
          $result->{$IP}{'avg'} = 0;
        }
        else {$result->{'total'}{'avg'} = 60 * $result->{'total'}{'count'} / ($timemax - $timemin);
        $result->{$IP}{'avg'} = 60 * $result->{$IP}{'count'} / ($timemax - $timemin);}
        say "$timemin $timemax $result->{'total'}{'avg'} $result->{$IP}{'avg'}";
      }

      if ($code == 200) {
        $result->{'total'}{'data'} += $nofbytes * $cratio / 1024;
        $result->{$IP}{'data'} += $nofbytes * $cratio / 1024;
      }

      $result->{'total'}{'data_code'}{$code} += $nofbytes / 1024;
      $result->{$IP}{$code} += $nofbytes / 1024;
  #say "$timemin $timemax";
    }

    close $fd;



    # you can put your advt here

    return $result;
}

sub report {
    my $result = shift;
    #say join "\t", keys %{$result->{'total'}} ;
    print "IP\tcount\tavg\tdata\tdata_";
    say join "\tdata_",
      sort keys %{$result->{'total'}{'data_code'}};
    my $i = 0;

    for my $key (sort {$result->{$b}{'count'} <=>  $result->{$a}{'count'}} keys %{$result}) {
      $i++;
      #IP count avg data
      print "$key\t" . $result->{$key}{'count'};
      print "\t";
      printf "%.2f" , $result->{$key}{'avg'};;
      if (exists $result->{$key}{'data'}) {print "\t" . int($result->{$key}{'data'});}
        else {print "\t0";}
      #data_xxx data_xxx data_xxx....
      for my $data_key (sort keys %{$result->{'total'}{'data_code'}}){
        if (exists $result->{$key}{$data_key}) { print "\t"; print int($result->{$key}{$data_key});}
          else {print "\t0";}
      }
      print "\n";
      exit if $i == 11;
    }

    # you can put your advt here

}
