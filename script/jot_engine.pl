#!perl

use strict;
use autodie;
use warnings;

use Mojo::Base;

use File::Basename 'dirname';
use File::Spec;

use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';

# Check if Mojolicious is installed;
die <<EOF unless eval 'use Mojolicious::Commands; 1';
It looks like you don't have the Mojolicious framework installed.
Please visit http://mojolicio.us for detailed installation instructions.

EOF

# Application
$ENV{MOJO_APP} ||= 'Jot::Engine';

# Start commands
Mojolicious::Commands->start();
