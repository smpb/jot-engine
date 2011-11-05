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

  # Render template "index/posts.html.ep"
  $self->render(name        => $self->blog->name,
                description => $self->blog->description,
                posts       => $posts );
}

sub posts_search
{
  my $self   = shift;
  my $posts  = {};
  my $search = [];

  $search = $self->blog->get_posts_by_tag(tag => $self->param('tag'));

  foreach my $post (@$search)
  {
    my $date = $post->created->dmy;
    my $p = {
      permalink => $post->permalink,
      title     => $post->title,
    };

    if (defined $posts->{$date})
    {
      push(@{$posts->{$date}}, $p);
    }
    else
    {
      $posts->{$date} = [ $p ];
    }
  }

  # Render template "index/posts_search.html.ep"
  $self->render(template => 'index/posts_search',
                name        => $self->blog->name,
                description => $self->blog->description,
                posts       => $posts);
}

1;
