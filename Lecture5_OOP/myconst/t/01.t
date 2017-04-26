#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib/";

use strict;
use warnings;
use Test::More tests => 1;

use_ok('myconst');
