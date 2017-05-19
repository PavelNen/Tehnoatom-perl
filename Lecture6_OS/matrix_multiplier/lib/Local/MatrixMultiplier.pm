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

    my $forks = 0;
    # Работаем, пока не дойдём до последней ячейки
    while ( $i != $height_a + 1 and $j != $height_a + 1 ) {
        # Форкаем сколько нужно
        for ( 1 .. $max_child ) {

            $s--;

            pipe(PARENT_RDR, CHILD_WTR);
            pipe(CHILD_RDR,  PARENT_WTR);
            CHILD_WTR->autoflush(1);
            PARENT_WTR->autoflush(1);

            if ( my $pid = fork() ) {
                close PARENT_RDR;
                close PARENT_WTR;
                $forks++;

                print CHILD_WTR "$i $j\n";

                chomp($res->[$i]->[$j] = <CHILD_RDR>);
                # Идём по ячейкам матрицы C
                if ( $j == $height_a ) {
                    $j = 0;
                    $i++;
                }
                else {
                    $j++;
                }
                close CHILD_RDR; close CHILD_WTR;
                #waitpid($pid, 0);
            }
            else {
                die "Cannot fork: $!" unless defined $pid;

                my $line;
                chomp($line = <PARENT_RDR>);
                my ($ii, $jj) = $line =~ /(\d+)\s(\d+)/;

                my $res = 0;

                # перемножаем строку из А и столбец из В
                for my $k ( 0 .. $height_a ) {
                    $res += $mat_a->[$k]->[$jj] * $mat_b->[$ii]->[$k];
                }

                print PARENT_WTR "$res\n";
                close PARENT_RDR;
                close PARENT_WTR;
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

    return $res;
}

1;
