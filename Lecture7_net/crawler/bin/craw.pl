#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

# Подключаем AE
use AnyEvent;

# Асинхронный юзер-агент
use AnyEvent::HTTP;
use DDP;
use URI;
use AE;

sub async {
    my $cb = pop;
    my $w;
    $w = AE::timer rand(0.1), 0, sub {
        undef $w;
        $cb->();
    };
    return;
}

$AnyEvent::HTTP::MAX_PER_HOST = 1000;

my $base = 'https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler/';

# Ссылки будут храниться в стеке
my @urls   = ($base);
my $result = {};

my $cv = AE::cv;
$cv->begin;

my $count = 0;
my $url;

my $next;
$next = sub {
    return if 0 > $#urls or ( keys %$result ) > 1000;
    my $url = pop @urls;
    $cv->begin;
    async sub {

        # количество запросов
        #$url = pop @urls;
        #print "New event: GET => $url\n";
        $cv->begin;

        http_request(
            HEAD => $url,
            sub {

                my $headers = $_[1];

                #print "Headers of $url: $headers\n";

                #p $headers;

                if ( $headers->{'content-type'} =~ /text\/html/ ) {

                    $cv->begin;
                    http_request(
                        GET => $url,
                        sub {
                            my ( $content, $head ) = @_;
                            #p $head;

                            # Записываем размер страницы,
                            # которую парсит next
                            $result->{"$url"} = length $content;

                            if ( $content =~ m/href="[^"#]+"/ ) {
                                # Ищем в $content, если они там есть,
                                # уникальные ссылки,
                                # которые начинаются на URL.
                                # Относительные ссылки переводим
                                # в абсолютные
                                push @urls,
                                grep {
                                    !( exists $result->{"$_"} )
                                      && $_ =~ /^$base/
                                  }
                                  map {
                                    my $uri =
                                      URI->new_abs( $_, $head->{'URL'} );
                                    "$uri";
                                  } $content =~ m/href="([^"#]+)"/g
                            };



                            $next->();
                            $cv->end;
                        }
                    );
                }

                $cv->end;
            }
        );

        $next->();
        $cv->end;
    };
};

$next->() for 1 .. 100;

$cv->end;
$cv->recv;
#p $result;
#say scalar( keys %$result );
#p @urls;

my @rating = sort { $result->{$b} <=> $result->{$a} } keys %$result;
my @top = @rating[0..9];
p @top;

my $sum = 0;

for my $values (values %$result) {
     $sum += $values;
}
$sum = int $sum/1024;
say "$sum kBytes";

1;
