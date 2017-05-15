package Local::MatrixMultiplier;

use 5.020;
use strict;
use warnings;
use DDP;
use POSIX 'ceil';
use IO::Handle;

sub mult {
    $| = 1;
    my ( $mat_a, $mat_b, $max_child ) = @_;
    my $res = [];

    my $height_a = $#$mat_a;
    my $width_a  = $#{ $mat_a->[0] };

# Проверка матриц нв квадратность и одинаковость порядков
    for my $row (@$mat_a) {
        if ( $#{$row} != $height_a ) {
            die 'Строки матрицы А разной длины!';
        }
    }
    if ( $#$mat_a != $height_a ) {
        die 'Матрица А не квадртная!';
    }
    if ( $#$mat_b != $height_a ) {
        die 'Порядки матриц не совпадают!';
    }
    if ( $#$mat_b != $height_a ) {
        die 'Матрица В не квадртная!';
    }
    for my $row (@$mat_b) {
        if ( $#{$row} != $height_a ) {
            die 'Строки матрицы А разной длины!';
        }
    }

# А теперь начинается размножение процессов и распределение задач
    my $i = 0; # Номер текущей умножаемой строки матрицы А
    my $j = 0; # Номер текущего умножаемого столбца матрицы В
    my $elmnts = ( $height_a + 1 ) * ( $height_a + 1 );

    if ( $max_child > $elmnts ) {
        $max_child = $elmnts;
    }
    my $s = $elmnts; # Количество оставшехся процессов

# Определяю количество ячеек, которое должен посчитать один процесс
# При не кратном

# Создаём потоки

    my $forks = 0;

    open( my $fifo, ">", 'matrix.pipe' ); # Для фиксации результатов

    while ( $i != $height_a + 1 and $j != $height_a + 1 ) {
        for ( 1 .. $max_child ) {

            $s--;
            my ( $ri, $wi, $rj, $wj);
            pipe( $ri, $wi );
            pipe( $rj, $wj );

            if ( my $pid = fork() ) {

                $forks++;
                close $ri;
                close $rj;

                print $wi $i;
                print $wj $j;

                # Идём по ячейкам матрицы C
                if ( $j == $height_a ) {
                    $j = 0;
                    $i++;
                }
                else {
                    $j++;
                }

            }
            else {
                die "Cannot fork: $!" unless defined $pid;
                close $wi;
                close $wj;

                my $ii  = <$ri>;
                my $jj  = <$rj>;
                my $res = 0;

         # перемножаем строку из А и столбец из В
                for my $k ( 0 .. $height_a ) {
                    $res += $mat_a->[$k]->[$jj] * $mat_b->[$ii]->[$k];
                }

                print $fifo "$ii $jj $res\n";

                exit;
            }
        }
        # Если осталось мало ячеек, уменьшаем максимальное количество форков
        if ( $s < $max_child ) {
            $max_child = $s;
        }

        for ( 1 .. $forks ) {
            my $pid = wait();
        }
    }

    open( $fifo, "<", 'matrix.pipe' );
    while (<$fifo>) {
        $_ =~ /(\d+) (\d+) (\d+)/;
        $res->[$1]->[$2] = $3;
    }
    close $fifo;
    return $res;
}

1;
