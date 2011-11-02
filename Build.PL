#!perl

use strict;
use autodie;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'Jot::Engine',
  dist_version  => '0.01',
  dist_author   => 'Sérgio Bernardino <me@sergiobernardino.net>',
  dist_abstract => 'tiny blog engine, for quick and simple content creation',
  license       => 'perl',
  requires      => {
    'perl'                  => '5.10.1',
    'autodie'               => 2,
    'namespace::autoclean'  => 0,
    'Moose'                 => 2,
    'Mojolicious'           => 2,
    'Text::Markdown'        => 1,
  },
  build_requires      => { 'Test::More'     => 0 },
  configure_requires  => { 'Module::Build'  => 0 },
  add_to_cleanup      => [ 'Jot-*', '*META.*'  ],
);

$build->create_build_script;
