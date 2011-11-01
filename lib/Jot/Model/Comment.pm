package Jot::Model::Comment;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
use DateTime;
use Moose;

use Jot::Model::User;

has [ 'creation_date', 'modified_date' ] => (
  is  => 'rw',
  isa => 'DateTime',
);

has 'content' => (
  is      => 'rw',
  isa     => 'Str',
  default => '',
);

has 'author' => (
  is        => 'rw',
  isa       => 'Jot::Model::User',
  required  => 1,
);

1;
