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
    my $wordsList = shift;
    my %result;

    my $wordDic;	#Массив для букв слова из словаря
    my $wordKey;	#Массив для букв ключа

    my $cWord;	#Для перевода слова в асски

    for my $i (@$wordsList)	#идём по списку слов из словаря
    {
	$cWord = lc( decode('utf8', $i)); #current word

		my $splited = join ',', sort split //, $cWord;

		if (exists $result{$splited} && !($cWord ~~ @{@result{$splited}})) {
		      push @result{$splited}, $cWord;
		}
		else {
            @result{$splited} = [];
            push @result{$splited}, $cWord;
        }
    }

    for my $key (keys %result) {
	    if ($#{@result{$key}} == 0) {
            delete $result{$key};
        }
	    else {
	        @{@result{$key}} = sort @{@result{$key}};
	        $result{$result{$key}->[0]} = $result{$key};
	        delete $result{$key};
	    }
    }

    return \%result;
}

1;
