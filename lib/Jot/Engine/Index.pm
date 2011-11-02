package Jot::Engine::Index;
use 5.10.1;

use strict;
use autodie;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Jot::Model::Blog;
use Jot::Model::Post;

sub posts
{
  my $self = shift;
  my $posts = [];

  foreach my $p (@{$self->blog->posts})
  {
    push(@{$posts}, {
      creation_date => $p->creation_date->dmy . ', ' . $p->creation_date->hms,
      content       => $p->content, 
      });
  }

  # Render template "index/main.html.ep" with message
  $self->render(name => $self->blog->name,
                description => $self->blog->description,
                posts => $posts );
}

1;
