#!/usr/bin/perl

use strict;
use warnings;


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;


our $IP


sub parse_file {
    my $file = shift;

    # you can put your code here

    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file
	($IP_adress, $day, $mon, $year, $hh, $mm, $ss, $tzone, $req, $scode, $nofbytes, $refferer, $)
	$log_line =~ /^(\d+\.\d+\.\d+\.\d+) \[(\d{2})\/(\w{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2}) (\+\d{4})\] "([^"]+)" (\d{3}) (\d+) "([^"]+)" "([^"]+)" "([^"]+)"/;

    }

    close $fd;

    # you can put your code here

    return $result;
}

sub report {
    my $result = shift;

    # you can put your code here

}
