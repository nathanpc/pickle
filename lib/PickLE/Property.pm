#!/usr/bin/env perl

=head1 NAME

C<PickLE::Property> - Representation of a header property in a pick list

=cut

package PickLE::Property;

use strict;
use warnings;
use Moo;

=head1 ATTRIBUTES

=over 4

=item I<name>

Name of the property.

=cut

has name => (
	is => 'rw',
);

=item I<value>

Value of the property.

=cut

has value => (
	is => 'rw',
);

=back

=head1 METHODS

=over 4

=item I<$prop> = C<PickLE::Property>->C<new>([I<name>, I<value>])

Initializes a pick list property object with a I<name> and I<value>.

=item I<$prop> = C<PickLE::Property>->C<from_line>(I<$line>)

Initializes a pick list property object by parsing a I<$line> from a document.
Will return C<undef> if we couldn't parse a property from the given line.

This method can also be called as I<$prop>->C<from_line> and it'll override just
the I<name> and I<value> of the object.

=cut

sub from_line {
	my ($self, $line) = @_;
	$self = $self->new() unless ref $self;

	# Try to parse the property line.
	if ($line =~ /(?<name>[A-Za-z0-9\-]+):\s+(?<value>.+)/) {
		# Populate our object.
		$self->name($+{name});
		$self->value($+{value});

		return $self;
	}

	# Looks like the property line couldn't be parsed.
	return undef;
}

=item I<$str> = I<$prop>->C<as_string>()

Gets the string representation of this object.

=cut

sub as_string {
	my ($self) = @_;
	return $self->name . ': ' . $self->value;
}

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
