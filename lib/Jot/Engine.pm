package Jot::Engine;
use 5.10.1;

use strict;
use autodie;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;

use Jot::Model::Blog;

sub startup
{
  my $self = shift;
  
  # Model Setup
  my $blog = Jot::Model::Blog->new(
    config => $self->plugin('Config')
  );
  $self->helper(blog => sub { return $blog });

  # Routes
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/')->to(controller => 'index', action=> 'posts');
}

1;

__END__

=head1 NAME

Jot::Engine - 

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 SEE ALSO

L<Mojolicious>

=head1 AUTHOR

Sérgio Bernardino C<<me@sergiobernardino.net>>

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

