package Jot::Model::Post;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
use Text::Markdown;
use Time::ParseDate;
use DateTime;
use Moose;

use Jot::Model::User;
use Jot::Model::Comment;

has [ 'created', 'modified' ] => (
  is      => 'rw',
  isa     => 'DateTime',
  default => sub { DateTime->now },
);

has 'comments' => (
  is  => 'rw',
  isa => 'ArrayRef[Jot::Model::Comment]',
);

has [ 'title', 'content' ] => (
  is      => 'rw',
  isa     => 'Str',
  default => '',
);

has 'permatitle' => (
  is  => 'rw',
  isa => 'Str',
  writer => '_permatitle',
);

has 'tags' => (
  is      => 'rw',
  traits  => ['Array'],
  isa     => 'ArrayRef[Str]',
  handles => {
    get_tags => 'elements',
    add_tag  => 'push',
  },
  default => sub { [] },
);

has '_parser' => (
  is        => 'ro',
  isa       => 'Text::Markdown',
  handles   => {
    _parse => 'markdown',
  },
  required  => 1,
  default   => sub { Text::Markdown->new; },
);

sub permalink
{
  my $self = shift;

  return lc '/'. $self->created->year .'/'. $self->created->month .'/'.
          $self->created->day .'/'. $self->permatitle;
}

before 'title' => sub {
  my $self = shift;

  if (@_) # update permatitle if we're updating the title
  {
    my ($t) = @_;
    $t =~ s/[\W]+/-/ig;
    $t =~ s/-+$//ig;
    $self->_permatitle($t);
  }
};

override 'new' => sub {
  my $self = super(shift);
  my %args = @_;

  if (-e $args{'file'})
  {
    open my $fh, '<', $args{'file'};
    my $md;

    while (<$fh>)
    {
      given ($_)
      {
        when (/^;tags:(.+)/)
        {
          my $tags = $1;
          $tags =~ s/,\s*,/,/g;  # make sure "empty" tags aren't considered
          $self->tags( [ split(/\s*,\s*/, $tags) ] );
        }
        when (/^;title:(.+)/)
        {
          $self->title($1);
        }
        when (/^;(created|modified):(.+)/)
        {
          my $e = parsedate($2, UK => 1);
          $self->$1(DateTime->from_epoch(epoch => $e));
        }
        when (/^;(\w+):(.+)/) {}  # ignore unknown metadata keywords
        default { $md .= $_ }     # everything else is post content
      }
    }

    close $fh;

    $self->content($self->_parse($md));
  }
  
  return $self;
};

1;
