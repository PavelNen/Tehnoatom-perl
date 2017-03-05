package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	# ...
	#	push @res,[ "from_name", "to_name" ];
	# ...
	
	#Рассчёт итогового количества пар, оно равно количеству всех участников
	my $k = 0;
#	p @members;
	for my $mem (@members) {
	    ref $mem eq 'ARRAY' ? $k += 2: $k++;
	}
	#конец----------------
	

	my %hash = ();	#Хэш с парами дарителей и принимающих подарки
	my $size = $#members+1;  #Размер массива с участниками
	
	
	my $from_supr; my $to_supr; #Номера супругов в паре
	
	my $from; #Номер случайного элемента масива @members в качестве дарителя
	#Если в ячейке массива супруги, то нужно взять случайного супруга с номером 0 или 1, иначе -1
#	if (ref \@members[$from] eq "ARRAY") {$from_supr = int(rand 1);} else {$from_supr = -1; }
	my $to; #То же для принимающего подарок
#	if (ref \@members[$from] eq "ARRAY") {$to_supr = int(rand 1);} else {$to_supr = -1;}
#	say $k;
	#Начинаем составлять список (хэш) Даритель => Принимающий
	my $from_name; my $to_name;   #Имена пар
	
	my $i = 0;
	
	while($i<$k){
	    $from = int(rand $size);
	    if (ref $members[$from] eq 'ARRAY') { $from_supr = int(rand 2)} else {$from_supr = -1;}
	    $to = int(rand $size);
	    if (ref $members[$to] eq 'ARRAY') {$to_supr = int(rand 2)} else {$to_supr = -1;}
	   # print "$i ";
	    if ($from != $to){
	    
		#Если нет ещё такого дарителя, либо если он не получал от другого подарка, которому собирается подарить,
		#то записываем в хэш, иначе подбираем заново
		
		
		if ($from_supr == -1) {$from_name = $members[$from];} else {$from_name = $members[$from][$from_supr];}
		if ($to_supr == -1) {$to_name = $members[$to]} else {$to_name = $members[$to][$to_supr];}
		
		if (!(exists $hash{$from_name}))
		{
		    my $f = 0;
		    for my $value (values %hash) {$f = 1 if $value eq $to_name && $hash{$to_name} eq $from_name}
		    if (!$f) {
			$hash{$from_name} = $to_name;
			$i++; #Счётчик прибавляется только после успешного образования пары
		    }
		    
		}
	
	    }
	    else {redo;}
	    
	}
	
	for my $key (keys %hash) {push @res,[ $key, $hash{$key} ];}

	return @res;
}

1;
