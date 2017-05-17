#!/usr/bin/env perl
use 5.020;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use Getopt::Long;
use DDP;

use DBI::ActiveRecord;
use Local::

# На вход принимается строка вида
# album insert [name] [county]

my $end = 0;

while ( not $end ) {
    say "Выбери таблицу: 1) track, 2) album, 3) artist";

    ONE: {
        my $line = <>;
        return if $line eq "exit";
        if ($line == 1 or $line eq "track") {
            
        }
        elsif ($line == 2 or $line eq "album") {

        }
        elsif ($line == 3 or $line eq "artist") {

        }
        else {
            say "Ошибка, повтори ввод";
            redo;
        }
    }
}

1;
