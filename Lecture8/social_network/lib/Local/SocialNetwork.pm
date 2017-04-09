package Local::SocialNetwork;

use 5.010;
use strict;
use warnings;

use DBI;
use DDP;
use YAML;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my $config = YAML::LoadFile("$FindBin::Bin/../etc/conf.yaml");



our $dbh = DBI->connect($config->{dsn}, $config->{userDB}, $config->{password})
                or die $DBI::errstr;

$dbh->do( "SET SESSION wait_timeout=30" );

=pod
if ( ! $dbh->ping ) {
    $dbh = $dbh->clone() or die "cannot connect to db";
}
$dbh->{mysql_auto_reconnect} = 1;

#say "dbh:";
#p $dbh;

=pod
sub import {
    my ( $class, %list ) = @_;
    my $caller = caller;

    {
      no strict 'refs';
      push @{"$caller\::ISA"}, 'Exporter';
    }

    {
      no strict 'refs';
      push @{"$caller\::EXPORT_OK"}, qw(friends nofriends num_handshakes);
    }

}
=cut

my $sth = $dbh->prepare( "SELECT * FROM users where id = ?" )
                or die $dbh->errstr;;
$sth->execute(1324) or die $dbh->errstr;;
my $hash_ref = $sth->fetchrow_hashref();
p $hash_ref;

sub friends {
    say "Start 'friends'";
    p @_;
    my $firstID  = shift;
    my $secondID = shift;
    say "List of mutual friends for $firstID and $secondID :";
    my $sth = $dbh->prepare( "SELECT * FROM users where id = ?" )
                    or die $dbh->errstr;;
    $sth->execute($firstID) or die $dbh->errstr;;
    my $hash_ref = $sth->fetchrow_hashref();
    p $hash_ref;

    1;
}

sub nofriends {
    say "It is nofriends";

    1;
}

sub num_handshakes {
    say "It is num_handshakes";
    1;
}

sub discon { $dbh->disconnect; }

1;
