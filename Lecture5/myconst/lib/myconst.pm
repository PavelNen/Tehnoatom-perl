package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';

use Exporter 'import';

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';



our @EXPORT = 'PI';

sub PI {3.14}
#our %EXPORT_TAGS = import();


1;
