package Notes::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Добро пожаловать на сайт Заметки-онлайн!');
}

1;
