function getDay(day,mon,year){
	var days = ["воскресенье","понедельник","вторник","среда","четверг","пятница","суббота"];
	day=parseInt(day, 10); //если день двухсимвольный и <10 
	mon=parseInt(mon, 10); //если месяц двухсимвольный и <10 
	var a=parseInt((14-mon)/12, 10);
	var y=year-a;
	var m=mon+12*a-2;
	var d=(7000+parseInt(day+y+parseInt(y/4, 10)-parseInt(y/100, 10)+parseInt(y/400, 10)+(31*m)/12, 10))%7;
	return days[d];
}