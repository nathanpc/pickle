#!/usr/bin/env perl

=head1 NAME

C<PickLE::Component> - Representation of an electronic component in a pick list

=cut

package PickLE::Component;

use strict;
use warnings;
use Moo;

# Component has been picked?
has picked => {
	is => 'ro',
	required => 1
};

# Component name.
has name => {
	is => 'ro',
	required => 1
};

# Reference designators.
has refdes => {
	is => 'ro',
	required => 1
};

# Component package.
has case => {
	is => 'ro'
};

=head1 METHODS

=over

=item 4

=item I<$comp> = C<PickLE::Component>->C<new>(I<picked>, I<name>, I<refdes>[,
I<case>])

Initializes a component object with a I<name>, the reference designator list
(I<refdes>), if the component has been I<picked>, and an optional component
package (I<case>).

=item I<$quantity> = I<$comp>->C<quantity>()

Gets the quantity of the component to be picked.

=cut

sub quantity {
	my ($self) = @_;

	return scalar @{$self->refdes};
}

=item I<$str> = I<$comp>->C<as_string>()

Gets the string representation of this object.

=cut

sub as_string {
	my ($self) = @_;
	my $str = '';

	# First line.
	$str .= '[' . (($self->picked) ? 'X' : ' ') . ']\t' . $self->quantity .
		'\t' . $self->name;
	if (!defined($self->case)) {
		$str .= '\t[' . $self->case . ']';
	}

	# Reference designators.
	$str .= '\n';
	foreach (@{$self->refdes}) {
		$str .= $self->refdes[$i];
	}

	# Remove any trailling whitespace and return.
	$str =~ s/\s+$//;
	return $str;
}

1;

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
