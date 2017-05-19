package Notes;
use Mojo::Base 'Mojolicious';

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
    $self->secrets(['SomethingVerySecret']);
    my $r = $self->routes;
    $r->namespaces(['Notes::Controller']);
    $r->route('/')->to('index#welcome')->name('index');
}

1;
