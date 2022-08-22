#!/usr/bin/env perl

=head1 NAME

C<PickLE::Exception::Parser> - Errors while parsing a PickLE document

=cut

package PickLE::Exception::Parser;

use strict;
use warnings;
use Exception::Base (__PACKAGE__) => {
	has => [ 'linenum', 'line' ],
	string_attributes => [ 'message', 'line' ]
};

=head1 ATTRIBUTES

=over 4

=item I<message>

A descriptive message about the parsing error.

=item I<linenum>

Number of the line where the parsing error occurred.

=item I<line>

The actual line string that caused the parsing error.

=back

=head1 DESCRIPTION

This class implements L<Exception::Base>, so for more information on how to use
it just check out that documentation.

=cut

1;

__END__

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
