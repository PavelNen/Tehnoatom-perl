package DeepClone;

use 5.010;
use strict;
use warnings;
use Switch;
use DDP;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

our $i;
our %refarr=(); # массив со ссылками
our $k = 0;	#была ли ссылка на функцию

sub clone {
	my $orig = shift;
	my $cloned;
	
	if ($k ==1) {return undef; exit;} 
	
	switch(ref $orig)
	{
		case ''           {$cloned = $orig; }
		
		case 'ARRAY'      {if (!(exists $refarr{$orig}))
					  {$refarr{$orig} = 1; for $i (@$orig) {push @$cloned, clone($i);} }
				   else {$cloned = $orig;}}
				   
		case 'HASH'       {if (!(exists $refarr{$orig}))
					  {$refarr{$orig} = 1; for $i (keys %{$orig}) {$cloned->{$i} = clone($orig->{$i});}}
				   else {$cloned = $orig;}}
													   
		else              {$k = 1; $cloned = undef;}
	}
	
	if ($k ==1) {return undef; exit;} # Last fix
	
	return $cloned;
}

1;
