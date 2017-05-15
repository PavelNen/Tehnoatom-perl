package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent;
use AnyEvent::HTTP;
use URI;

=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора параллельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut




sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";

    local $AnyEvent::HTTP::MAX_PER_HOST = $parallel_factor;

    my $total_size = 0;
    my @top10_list;

    # Ссылки будут храниться в стеке
    my @urls   = ($start_page);
    my $result = {};

    my $cv = AnyEvent->condvar;


    my $count = 0;
    my $url;

    while ( 0 <= $#urls and ( keys %$result ) <= 1000 ) {
        my $cv = AnyEvent->condvar;
        my $br = $#urls + 1;
        for (1..$br) {
        my $url = pop @urls;
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
                                          && $_ =~ /^\Q$start_page\E/
                                      }
                                      map {
                                        my $uri =
                                          URI->new_abs( $_, $head->{'URL'} );
                                        "$uri";
                                    } $content =~ m/href="([^"#]+)\??"/g
                                };

                                $cv->end;
                            }
                        );
                    }

                    $cv->end;
                }
            );
        };
        $cv->recv;
    };

    my @rating = sort { $result->{$b} <=> $result->{$a} } keys %$result;

    @top10_list = @rating[0..9];

    for my $values (values %$result) {
        $total_size += $values;
    }

    return $total_size, @top10_list;
}

1;
