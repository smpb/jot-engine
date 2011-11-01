package Jot::Model::Post;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
use Text::Markdown;
use DateTime;
use Moose;

use Jot::Model::User;
use Jot::Model::Comment;

has [ 'creation_date', 'modified_date' ] => (
  is  => 'rw',
  isa => 'DateTime',
);

has 'comments' => (
  is  => 'rw',
  isa => 'ArrayRef[Jot::Model::Comment]',
);

has 'content' => (
  is      => 'rw',
  isa     => 'Str',
  default => '',
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

override 'new' => sub {
  my $self = super(shift);
  my %args = @_;

  if (-e $args{'file'})
  {
    open my $fh, '<', $args{'file'};
    my $md = do { local $/; <$fh>  };
    close $fh;

    $self->content($self->_parse($md));
  }
  
  return $self;
};

1;
