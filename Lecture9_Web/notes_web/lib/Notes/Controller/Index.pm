package Notes::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;
  if ($self->session('user_id')) {
      $self->redirect_to('notes_show');
  }
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Добро пожаловать на сайт miniNote!');
}

1;
