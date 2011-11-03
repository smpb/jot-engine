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
  isa     => 'ArrayRef[Str]',
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

sub generate_permatitle
{
  my $self = shift;
  my $pt = $self->title;

  $pt =~ s/[\W]+/-/ig;
  $pt =~ s/-+$//ig;

  $self->_permatitle($pt);
}

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
        when (/^;tags:(.+)/) { $self->tags( [ split(',', $1) ] ); }
        when (/^;title:(.+)/)
        {
          $self->title($1);
          $self->generate_permatitle;
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
