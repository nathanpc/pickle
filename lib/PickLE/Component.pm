#!/usr/bin/env perl

=head1 NAME

C<PickLE::Component> - Representation of an electronic component in a pick list

=cut

package PickLE::Component;

use strict;
use warnings;
use Moo;

=head1 ATTRIBUTES

=over 4

=item I<picked>

Has the component in the list already been picked?

=cut

has picked => {
	is => 'rw'
};

=item I<name>

Name or part number of the component. A way to uniquely identify this component
in the list without being too descriptive.

=cut

has name => {
	is => 'rw'
};

=item I<refdes>

A B<list reference> of reference designators for this component. This is
important since it'll be the only way this class can determine the quantity of
components to be picked.

=cut

has refdes => {
	is       => 'rw',
	init_arg => []
};

=item I<case>

I<Optional>. Since C<package> is kind of a reserved word, this defines the
component package as a simple string. This attribute also has associated
clearer (C<clear_case>) and predicate (C<has_case>) methods.

=cut

has case => {
	is        => 'rw',
	clearer   => 'clear_case',
	predicate => 'has_case'
};

=back

=head1 METHODS

=over 4

=item I<$comp> = C<PickLE::Component>->C<new>([I<picked>, I<name>, I<refdes>,
I<case>])

Initializes a component object with a I<name>, the reference designator list
(I<refdes>), if the component has been I<picked>, and an component package
(I<case>).

=item I<$comp>->C<add_refdes>(I<@refdes>)

Adds any number of reference designators to the reference designator list.

=cut

sub add_refdes {
	my $self = shift;

	push @{$self->refdes}, @_;
}

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

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
