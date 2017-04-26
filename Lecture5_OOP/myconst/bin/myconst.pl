#!/usr/bin/perl
use 5.010;

#use lib '/lib/';
#BEGIN { push(@INC, 'lib/'); }
use FindBin;
use lib "$FindBin::Bin/../lib/";
use strict;
no strict 'subs';
no strict 'refs';
use warnings;
use DDP;

use myconst math => {PI => 3.14, STRING => 'some string'};

say PI();
say STRING();
#p %{"::"};
#p @main::ISA;
1;
