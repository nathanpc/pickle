#!/usr/bin/env perl

=head1 NAME

C<PickLE::Exception::Simple> - Simple exceptions that could've just been a die

=cut

package PickLE::Exception::Simple;

use strict;
use warnings;
use Exception::Base (__PACKAGE__);

=head1 ATTRIBUTES

=over 4

=item I<message>

A descriptive message that summarizes the exception that occured.

=item I<value>

A value that will be passed with the exception message to provied a more
detailed state.

=back

=head1 DESCRIPTION

This class implements L<Exception::Base>, it's literally just an alias of it for
now, so for more information on how to use it just check out that documentation.

=cut

1;

__END__

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
