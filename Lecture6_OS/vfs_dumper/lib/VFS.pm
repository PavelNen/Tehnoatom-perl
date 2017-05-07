package VFS;
use utf8;
use Encode qw(encode decode);
use strict;
use warnings;
use 5.020;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';

use DDP;


sub mode2s {
    my $c = shift;

    my $h = {};
    (
        $h->{group}->{read}, $h->{group}->{write}, $h->{group}->{execute},
        $h->{user}->{read},  $h->{user}->{write},  $h->{user}->{execute},
        $h->{other}->{read}, $h->{other}->{write}, $h->{other}->{execute}
      )
      = map {
        if ( $_ == 1 ) {
            \1;
        }
        else {
            \0;
        }
      } unpack "x7aaaaaaaaa", $c;
    return $h;
}

sub parse {
    my $buf = shift;

    my $h = {};    # Хэш с деревом
    my @a = ();    # ссылки на каждый уровень до текущей директории
    my $lvl = -1;
    my $lastdir;
    my $lth = length $buf;
    my $eot = 0;    # Признак конца дерева
    my $i   = 0;    # Счётчик комманд

    while ( $buf and $eot != 1 ) {
        my $cmd = unpack "a", substr $buf, 0, 1, '';
        $i++;

        if ( $cmd eq 'D' ) {
            # Временная переменная для создания считываемой директории
            my $dir = {};
            $dir->{type} = 'directory';
            # Длина строки
            my $lname = unpack "n", substr $buf, 0, 2, '';
            # Имя директории
            my $name = unpack "A$lname", substr $buf, 0, $lname, '';
            $dir->{name} = decode( 'utf8', $name );
            # Права доступа
            my $mode = unpack "B16", substr $buf, 0, 2, '';
            $dir->{mode} = mode2s($mode);
            # Содержимое директории
            $dir->{list} = [];

            if ( $#a == -1 ) {
                $h = $dir; # Создание корневой директории
            }
            else {
                # Запись директории в текущую директорию
                $a[$lvl]->[ $#{ $a[$lvl] } + 1 ] = $dir;
            }

            $lastdir = $dir->{list};
        }

        if ( $cmd eq 'I' ) {
            if ( $i == 1 ) {
                die "The blob should start from 'D' or 'Z'";
            }
            push @a, $lastdir;
            $lvl++;
        }

        if ( $cmd eq 'F' ) {
            if ( $i == 1 ) {
                die "The blob should start from 'D' or 'Z'";
            }
            my $file = {};
            $file->{type} = 'file';
            # Длина строки
            my $lname = unpack "n", substr $buf, 0, 2, '';
            # Имя директории
            my $name = unpack "A$lname", substr $buf, 0, $lname, '';
            $file->{name} = decode( 'utf8', $name );
            # Права доступа
            my $mode = unpack "B16", substr $buf, 0, 2, '';
            $file->{mode} = mode2s($mode);
            # Размер файла
            my $size = unpack "N", substr $buf, 0, 4, '';
            $file->{size} = $size;
            # SH1
            my $hash = unpack "H*", unpack "A20", substr $buf, 0, 20, '';
            $file->{hash} = $hash;
            # Запись файла в текущую директорию
            $a[$lvl]->[ $#{ $a[$lvl] } + 1 ] = $file;
        }

        if ( $cmd eq 'U' ) {
            if ( $i == 1 ) {
                die 'Команда U не может быть первой!';
            }
            pop @a;
            $lvl--;
        }

        if ( $cmd eq 'Z' ) {
            $eot = 1;
        }

        if ( $buf and $cmd eq 'Z' ) {
            die "Garbage at the end of the buffer";
        }

    }

    return $h;
}

1;
