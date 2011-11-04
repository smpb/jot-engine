package Jot::Model::Blog;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
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
    _push_post  => 'push',
  },
  default => sub { [] },
);

has '_posts_by_date' => (
  is      => 'rw',
  traits  => ['Hash'],
  isa     => 'HashRef[Int]',
  default => sub { {} },
);

has '_posts_by_tag' => (
  is      => 'rw',
  traits  => ['Hash'],
  isa     => 'HashRef[Str]',
  default => sub { {} },
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

# add posts using insertion sort
sub add_post
{
  my ($self, $new_post) = @_;

  my $year  = $new_post->created->year;
  my $month = $new_post->created->month;
  my $day   = $new_post->created->day;

  if (defined $self->_posts_by_date->{$year}->{$month}->{$day})
  {
    push(@{$self->_posts_by_date->{$year}->{$month}->{$day}}, $new_post);
  }
  else
  {
    $self->_posts_by_date->{$year}->{$month}->{$day} = [ $new_post ];
  }

  foreach my $tag ($new_post->get_tags)
  {
    if (defined $self->_posts_by_tag->{$tag})
    {
      push(@{$self->_posts_by_tag->{$tag}}, $new_post);
    }
    else
    {
      $self->_posts_by_tag->{$tag} = [ $new_post ];
    }
  }

  my $posts = $self->posts;
  for (my $i = 0; $i<@$posts;$i++)
  {
    if ($new_post->created->epoch > $posts->[$i]->created->epoch)
    {
      splice @$posts, $i, 0, $new_post;
      return 1;
    }
  }

  $self->_push_post($new_post);
  return 1;
}

sub get_posts_by_date
{
  my $self = shift;
  return [] if (@_ % 2);

  my $posts = [];
  my %args  = @_;
  my $y = $args{'year'}  || $args{'YEAR'};
  my $m = $args{'month'} || $args{'MONTH'};
  my $d = $args{'day'}   || $args{'DAY'};

  if ((defined $y) and (defined $m) and (defined $d))
  {
    $posts = $self->_posts_by_date->{$y}->{$m}->{$d};
  }
  elsif ((defined $y) and (defined $m))
  {
    my @days = keys %{$self->_posts_by_date->{$y}->{$m}};

    foreach my $d (sort @days)
    {
      map { push(@$posts, $_) }
        @{$self->get_posts_by_date(year => $y, month => $m, day => $d)};
    }
  }
  elsif (defined $y)
  {
    my @months = keys %{$self->_posts_by_date->{$y}};

    foreach my $m (sort @months)
    {
      map { push(@$posts, $_) }
        @{$self->get_posts_by_date(year => $y, month => $m)};
    }
  }

  return $posts;
}

sub get_posts_by_tag
{
  my $self = shift;
  return [] if (@_ % 2);

  my %args  = @_;
  my $t = $args{'tag'}  || $args{'TAG'};

  my $posts = $self->_posts_by_tag->{$t};

  return $posts if (defined $posts);
  return [];
}

override 'new' => sub {
  my $self = super(shift);
  my %args = @_;

  my $config = $args{'config'} || {};

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
            my @files = grep { /\.md$/i && -f "$path/$_" } readdir($dir)
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
