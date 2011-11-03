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
      created   => $p->created->dmy  . ', ' . $p->created->hms,
      modified  => $p->modified->dmy . ', ' . $p->modified->hms,
      content   => $p->content,
      tags      => $p->tags,
    });
  }

  # Render template "index/main.html.ep" with message
  $self->render(name => $self->blog->name,
                description => $self->blog->description,
                posts => $posts );
}

1;
