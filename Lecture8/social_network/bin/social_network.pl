#!/usr/bin/env perl
use 5.010;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use Getopt::Long;
use DDP;
use Encode qw(encode decode);

#use DBI;
use YAML;
use JSON;

use Local::SocialNetwork;

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

if ($#user > 0 && $user[0] eq $user[1] ) { die "Ошибка: Ты ввёл одного и того же человека"; }


my $session = Local::SocialNetwork->new();

my $result;

if ($ARGV[0] eq 'friends') {
    $result = $session->friends(@user);
}
  elsif ($ARGV[0] eq 'nofriends') {
      $result = $session->nofriends();
  }
    elsif ($ARGV[0] eq 'num_handshakes') {
        $result = $session->num_handshakes(@user);
    }
      else {
          die 'I don\'t understand you, please, repeat';
      }


say encodeJSON($result);

$session->DESTROY();

sub encodeJSON{
	my($arrayRef) = @_;
	my $JSONText= decode('utf8', JSON->new->utf8->encode($arrayRef));
	return $JSONText;
}

1;
