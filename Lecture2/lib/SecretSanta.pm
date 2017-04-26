package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
		
	#Рассчёт итогового количества пар, оно равно количеству всех участников
	my $k = 0;
#	p @members;
	for my $mem (@members) {
	    ref $mem eq 'ARRAY' ? $k += 2: $k++;
	}
	#конец----------------
	
	my $size = $#members+1;  #Размер массива с участниками
	
	
	my $i = 0;

	if ($k == 3 && $size == 2	#Условие,
	    ||
	    $k == 2 && $size == 1	#если участников
	    ||
	    $k == 1 && $size == 1)	#недостаточно для создания пар
	    {@res = ();}
	else{
	
	my %hash = ();	#Хэш с парами дарителей и принимающих подарки
			
	my $from_supr; my $to_supr; #Номера супругов в паре
	
	my $from; #Номер случайного элемента масива @members в качестве дарителя
		  #Если в ячейке массива супруги, то нужно взять случайного супруга с номером 0 или 1, иначе -1
	my $to;   #То же для принимающего подарок
	
	#Начинаем составлять список (хэш) Даритель => Принимающий
	my $from_name; my $to_name;   #Имена пар
	
	while($i<$k){
		START:
		$from = int(rand $size);
		if (ref $members[$from] eq 'ARRAY') { $from_supr = int(rand 2)} else {$from_supr = -1;}
		$to = int(rand $size);
		if (ref $members[$to] eq 'ARRAY') {$to_supr = int(rand 2)} else {$to_supr = -1;}
	    
		my $f1 = 0; # Флаг наличия дарителя в хэше в своей роли, а принимателя в своей
		my $f2 = 0; # Флаг наличия дарителя в хэше в роли принимателя, а принимателя в другой
		my $f3 = 0; # Флаг, дарил ли второй первому подарок?
		    
		if ($from != $to){	#Проверяем претендентов из разных ячеек @members
	    
			#Проверяем, чтобы не было уже такой пары, прямой или обратной,
			#и записываем в хэш, иначе подбираем заново
		
					
			if ($from_supr == -1) {$from_name = $members[$from];} else {$from_name = $members[$from][$from_supr];}
			if ($to_supr == -1) {$to_name = $members[$to]} else {$to_name = $members[$to][$to_supr];}
		
		    
			if (exists $hash{$from_name}) {$f1 = 1;} #Если этот даритель уже дарил
			for my $value (values %hash) {if ($value eq $to_name) {$f1 = 1;}} #Если этот получатель уже получал
		    		    
			if (exists $hash{$to_name}) {
				$f2 = 1; # Если этот получатель уже дарил
				if ($hash{$to_name} eq $from_name) {$f3 = 1;} #Если дарил текущему дарителю
			}
			for my $value (values %hash) {if ($value eq $from_name) {$f2 = 1;}} #Если этот даритель уже получал
			
		    
			if (!$f1 && !$f3 && ($i<$k-2 || $f2)) {
				$hash{$from_name} = $to_name;
				$i++; #Счётчик прибавляется только после успешного образования пары
				#p %hash if $i==5;
			}
			    elsif ((!$f1 && !$f2 || $f3) && $i == $k-2) {$i = 0; %hash = (); goto START;}#Когда остаётся заполнить одну или две пары,
				elsif ((!$f1 && !$f2 || $f3) && $i == $k-1) {$i = 0; %hash = (); goto START;}#появляются специальные ограничения для претендентов
			
	
		}
		    elsif ($i == $k-1 && $from == $to) { # Обрабатывем случаи, когда претенденты оказались из одной ячейки
		    
		
			    if (ref $members[$from] eq ''){
				    if (exists $hash{$from}) {$f1 = 1;}
				    for my $value (values %hash) {if ($value eq $to) {$f1 = 1;}}
				    
				    if (exists $hash{$from}) {$f2 = 1;}
				    for my $value (values %hash) {if ($value eq $to) {$f2 = 1;}}
				    if (!$f1) {$i = 0; %hash = (); goto START;}
			    }
				else{
					$from_name = $members[$from][0];
					$to_name = $members[$from][1];
					
					if (exists $hash{$from_name}) {$f1 = 1;}
					for my $value (values %hash) {if ($value eq $to_name) {$f1 = 1;}}
		
					if (exists $hash{$to_name}) {$f2 = 1;}
					for my $value (values %hash) {if ($value eq $from_name) {$f2 = 1;}}
					
					if (!$f1 && !$f2) {$i = 0; %hash = (); goto START;}
				}
		    }
			elsif ($i == $k-2  && $from == $to && ref $members[$from] eq 'ARRAY') {
				
				$from_name = $members[$from][0];
				$to_name = $members[$to][1];
		
				if (exists $hash{$from_name}) {$f1 = 1;}
				for my $value (values %hash) {if ($value eq $to_name) {$f1 = 1;}}
		    		   
				if (exists $hash{$to_name}) {$f2 = 1;}
				for my $value (values %hash) {if ($value eq $from_name) {$f2 = 1;}}
		  
				if (!$f1 && !$f2){$i = 0; %hash = (); goto START;}
			}
			    
		
	}
	for my $key (keys %hash) {push @res,[ $key, $hash{$key} ];}
	}
	
	
	return @res;
}

1;
