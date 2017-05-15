package Notes;

use Mojo::Base 'Mojolicious';
use Notes::Model;

=encoding utf8

=head1 NAME

Local::Notes - user notes

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    my $r = $self->routes;
    $r->route('/')->to('Index#welcome')->name('index');
    #$r->route('/')               ->to('auth#create_form')->name('auths_create_form');
    $r->route('/login')              ->to('auths#create')     ->name('auths_create');
    $r->route('/logout')             ->to('auths#delete')     ->name('auths_delete');
    $r->route('/signup')->via('get') ->to('users#create')->name('users_create_form');
    $r->route('/signup')->via('post')->to('users#create')     ->name('users_create');
    $r->route('/main')  ->via('get') ->to('users#wall')       ->name('users_wall');

    my $rn = $r->under('/notes')->to('auths#check');

    #Init Model
    #Инициализация базы данных
    Notes::Model->db();
}

1;
