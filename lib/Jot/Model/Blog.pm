package Jot::Model::Blog;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
use Config::Tiny;
use Moose;

use Jot::Model::Post;
use Jot::Model::User;

has [ 'name', 'description' ] => (
  is  => 'rw',
  isa => 'Str',
);

has 'author' => (
  is  => 'rw',
  isa => 'Jot::Model::User',
);

has 'pagination' => (
  is      => 'rw',
  isa     => 'Int',
  default => 5,
);

has 'posts' => (
  is      => 'rw',
  traits  => ['Array'],
  isa     => 'ArrayRef[Jot::Model::Post]',
  handles => {
    get_posts => 'elements',
    add_post  => 'push',
  },
  default => sub { [] },
);

has 'users' => (
  is      => 'rw',
  traits  => ['Array'],
  isa     => 'ArrayRef[Jot::Model::User]',
  handles => {
    get_users => 'elements',
    add_user  => 'push',
  },

  default => sub { [] },
);

override 'new' => sub {
  my $self = super(shift);
  my %args = @_;

  die "Invalid configuration file." unless (-e $args{'config'});

  my $config = Config::Tiny->new->read($args{'config'});

  foreach my $section (keys %$config)
  {
    given ($section)
    {
      when (/blog|engine/)
      {
        foreach my $property (keys %{$config->{$section}})
        {
          if ($self->can($property))
          {
            $self->$property($config->{$section}->{$property});
          }
          
          if ($property eq 'path')
          {
            my $path = $config->{$section}->{'path'};
            opendir(my $dir, $path)
              or die "Unable to access '$path'.";
            my @files = grep { /\.md$/ && -f "$path/$_" } readdir($dir)
              or die "Unable to list contents of '$path'.";
            foreach my $f (@files)
            {
              my $post = Jot::Model::Post->new(file => "$path$f");
              $self->add_post($post) if (defined $post);
            }
            closedir($dir);
          }
        }
      }
      
      when ('author')
      {
        $self->author(Jot::Model::User->new(
          name      => $config->{'author'}->{'name'},
          email     => $config->{'author'}->{'email'},
          is_author => 1,
        ));
      }
    }
  }
  
  return $self;
};

1;
