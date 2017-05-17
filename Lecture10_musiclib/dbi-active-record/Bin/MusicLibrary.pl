#!/usr/bin/env perl
use 5.020;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use Getopt::Long;
use DDP;

use DBI::ActiveRecord;
use Local::MusicLib::Track;
use Local::MusicLib::Artist;
use Local::MusicLib::Album;

# На вход принимается строка вида
# album insert [name] [county]

my $obj;

my $end = 0;

until ( $end ) {
    say "Выбери таблицу: 1) tracks, 2) albums, 3) artists";

    ONE: {
        my $table = <>;
        return if $table eq "exit";
        if ($table == 1 or $table eq "tracks") {
            $table = "tracks";
            $obj = Local::Track->BUILD();
        }
        elsif ($table == 2 or $table eq "albums") {
            $table = "albums";
            $obj = Local::Album->BUILD();
        }
        elsif ($table == 3 or $table eq "artists") {
            $table = "artists";
            $obj = Local::Artist->BUILD();
        }
        else {
            say "Ошибка, повтори ввод";
            redo;
        }
    }

    say "Выбери операцию: 1) select, 2) insert, 3) update, 4) delete";
    my $cmd;

    TWO: {
        my $cmd = <>;
        return if $cmd eq "exit";
        if ($cmd == 1 or $cmd eq "select") {
            $cmd = "select";
        }
        elsif ($cmd == 2 or $cmd eq "insert") {
            $cmd = "insert";
        }
        elsif ($cmd == 3 or $cmd eq "update") {
            $cmd = "update";
        }
        elsif ($cmd == 4 or $cmd eq "delete") {
            $cmd = "delete";
        }
        else {
            say "Ошибка, повтори ввод";
            redo;
        }
    }


    THREE: {
        if ($line == 1 or $line eq "select") {
            say "Введи имя поля, список значений через запятую и лимит выборки";
            $line = <>;
            my ($field, $par, $lim) = $line =~ /^([^\s]+)\s(.+)\s([^\s+])$/ or redo;
            $par =~ s/\s//;
            my @param = split /,/, $par;
            my $res = $obj->select($field, \@param, $lim);

            say "ID\tNAME\tCOUNTRY\tTIMESTAMP" if $table eq 'artists';
            say "ID\tARTIST_ID\tNAME\tYEAR\tTYPE" if $table eq 'albums';
            say "ID\tALBUM_ID\tNAME\tDURATION\tTIMESTAMP" if $table eq 'tracks';

            for (@$res) {
                say join("\t", @$_);
            }
        }
        elsif ($line == 2 or $line eq "insert") {
            table 'albums';
        }
        elsif ($line == 3 or $line eq "update") {
            table 'artists';
        }
        else {
            say "Ошибка, повтори ввод";
            redo;
        }
    }
}

1;
