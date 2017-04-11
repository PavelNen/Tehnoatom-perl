package Local::SocialNetwork;

use 5.010;
use strict;
use warnings;
use Encode qw(encode decode);

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

    say "List of mutual friends for $firstID and $secondID in JSON:";

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
                $secondID_list{$hash_ref->{$key}{Two}} = $secondID;
            }
        }
    }

    #Поиск ID общих друзей
    for my $key (keys %firstID_list) {
        if (exists $secondID_list{$key}) {
            push @mutual_array_ID, $key;
        }
    }

    #Сбор имени и фамилии для этих ID
    if ($#mutual_array_ID > 0) {
        my $query = "SELECT * FROM users where id = ? ";
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
    return \@result;
}

sub nofriends {
  my @result = ();
  our $test;
  say "Who has no friends?";

  my $query = "SELECT * FROM users
                  WHERE NOT id IN (SELECT DISTINCT One FROM users_relation)
                    AND NOT id IN (SELECT DISTINCT Two FROM users_relation)";
  my $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
  $sth_rel->execute or die $dbh->errstr;

  my $hash_ref_nofrnd = $sth_rel->fetchall_hashref('id');
=pod
  my @ID_array_hasfrnd = ();
  for my $key (keys %{$hash_ref_rel}) {
      push @ID_array_hasfrnd, $hash_ref_rel->{$key}{'id'};
  }
p @ID_array_hasfrnd;
say $#ID_array_hasfrnd+1;

  $query = "SELECT * FROM users WHERE id != ? ";
        for (1..$#ID_array_hasfrnd) {
          $query .= " AND id != ?";
      }

  p @ID_array_hasfrnd;
  $sth_rel = $dbh->prepare( $query ) or die $dbh->errstr;
  $sth_rel->execute(@ID_array_hasfrnd) or die $dbh->errstr;
  my $hash_ref_nofrnd = $sth_rel->fetchall_hashref('id');
  #p $hash_ref_nofrnd;
=cut
  for my $key (keys %{$hash_ref_nofrnd}) {
      push @result, $hash_ref_nofrnd->{$key};
  }

  #p $hash_ref_rel;
  return \@result;
}

sub num_handshakes {
    say "It is num_handshakes";
    1;
}

sub discon { $dbh->disconnect; }

sub encodeJSON{
	my($arrayRef) = @_;
	my $JSONText= decode('utf8', JSON->new->utf8->encode($arrayRef));
	return $JSONText;
}

1;
