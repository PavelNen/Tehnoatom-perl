package Local::SocialNetwork;

use 5.020;
use strict;
use warnings;
no warnings 'experimental';
use Encode qw(encode decode);

#use Data::Dumper;
use Cache::Memcached::Fast;

use DBI;
use DDP;
use YAML;
use JSON;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my $config = YAML::LoadFile("$FindBin::Bin/../etc/conf.yaml");

our $dbh = DBI->connect($config->{dsn}, $config->{userDB}, $config->{password})
                or die $DBI::errstr;

$dbh->do( "SET SESSION wait_timeout=30" );

=pod
if ( ! $dbh->ping ) {
    $dbh = $dbh->clone() or die "cannot connect to db";
}
$dbh->{mysql_auto_reconnect} = 1;

#say "dbh:";
#p $dbh;
=cut

sub friends {
    my $firstID  = shift; #Первый юзер из параметров
    my $secondID = shift; #Второй юзер
    my %firstID_list = (); #Список (хэш) друзей первого
    my %secondID_list = (); #Список (хэш) друзей второго
    my %mutual_hash = (); #Список (хэш) общих друзей
    my @mutual_array_ID = (); #Массив списка ID общих друзей
    my @result = (); #Массив для итога в JSON

    my $They_are_friends = 0; # А вдруг они друг другу друзья?

    say "Список общих друзей для $firstID и $secondID в формате JSON:";

    #Собираем списки друзей для каждого отдельно
    #Сначала получаем все строки, содержащие любого из двух юзеров
    my $sth = $dbh->prepare( "SELECT * FROM users_relation where
                      One = ? OR Two = ? OR One = ? OR Two = ?" )
                        or die $dbh->errstr;
    $sth->execute($firstID, $firstID, $secondID, $secondID) or die $dbh->errstr;
    my $hash_ref = $sth->fetchall_hashref('id');

    #Затем уже разделяем хэш на два
    for my $key (keys %{$hash_ref})
    {
        # Проверка товарищей на дружбу
        if ($hash_ref->{$key}{One} == $firstID
              && $hash_ref->{$key}{Two} == $secondID
                || $hash_ref->{$key}{One} == $secondID
                  && $hash_ref->{$key}{Two} == $firstID) {
            $They_are_friends = 1;
        }

        # Если не оказалось, что друзья, то продолжаем
        if ($hash_ref->{$key}{One} != $hash_ref->{$key}{Two}) {

            #составляем список друзей первого юзера
            if ($hash_ref->{$key}{One} == $firstID) {
                $firstID_list{$hash_ref->{$key}{Two}} = $firstID;
            }
            if ($hash_ref->{$key}{Two} == $firstID) {
                $firstID_list{$hash_ref->{$key}{One}} = $firstID;
            }
            #составляем список друзей второго юзера
            if ($hash_ref->{$key}{One} == $secondID) {
                $secondID_list{$hash_ref->{$key}{Two}} = $secondID;
            }
            if ($hash_ref->{$key}{Two} == $secondID) {
                $secondID_list{$hash_ref->{$key}{One}} = $secondID;
            }
        }
    }

    #p %firstID_list;

    #Поиск ID общих друзей
    for my $key (keys %firstID_list) {
        if (exists $secondID_list{$key}) {
            push @mutual_array_ID, $key;
        }
    }
    #p @mutual_array_ID;
    #Сбор имени и фамилии для этих ID
    if ($#mutual_array_ID + 1 > 0) {
        my $query = "SELECT * FROM users WHERE id = ? ";
        for (1..$#mutual_array_ID) {
            $query .= " OR id = ?";
        }
        $sth = $dbh->prepare( $query ) or die $dbh->errstr;
        $sth->execute(@mutual_array_ID) or die $dbh->errstr;
        $hash_ref = $sth->fetchall_hashref('id');

        for my $key (keys %{$hash_ref}) {
            push @result, $hash_ref->{$key};
        }
    }

    #p @result;
    if ($They_are_friends) {say "$firstID и $secondID друзья!";}
    return \@result;
}

sub nofriends {
   my @result = ();
  our $test;
  say "Вот у кого нет друзей..:";

  my $query = "SELECT * FROM users
                  WHERE NOT id IN (SELECT DISTINCT One FROM users_relation)
                    AND NOT id IN (SELECT DISTINCT Two FROM users_relation)";
  my $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
  $sth_rel->execute or die $dbh->errstr;

  my $hash_ref_nofrnd = $sth_rel->fetchall_hashref('id');

  for my $key (keys %{$hash_ref_nofrnd}) {
      push @result, $hash_ref_nofrnd->{$key};
  }

  #p $hash_ref_rel;
  return \@result;
}


sub num_handshakes {
    # Здесь используется не дерево рукопожатий, а скорее пирамида
    # На каждой ступени находятся друзя юзеров с предыдущей ступени
    # Пирамида начинается с первого юзера $firstID,
    # На следующей ступени все его друзья


    my $firstID  = shift; #Первый юзер из параметров, он будет меняться
    my $lastID = shift; #Второй юзер
    say "Количество рукопожатий между $firstID и $lastID:";

    my $memd = Cache::Memcached::Fast->new({
        servers => [
            {address => 'localhost:11211', weight => 2.5},
            '192.168.254.2:11211',
            '/path/to/unix.sock'
        ],
        namespace => 'my:',
        connect_timeout => 0.2,
        # ...
    });


    my $We_found_him = 0; # Когда lastID найден
    my @gen_of_friends = ([$firstID]); # Матрица, в каждой строке люди одной степени знакомства с первым
    say "YES" if defined $memd->get('firstID');
    if ( defined $memd->get('firstID') &&
        ($firstID eq $memd->get('firstID')
          && $lastID eq $memd->get('lastID')
           || $firstID eq $memd->get('lastID')
                 && $lastID eq $memd->get('firstID') ) ) {
        say "YES!!!";
        @gen_of_friends = @{$memd->get('pyramid')};
        $We_found_him = $memd->get('W_f_h');
        goto FROM_MEMCACHED;
    }
    else {
        $memd->flush_all;
    }

    my $genID = $firstID; #То есть, он будет меняться
    my @all_friends = ($firstID); # Список всех найденых юзеров в пирамиде
    my $This_is_the_end = 0; # Для выхода из цикла в нужный момент
    my $cs = 0; # текущая строка, то есть номер поколения друзей

    while ( $This_is_the_end == 0) {
        my $current_gen = $gen_of_friends[$cs]; # ссылка на текущую строку
        #say "$cs now ";
        #p @gen_of_friends;
        #Найдём всех друзей всех друзей одного поколения
        my $query = "SELECT DISTINCT One, Two FROM users_relation
                      WHERE One IN (" . (join ',', ("?") x ($#$current_gen + 1))
                        . ") OR Two IN (" . (join ',', ("?") x ($#$current_gen + 1))
                          . ");";

        #Выберем в базе данных все пары с юзером $firstID

        my $sth = $dbh->prepare( $query ) or die $dbh->errstr;

        $sth->execute( @$current_gen, @$current_gen ) or die $dbh->errstr;

        $gen_of_friends[$cs+1] = [];

        while ( my $hash_ref = $sth->fetchrow_hashref ) {
            my $nextID;
            # Если человек
            if ( $hash_ref->{'One'} ~~ @$current_gen ) {
                $nextID = $hash_ref->{'Two'};
            }
            elsif ( $hash_ref->{'Two'} ~~ @$current_gen ) {
                $nextID = $hash_ref->{'One'};
            }
            if ( ! ($nextID ~~ @all_friends)) {
                push @all_friends, $nextID;
                push @{$gen_of_friends[$cs+1]}, $nextID;
            }
            if ( $nextID == $lastID ) {
                $This_is_the_end = 1;
                $We_found_him = $cs+1;

                last;
            }
        }

        $sth->finish();

        if ($#{$gen_of_friends[$cs+1]} == -1) {
          $This_is_the_end = 1;
          $We_found_him = -1;
        }

        #say join ' ', @{$gen_of_friends[$cs]};
        $cs++;

    }
    #say join ' ', @{$gen_of_friends[$cs]};
    #print Data::Dumper @gen_of_friends;

    #p @all_friends;

    # реализация кэша

    $memd->add_multi(['firstID', $firstID], ['lastID', $lastID],
                      ['pyramid', \@gen_of_friends], ['W_f_h', $We_found_him]);

    $memd->set_multi(['firstID', $firstID, 10], ['lastID', $lastID, 10],
                      ['pyramid', \@gen_of_friends, 10], ['W_f_h', $We_found_him, 10]);

    FROM_MEMCACHED:
    if ( $We_found_him > 0 ) {
        return {"Num_handshakes" => $We_found_him, };
    }
    else {
        return {"Num_handshakes" => "Между ними НЕТ связи", };
    }



}

sub discon { $dbh->disconnect; }

sub encodeJSON{
	my($arrayRef) = @_;
	my $JSONText= decode('utf8', JSON->new->utf8->encode($arrayRef));
	return $JSONText;
}

1;
