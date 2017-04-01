package myconst;

use 5.010;
use strict;
no warnings;
use Scalar::Util 'looks_like_number';
use DDP;

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

sub import {
    my ( $class, %list ) = @_;
    my $caller = caller;

    {
      no strict 'refs';
      push @{"$caller\::ISA"}, 'Exporter';
    }
    #  p %list;

    # Пробегаем список (хэш) аргументов
    for my $key ( keys %list ) {

        # Проверяем на корректность имени ключи
        ( $key ne '' ) and ( ref $key eq '' ) or die;

      # Действия для значения-скаляра или -хэша
        if ( ref $list{$key} eq 'HASH' ) {
            for my $in_group ( keys %{ $list{$key} } ) {

                # Проверяем, что ключ не пустой
                $in_group ne '' or die;

     # Проверяем, что значение не ссылка, не undef
     # а что угодно другое
                ref $list{$key}{$in_group} eq ''
                  and $list{$key}{$in_group} ne ''
                  or die;
                {
                  no strict 'refs';
                  my $way = "$caller\::$in_group";
                  *{$way} = sub () { $list{$key}{$in_group} };

                  push @{"$caller\::EXPORT_OK"}, "$in_group";
                  push @{ ${"$caller\::EXPORT_TAGS"}{$key} }, "$in_group";
                  push @{ ${"$caller\::EXPORT_TAGS"}{'all'} }, "$in_group";
                }
            }
        }
        elsif ( ref $list{$key} eq '' and $list{$key} ne '' ) {
            {no strict 'refs';
              my $way = "$caller\::$key";
              *{$way} = sub () { $list{$key} };

              push @{"$caller\::EXPORT_OK"}, "$key";
              push @{ ${"$caller\::EXPORT_TAGS"}{'all'} }, "$key";
            }
        }
        else { die; }
    }
}

1;
__END__
