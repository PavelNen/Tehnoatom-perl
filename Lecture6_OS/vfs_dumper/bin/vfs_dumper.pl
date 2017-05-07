#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use 5.010;
use JSON::XS;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use VFS;
use DDP;
use Encode qw(encode decode);

our $VERSION = 1.0;

binmode STDOUT, ":utf8";

unless (@ARGV == 1) {
	warn "$0 <file>\n";
}
say $ARGV[0];
open my $file, "<", "$FindBin::Bin/../$ARGV[0]" or die "Can't open file $ARGV[0]";

my $buf;
{
	local $/ = undef;
	$buf = <$file>;
}

# Вот досада, JSON получается трудночитаемым, совсем не как в задании.
# Но пришёл герой и всё исправил
say decode('utf8', JSON::XS::encode_json(VFS::parse($buf)));
