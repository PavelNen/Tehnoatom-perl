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
    $r->route('/signup')->via('post')->to('users#create')     ->name('users_create');
    #$r->route('/main')  ->via('get') ->to('users#wall')       ->name('users_wall');

    my $rc = $r->under('/')->to('auths#check');
    $rc->route('/id:id', id => qr/\d+/)->via('get')->to('notes#lenta')->name('notes_individual');

    my $rn = $r->under('/notes')->to('auths#check');
    $rn->route                       ->via('get')   ->to('notes#wall') ->name('notes_show');
    $rn->route('/newnote')           ->via('get')   ->to('notes#create_form') ->name('notes_form');
    $rn->route                       ->via('post')  ->to('notes#create')->name('notes_create');
    $rn->route('/edit:noteid', noteid => qr/\d+/)->via('get')->to('notes#edit_form')->name('notes_edit');
    $rn->route('/up')                ->via('post')  ->to('notes#update')->name('notes_update');
    $rn->route('/del:noteid', noteid => qr/\d+/)->via('get')->to('notes#delete')->name('notes_delete');

    my $rl = $r->under('/lenta')->to('auths#check');
    $rl->route->to('notes#lenta')->name('lenta_show');

    my $rp = $r->under('/people')->to('auths#check');
    $rp->route->to('users#show')->name('people_show');
    #$rp->route('', favname => qr/^[^\.\/\?]+$/)->via('get')->to('users#favadd')->name('favorite_add');

    my $rf = $r->under('/favorites')->to('auths#check');
    $rf->route->to('users#show', fav => 1)->name('favorites_show');

    #Init Model
    #Инициализация базы данных
    Notes::Model->db();
}

1;
