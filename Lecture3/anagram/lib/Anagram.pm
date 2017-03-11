package Anagram;

use 5.010;
use strict;
use warnings;
no warnings 'all';

#=encoding utf8
use utf8;
binmode(STDOUT,':utf8');
use Encode qw(encode decode);
use DDP;
=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

=pod

Создадим хэш из букв слова, где ключ-буква хранит значение - количество повторений этой буквы в слове.

Далее можем просто сравнивать такие хэши слов.

=cut

sub anagram {
    my $words_list = shift;
    my %result;
    
    my $word_dic;	#Массив для букв слова из словаря
    my $word_key;	#Массив для букв ключа
    
    my $c_word;	#Для перевода слова в асски
    
    for my $i (@$words_list)	#идём по списку слов из словаря
    {
	$c_word = lc( decode('utf8', $i)); #current word
	
		my $c_w_o_r_d = join ',', sort split //, $c_word;
		
		if (exists $result{$c_w_o_r_d} && !($c_word ~~ @{@result{$c_w_o_r_d}}))
		{
		      push @result{$c_w_o_r_d}, $c_word;

		}
		else {@result{$c_w_o_r_d} = []; push @result{$c_w_o_r_d}, $c_word;}
    }
    
    for my $key (keys %result)
    {
	if ($#{@result{$key}} == 0) {delete $result{$key};}
	else
	{
	    @{@result{$key}} = sort @{@result{$key}};
	    $result{$result{$key}->[0]} = $result{$key};
	    delete $result{$key};
	}
	
    }

    return \%result;
}

1;
