#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use DBI;
use DDP;
use YAML;

=encoding utf8

=head1 NAME

InsertDB - заполняет таблицу users_realtion огромным количеством строк

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

open my $fi, "<", "$FindBin::Bin/../etc/user_relation" or die "Can't open file: $!";

my $config = YAML::LoadFile("$FindBin::Bin/../etc/conf.yaml");

our $dbh = DBI->connect($config->{dsn}, $config->{userDB}, $config->{password})
                or die $DBI::errstr;

$dbh->do( "SET SESSION wait_timeout=30" );

my $sth = $dbh->prepare( "INSERT INTO users_realtion (One, Two) VALUES (?, ?)" )
                or die $dbh->errstr;

say "Start";
my $i = 0;
while (my $str = <$fi>) {
    $i++;
    $str =~ /^(\d+) (\d+)$/;
    $sth->execute($1, $2) or die $dbh->errstr;
    if ($i % 5000 == 0) { say "Done $i"; }
}

$dbh->disconnect;

close $fi;

1;
