#!/usr/bin/perl

use 5.020;
use strict;
use warnings;
use Getopt::Long;
use IO::Handle;
STDOUT->autoflush(1);
STDERR->autoflush(1);

local $SIG{INT} = \&CtrlC;
our $i = 0; # Счётчик нажатий Ctrl+C
my $sumlth = 0; # Сумма длин строк
my $numstr = 0; # Счётчик строк

my $file;
GetOptions("file=s" => \$file);

print STDOUT "Get ready\n";
my $fh;
if ( open $fh, '>', "$file" ) {


select($fh);
while (<STDIN>) {
    if ($i == 1) {
        $i--;
    }
    my $s = $_;
    chomp $s;
    say $s;
    $sumlth += length $s;
    $numstr++;
}

select(STDOUT);
my $avg = $sumlth / $numstr;
#my $bytes = -s $fh;
say "$sumlth $numstr $avg";

close $fh;
}
else {
    #print '';
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
        #my $bytes = -s $fh;
        say "$sumlth $numstr $avg";
        die '';
    }
}
