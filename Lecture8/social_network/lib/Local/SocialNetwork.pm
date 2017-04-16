package Local::SocialNetwork;

use 5.020;
use strict;
use warnings;
no warnings 'experimental';
use Encode qw(encode decode);

#use Data::Dumper;
use Cache::Memcached::Fast;


#use DBI;
use DDP;
use YAML;
use JSON;

use base qw/DBI DBI::db DBI::st/;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


=pod
if ( ! $dbh->ping ) {
    $dbh = $dbh->clone() or die "cannot connect to db";
}
$dbh->{mysql_auto_reconnect} = 1;

=cut

sub new {
    my $class = shift;
    my $config = YAML::LoadFile("$FindBin::Bin/../etc/conf.yaml");

    my $dbh =
        DBI->connect($config->{dsn}, $config->{userDB}, $config->{password})
          or die $DBI::errstr;

    $dbh->do( "SET SESSION wait_timeout=30" );

    my $self = bless $dbh, $class;

    return $self;
}

sub friends {
    my $dbh      = shift;
    my $firstID  = shift; #Первый юзер из параметров
    my $secondID = shift; #Второй юзер
    my %firstIdList   = (); #Список (хэш) друзей первого
    my %secondIdList  = (); #Список (хэш) друзей второго
    my @mutualArrayId = (); #Массив списка ID общих друзей
    my @result        = (); #Массив для итога в JSON

    my $theyAreFriends = 0; # А вдруг они друг другу друзья?

    say "Список общих друзей для $firstID и $secondID в формате JSON:";

    #Собираем списки друзей для каждого отдельно
    #Сначала получаем все строки, содержащие любого из двух юзеров
    my $sth = $dbh->prepare( "SELECT * FROM users_relation WHERE
                                one IN (?,?) OR two IN (?,?)" )
                                    or die $dbh->errstr;
    $sth->execute($firstID, $secondID, $firstID, $secondID)
            or die $dbh->errstr;
    my $hashRef = $sth->fetchall_hashref('id');

    #Затем уже разделяем хэш на два
    for my $key (keys %{$hashRef})
    {
        # Проверка товарищей на дружбу
        if ($hashRef->{$key}{one} == $firstID
              && $hashRef->{$key}{two} == $secondID
                || $hashRef->{$key}{one} == $secondID
                  && $hashRef->{$key}{two} == $firstID) {
            $theyAreFriends = 1;
        }

        # Если не оказалось, что друзья, то продолжаем
        if ($hashRef->{$key}{one} != $hashRef->{$key}{two}) {

            #составляем список друзей первого юзера
            if ($hashRef->{$key}{one} == $firstID) {
                $firstIdList{$hashRef->{$key}{two}} = $firstID;
            }
            if ($hashRef->{$key}{two} == $firstID) {
                $firstIdList{$hashRef->{$key}{one}} = $firstID;
            }
            #составляем список друзей второго юзера
            if ($hashRef->{$key}{one} == $secondID) {
                $secondIdList{$hashRef->{$key}{two}} = $secondID;
            }
            if ($hashRef->{$key}{two} == $secondID) {
                $secondIdList{$hashRef->{$key}{one}} = $secondID;
            }
        }
    }

    #Поиск ID общих друзей
    for my $key (keys %firstIdList) {
        if (exists $secondIdList{$key}) {
            push @mutualArrayId, $key;
        }
    }

    #Сбор имени и фамилии для этих ID
    if ($#mutualArrayId + 1 > 0) {
        my $query = "SELECT * FROM users WHERE id IN ("
                      . (join ',', ("?") x ($#mutualArrayId + 1)) . ") ";

        $sth = $dbh->prepare( $query ) or die $dbh->errstr;
        $sth->execute(@mutualArrayId) or die $dbh->errstr;
        $hashRef = $sth->fetchall_hashref('id');

        for my $key (keys %{$hashRef}) {
            push @result, $hashRef->{$key};
        }
    }

    if ($theyAreFriends) {say "$firstID и $secondID друзья!";}
    return \@result;
}

sub nofriends {
    my $dbh    = shift;
    my @result = ();

    say "Вот у кого нет друзей..:";

    my $query = "SELECT * FROM users
                    WHERE id NOT IN (SELECT DISTINCT one FROM users_relation)
                      AND id NOT IN (SELECT DISTINCT two FROM users_relation)";
    my $sth = $dbh->prepare( $query ) or die $dbh->errstr;
    $sth->execute or die $dbh->errstr;

    my $hashRefNoFrnd = $sth->fetchall_hashref('id');

    for my $key (keys %{$hashRefNoFrnd}) {
        push @result, $hashRefNoFrnd->{$key};
    }

    return \@result;
}


sub num_handshakes {
    # Здесь используется не дерево рукопожатий, а скорее пирамида
    # На каждой ступени находятся друзя юзеров с предыдущей ступени
    # Пирамида начинается с первого юзера $firstID,
    # На следующей ступени все его друзья

    my $dbh      = shift;
    my $firstID  = shift; #Первый юзер из параметров, он будет меняться
    my $lastID   = shift; #Второй юзер
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

    say "При запуске";
    p $memd->get("$firstID\_$lastID");

    my $weFoundHim = 0; # Когда lastID найден
    my @genFriends = ([$firstID]); # Матрица, в каждой строке люди одной степени знакомства с первым

    if ( defined $memd->get("$firstID\_$lastID")) {
        $weFoundHim = $memd->get("$firstID\_$lastID");
    }
    elsif (defined $memd->get("$lastID\_$firstID")) {
        $weFoundHim = $memd->get("$lastID\_$firstID");
    }
    else
    {

        my $genID      = $firstID; #То есть, он будет меняться
        my @allFriends = ($firstID); # Список всех найденых юзеров в пирамиде
        my $thisEnd    = 0; # Для выхода из цикла в нужный момент
        my $cs         = 0; # текущая строка, то есть номер поколения друзей

        while ( $thisEnd == 0) {
            my $currentGen = $genFriends[$cs]; # ссылка на текущую строку

            #Найдём всех друзей всех друзей одного поколения
            my $query = "SELECT DISTINCT one, two FROM users_relation
                      WHERE one IN (" . (join ',', ("?") x ($#$currentGen + 1))
                        . ") OR two IN (" . (join ',', ("?") x ($#$currentGen + 1))
                          . ");";

            #Выберем в базе данных все пары с юзером $firstID

            my $sth = $dbh->prepare( $query ) or die $dbh->errstr;

            $sth->execute( @$currentGen, @$currentGen ) or die $dbh->errstr;

            $genFriends[$cs+1] = [];

            while ( my $hashRef = $sth->fetchrow_hashref ) {
                my $nextID;
                # Если человек
                if ( $hashRef->{'one'} ~~ @$currentGen ) {
                    $nextID = $hashRef->{'two'};
                }
                elsif ( $hashRef->{'two'} ~~ @$currentGen ) {
                    $nextID = $hashRef->{'one'};
                }
                if ( ! ($nextID ~~ @allFriends)) {
                    push @allFriends, $nextID;
                    push @{$genFriends[$cs+1]}, $nextID;
                }
                if ( $nextID == $lastID ) {
                    $thisEnd = 1;
                    $weFoundHim = $cs+1;
                    last;
                }
            }

            $sth->finish();

            if ($#{$genFriends[$cs+1]} == -1) {
                $thisEnd = 1;
                $weFoundHim = -1;
            }

            $cs++;
        }

        # реализация кэша
        $memd->set("$firstID\_$lastID", "$weFoundHim", 60);

        say "Сразу после записи в кэш";
        p $memd->get("$firstID\_$lastID");
    }

    if ( $weFoundHim > 0 ) {
        return {"Num_handshakes" => $weFoundHim, };
    }
    else {
        return {"Num_handshakes" => "Между ними НЕТ связи", };
    }



}

sub DESTROY {
    my $dbh = shift;
    my $self = bless $dbh, 'DBI::db';
    $self->disconnect;
}



1;
