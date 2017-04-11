
#Неудачные дубли


sub nofriendsxxx {
    my @result = ();
    our $test;
    say "Who has no friends?";

    #Так как мой ноут не выдерживает нагрузку при обработке
    #запроса SELECT одновременно к двум таблицам целиком,
    #то буду обрабатывать таблицу users по 10000 записей (или сколько останется)
    # Идея - как только натнёмся на строчку, где есть текущий ID
    # Другая - идея - записать в хэш все ID из users_realtion!!!!!
    my $rv = 1;
    my $cloud = 0; # тьма = 10000

    # Scan users_realtion
    my $query = "SELECT * FROM users_realtion";
    my $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
    $sth_rel->execute($hash_ref->{$key}{'id'}, $hash_ref->{$key}{'id'}) or die $dbh->errstr;

    my $hash_ref_rel = $sth_rel->fetchrow_hashref;


    # Scan users
    my $sth_usr = $dbh->prepare( "SELECT * FROM users" )
                        or die $dbh->errstr;
    #while ($rv == 1) {
        my $hash_ref = {};
        #берём очвередную тьму юзеров
        say "\ncloud = $cloud; ";

        $rv = $sth_usr->execute or die $dbh->errstr;
        $hash_ref = $sth_usr->fetchall_hashref('id');
=pod
        #Собираем ID юзеров в массив
        my @users_array_ID = 0;
        for my $key (keys %{$hash_ref}) {
            push @users_array_ID, $hash_ref->{$key};
        }
=cut
        my $i = 0;
        for my $key (keys %{$hash_ref}) {
            #print "ID " . $hash_ref->{$key}{'id'};
            $i++;
            print "$i.";
            $sth_rel->execute($hash_ref->{$key}{'id'}, $hash_ref->{$key}{'id'}) or die $dbh->errstr;
            my $hash_ref_usr = {};
            $hash_ref_usr = $sth_rel->fetchall_hashref('id');
            $test = $hash_ref_usr;

            if ( 0 == (keys %{$hash_ref_usr})  ) {
                push @result, $hash_ref->{$key};

                #print " is alone(((";
            }
            #else { print " has friends!"; }
            #print "\t";
        }

=pod
        # Кого нет в таблице дружбы, того записываем в массив
        if ($#users_array_ID > 0) {
            my $query = "SELECT * FROM users_realtion where id = ? ";
              for (1..$#users_array_ID) {
                $query .= " OR id = ?";
            }
        }
        $sth = $dbh->prepare( $query ) or die $dbh->errstr;
        $sth->execute(@users_array_ID) or die $dbh->errstr;
        $hash_ref = $sth->fetchall_hashref('id');
=cut

    #$cloud += 10000;
    #}
    print "\n";
    p $test;

    return \@result;
}
