#!/usr/bin/env perl
use 5.010;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use Getopt::Long;
use Switch;
use DDP;
use Encode qw(encode decode);

use DBI;
use YAML;
use JSON;

require Local::SocialNetwork;

=encoding utf8

=head1 NAME

social_network - main window

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my @user = ();
GetOptions ( "user=s" => \@user );

#p @ARGV;
#p $config;
#my $cmd = $ARGV[0];
my $result;

switch ($ARGV[0]) {
    case 'friends' { $result = Local::SocialNetwork::friends(@user) }
    case 'nofriends' { $result = Local::SocialNetwork::nofriends() }
    case 'num_handshakes' { $result = Local::SocialNetwork::num_handshakes(@user) }
    #case 'exit' { exit; }
    else { say 'I don\'t understand you, please, repeat'}
}

#p $result;
say Local::SocialNetwork::encodeJSON($result);

Local::SocialNetwork::discon();

1;
