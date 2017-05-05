#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use Getopt::Long;

local $SIG{INT} = \&CtrlC;
our $i     = 0;     # Счётчик сигналов Ctrl+C
my $sumlth = 0;     # Сумма длин строк
my $numstr = 0;     # Счётчик строк

my $file;
GetOptions("file=s" => \$file);

print STDOUT "Get ready\n";
my $fh;
if ( open $fh, '>', "$file" ) {
    select($fh);
    while (<STDIN>) {
        if ($i == 1) {
            $i--;   # Если повторно не нажали Ctrl+C, то сбрасываем счётчик
        }
        my $s = $_;
        chomp $s;
        say $s;
        $sumlth += length $s;
        $numstr++;
    }

    select(STDOUT);
    my $avg = $sumlth / $numstr; # Средняя длина строк
    say "$sumlth $numstr $avg";

    close $fh;
}

sub CtrlC {
    $i++;
    if ($i == 1) {
        select(STDERR);
        print "Double Ctrl+C for exit";
        select($fh);
    }
    if ($i == 2) {
        select(STDOUT);
        my $avg = $sumlth / $numstr;
        say "$sumlth $numstr $avg";
        exit 1; # Выход без сообщений
    }
}
