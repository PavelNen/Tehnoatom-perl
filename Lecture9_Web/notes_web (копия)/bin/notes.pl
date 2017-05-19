#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Mojolicious::Lite;

# / (с проверкой подлинности)
#get '/' => 'index';

#my $route = post ''

app->start('Notes');
