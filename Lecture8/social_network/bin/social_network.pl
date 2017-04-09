#!/usr/bin/env perl
use 5.010;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use Getopt::Long;
use Switch;
use DDP;

use DBI;
use YAML;
use JSON;

require Local::SocialNetwork;


my @user = ();
GetOptions ( "user=s" => \@user );

#p @ARGV;
#p $config;
#my $cmd = $ARGV[0];

switch ($ARGV[0]) {
    case 'friends' { Local::SocialNetwork::friends(@user) }
    case 'nofriends' { Local::SocialNetwork::nofriends() }
    case 'num_handshakes' { Local::SocialNetwork::num_handshakes(@user) }
    #case 'exit' { exit; }
    else { say 'I don\'t understand you, please, repeat'}
}


sub encodeJSON{
	my($arrayRef) = @_;
	my $JSONText= JSON->new->utf8->encode($arrayRef);
	return $JSONText;
}

Local::SocialNetwork::discon();

1;
