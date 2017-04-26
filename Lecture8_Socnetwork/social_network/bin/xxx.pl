
#Неудачные дубли
sub FindHisFriends {
    # Для num_handshakes
    # Рекурсивная функция поиска друзей и записи в соответствующих ключ
    # Вернёт минимальное количество рукопожатий между целевыми юзерами firstID и secondID,
    # либо -1, если ветвь не дойдёт до $secondID

    my $bundle = shift;
        $bundle++;
    my $rootID = shift;
    my $secondID = shift;
    my $subtree_of_friends = shift;
    my $who_exists_in_tree = shift;
    my $dbh = shift;

    print "$rootID -> ";

    my $We_found_him = 0; # 0 - не нашли второго друга, 1 - нашли
    my $Last_friend = 1; # Предположение, что юзер, которому будем искать друзей,
    # последний в своей ветви, иначе присвои 0, когда поймём, что это не так

    # Ищем всех друзей для $rootID
    my $query = "SELECT DISTINCT One, Two FROM users_relation
                    WHERE One = ? OR Two = ? ";
    my $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
    $sth_rel->execute( $rootID, $rootID ) or die $dbh->errstr;
    my $hash_ref = $sth_rel->fetchall_hashref('One');
    # Для каждого его друга повторим операцию поиска друзей
    for my $key (keys %{$hash_ref}) {
            my $nextrootID;

            if ( $hash_ref->{$key}{'Two'} == $rootID ) {
                $nextrootID = $hash_ref->{$key}{'One'};
            }
            elsif ( $hash_ref->{$key}{'One'} == $rootID ) {
                $nextrootID = $hash_ref->{$key}{'Two'};
            }

            if (! ( exists $who_exists_in_tree->{$hash_ref->{$key}{'One'}} ) ) {

                $subtree_of_friends->{$nextrootID} = {};
                $who_exists_in_tree->{$nextrootID} = $bundle;
                if ( $nextrootID != $secondID ) {
                    $We_found_him =
                        FindHisFriends($bundle, $nextrootID, $secondID, $subtree_of_friends->{$nextrootID}, $who_exists_in_tree, $dbh);
                    $Last_friend = 0;

                }
                else {
                  $We_found_him = 1;
                  $Last_friend = 1;
                }
            }
            elsif ( ( exists $who_exists_in_tree->{$hash_ref->{$key}{'One'}} )
                      && $nextrootID == $secondID ) {

                        $subtree_of_friends->{$nextrootID} = {};
                        $who_exists_in_tree->{$nextrootID} = $bundle;
                        $Last_friend = 1;
                        $We_found_him = 1;
            }
    }

    if ( $We_found_him == 1 ) { return $bundle; }
    else { return -1; }

}
# С рекурсией
sub num_handshakes {
    say "It is num_handshakes";

    my $firstID  = shift; #Первый юзер из параметров
    my $secondID = shift; #Второй юзер

    print "$firstID -> ";

    my $tree_of_friends = {
        $firstID => {} # Дерево друзей начиная с firstID
    };

    my $who_exists_in_tree = { $firstID => '0', }; #хэш со списком всехкто уже есть в дереве, чтобы не запутывались ветви и можно было дойти до конца

    #Выберем в базе данных все пары с юзером $firstID
    my $query = "SELECT DISTINCT One, Two FROM users_relation
                    WHERE One = ? OR Two = ? ";
    my $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
    $sth_rel->execute( $firstID, $firstID ) or die $dbh->errstr;
    my $hash_ref = $sth_rel->fetchall_hashref('One');

    # Пойдём по хэшу с полученными парами
    for my $key (keys %{$hash_ref}) {
        # Выделим друга $rootID для юзера $firstID из пары $key,
        # он будет ключом для хэша уже своих друзей
        my $rootID;

        if ($hash_ref->{$key}{'Two'} == $firstID) {
            $rootID = $hash_ref->{$key}{'One'};
        }
        else { $rootID = $hash_ref->{$key}{'Two'}; }

        # Запишем друга в хэш со всеми юзерами, которые нам встретятся в дереве
        $who_exists_in_tree->{$rootID} = 1;

        # Теперь будем строить хэш, - искать друзей, для друга юзера
        my $We_found_him = FindHisFriends(0, $rootID, $secondID, $tree_of_friends->{$firstID}, $who_exists_in_tree, $dbh);

        p $tree_of_friends;

        if ( $We_found_him > 0 ) {
            return {"Num_handshakers" => $We_found_him, };
        }
        else {
            return {"Num_handshakers" => "Между ними НЕТ связи", };
        }

    }

}

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
