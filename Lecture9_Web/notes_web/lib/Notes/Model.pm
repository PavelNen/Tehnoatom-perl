package Notes::Model;
use Notes::Model::User;
use Notes::Model::Note;
use 5.020;
use strict;
use warnings;
no warnings 'experimental';
use Encode qw(encode decode);

#use DBI;
use DDP;
use YAML;
use JSON;

use base qw/DBI DBI::db DBI::st/;

my $DB;

# Если база подключена, то просто возвращается существующий объект,
# иначе подключается БД и создаётся объект

sub db {
    my $class = shift;
    unless ($DB) {
        my $config = YAML::LoadFile("$FindBin::Bin/../conf.yaml");
        my $dbh =
            DBI->connect($config->{dsn}, $config->{userDB}, $config->{password})
                or die $DBI::errstr;

        $dbh->do( "SET SESSION wait_timeout=30" );

        $DB = bless $dbh, $class;

        # TODO Проверить наличие таблиц и создать при необходимости
    }
    return $DB;
}


sub mutualFriends {
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

sub DESTROY {
    my $dbh = shift;
    my $self = bless $dbh, 'DBI::db';
    $self->disconnect;
}



1;
