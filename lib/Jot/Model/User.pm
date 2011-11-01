package Jot::Model::User;
use 5.10.1;

use strict;
use autodie;
use warnings;

use namespace::autoclean;
use Moose;

has [ 'name', 'email' ] => (
  is        => 'rw',
  isa       => 'Str',
  default   => '',
  required  => 1,
);

has 'is_author' => (
  is        => 'ro',
  isa       => 'Bool',
  default   => 0,
  required  => 1,
);

1;
