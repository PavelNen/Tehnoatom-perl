#!/usr/bin/perl

use 5.010;

use strict;
use warnings;

package Server;

use IO::Handle;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use Errno qw(EAGAIN EINTR);

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Util qw(WSAEWOULDBLOCK);
use AnyEvent::HTTP;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub start_listen
{
    my ($self, $host, $port) = @_;

    $self->{server} = tcp_server($host,
                                 $port,
                                 $self->_accept_handler(),
                                 \&prepare_handler);
}

sub prepare_handler
{
    my ($fh, $host, $port) = @_;
    #DEBUG &&
    warn "Listening on $host:$port\n";
}

sub _accept_handler
{
    my $self = shift;

    return sub {
        my ($sock, $peer_host, $peer_port) = @_;
        my $url = ''; # URL для текущей сессии
        #DEBUG &&
        warn "Accepted connection from $peer_host:$peer_port\n";
        return unless $sock;

        setsockopt($sock, IPPROTO_TCP, TCP_NODELAY, 1)
            or die "setsockopt(TCP_NODELAY) failed: $!";
        $sock->autoflush(1);

        $self->watch_socket($sock, $peer_host, $peer_port, $url);
    };
}

sub watch_socket
{
    my ($self, $sock, $peer_host, $peer_port, $url) = @_;

    my $headers_io_watcher;

    $headers_io_watcher = AE::io $sock, 0, sub {
        while (defined(my $line = <$sock>)) {
            $line =~ s/\r?\n$//;
            say "Received from $peer_host:$peer_port : [$line] ";

            if ($line eq 'FIN') {
                print $sock "Closing connection...\r\n";
                warn "Client $peer_host:$peer_port closed connection.\n";
                undef $headers_io_watcher;
            }
            elsif ($line =~ /^URL (https?:\/\/.+)$/) {
                $url = $1;
                print $sock "OK. Set URL [$url]\r\n";
            }
            elsif ($line eq 'HEAD' and $url ne '') {
                http_request
                    HEAD => $url,
                    sub {
                        my $header = $_[1];
                        my $size = 0;
                        for my $key (keys %$header) {
                            $size += length $key;
                            $size += length '' . $header->{$key};
                        }

                        print $sock "OK. $size bytes\n";
                        for my $key (keys %$header) {
                            print $sock "\x1b[33m\t$key: \x1b[37m" . $header->{$key} . "\x1b[0m\n";
                        }

                    };
            }
            elsif ($line eq 'GET' and $url ne '') {
                http_request
                    GET => $url,
                    sub {
                        my $body = shift;
                        print $sock "OK. " . int( length($body) / 1024 ) . " Kb\r\n";
                        print $sock "$body\n";
                    }
            }
            else {
                print $sock "Error: Incorrect input\r\n";
            }
        }

        if ($! and $! != EAGAIN && $! != EINTR && $! != WSAEWOULDBLOCK ) {
            undef $headers_io_watcher;
            die $!;
        } elsif (!$!) {
            undef $headers_io_watcher;
            die "client disconnected";
        }
    };
}

package main;

my $host = undef;
my $port = 1234;

my $server = Server->new();
$server->start_listen($host, $port);

AE::cv->recv();
