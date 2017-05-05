package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';

sub mode2s {
	# Тут был полезный код для распаковки численного представления прав доступа
	# но какой-то злодей всё удалил.

}

sub parse {
	my $buf = shift;

	my $h = {}; # Хэш с деревом
	#my $ch = \%h; # ссылка на текущюю директорию дерева
	my @a  = ($h); # ссылки на каждый уровень до текущей директории
	my $lvl = 0;
	my $lastdir;
	my $lth = length $buf;

	my $i = -1; # Номер последнего прочитанного символа строки
	while ($buf) {
		my $cmd = unpack "C", substr $buf, 0, 1, '';

		$i++;
		if ( $cmd eq 'D' ) {
			$a[$lvl] = {};
			$a[$lvl]->{type} = 'directory';
			my $lname = unpack "S2", substr $buf, 0, 2, ''; # Читаем длину строки
			$i += 2;
			my $name = unpack "a$lname", substr $buf, 0, $lname, ''; #S/a* # Читаем имя директории
			$i += $lname;
			$a[$lvl]->{name} = $name;
			my $mode = unpack "S2", substr $buf, 0, 2, ''; # Читаем права доступа
			$a[$lvl]->{list} = [];

			$lastdir = $a[$lvl]->{list}
		}

		if ( $cmd eq 'I') {
			
			$a[$lvl + 1]
			$lvl++;

		}

		if ( $cmd eq 'F') {
			$a[$lvl + 1] = {};
			$a[$lvl + 1]->{type} = 'directory';
			my $lname = unpack "S2", substr $buf, 0, 2, ''; # Читаем длину строки
			$i += 2;
			my $name = unpack "a$lname", substr $buf, 0, $lname, ''; #S/a* # Читаем имя директории
			$i += $lname;
			$a[$lvl + 1]->{name} = $name;
			my $mode = unpack "S2", substr $buf, 0, 2, ''; # Читаем права доступа
		}



		if ( $cmd eq 'U') {

		}

		if ( $cmd eq 'Z') {

		}

	}

	# Тут было готовое решение задачи, но выше упомянутый злодей добрался и
	# сюда. Чтобы тесты заработали, вам предстоит написать всё заново.
}

1;
