package Local::MatrixMultiplier;

use strict;
use warnings;
use DDP;
use POSIX 'ceil';

sub mult {
    $|=1;
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];

    my $height_a = $#$mat_a;
    my $width_a  = $#{$mat_a->[0]};

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
    my $i = 0;   # Номер текущей умножаемой строки матрицы А
    my $j = 0;   # Номер текущего умножаемого столбца матрицы В
    my $elmnts = ($height_a + 1)*($height_a + 1);
    my $s = $elmnts/$max_child;

    # Определяю количество ячеек, которое должен посчитать один процесс
    # При не кратном
    my $forkSize = (($elmnts / $max_child) > 1 ) ? (ceil($elmnts / $max_child)) : 1;

    # Создаём потоки, пока не исчерпаем либо лимит, либо все элементы матрицы
    # Каждый форк считает минимум один элемент матрицы С
    my $numpid = 0;     # Счётчик запущенных процессов
    while ( $numpid <= $max_child and $numpid < $elmnts) {
        $numpid++;
        if ( my $pid = fork() ) {
            p $pid;
            # Один форк считает не более $forkSize ячеек С
            my $n = 1; # Счёт ячеек внутри форка
            while ( $n <= $forkSize
                        and $i != $height_a + 1 and $j != $height_a + 1) {
                # Наконец, перемножаем строку из А и столбец из В
                for my $k (0..$height_a) {
                    $res->[$i]->[$j] += $mat_a->[$k]->[$j] * $mat_b->[$i]->[$k];
                }
                # Идём по ячейкам матрицы C
                if ($j == $height_a) {
                    $j = 0;
                    $i++;
                }
                else {
                    $j++;
                }
                $n++;
            }

        }
        else {
            die "Cannot fork $!" unless defined $pid;
            exit;
        }


    }
    return $res;
}

1;
