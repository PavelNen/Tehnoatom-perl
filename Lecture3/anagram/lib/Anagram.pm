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
    @result{decode('utf8', $$words_list[0])} = [decode('utf8', $$words_list[0])];	#Создаём первый ключ, закладываем фундамент
    
    for my $i (@$words_list)	#идём по списку слов из словаря
    {
	$word_dic = '';
	$c_word = lc( decode('utf8', $i)); #current word
	
	my $f_glob = 0; # $c_word ещё нет в %result (0) или оно уже там есть (1)
	
	for my $key (keys %result)	#Просматриваем целевой хэш
	{    
	    my $e = 0; #Есть ли уже слово в массиве анаграмм слова $key (1) или нет (0)
	    
	    if (length $c_word == length $key)
	    {
		my $c_w_o_r_d = join ',', sort split //, $c_word;
		my $k_e_y = join ',', sort split //, $key;
# 		say $k_e_y;	
		
		if ($k_e_y eq $c_w_o_r_d && !($c_word ~~ @{@result{$key}}))
		{
		      push @result{$key}, $c_word;
		      $f_glob = 1;
		}
	    }
	 }    
	if (!$f_glob) {@result{$c_word} = []; push @result{$c_word}, $c_word;}
    }
    
    for my $key (keys %result)
    {
	if ($#{@result{$key}} == 0) {delete $result{$key};}
	else {@{@result{$key}} = sort @{@result{$key}};}
    }

    return \%result;
}

1;
