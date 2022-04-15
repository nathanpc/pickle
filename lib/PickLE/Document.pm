#!/usr/bin/env perl

=head1 NAME

C<PickLE::Document> - Component pick list document abstraction

=cut

package PickLE::Document;

use strict;
use warnings;
use autodie;
use Moo;
use Carp;

use PickLE::Component;
use PickLE::Parser;

=head1 SYNOPSIS

  use PickLE::Document;

  # Start from scratch.
  my $doc = PickLE::Document->new;
  $doc->add_component($component);
  $doc->save("example.pkl");

  # Load from file.
  $doc = PickLE::Document->load("example.pkl");
  foreach my $component (@{$doc->components}) {
      say $component->name;
  }

=head1 ATTRIBUTES

=over 4

=item I<components>

List of components to be picked.

=cut

has components => (
	is       => 'ro',
	lazy     => 1,
	init_arg => [],
	writer   => '_set_components'
);

=back

=head1 METHODS

=over 4

=item I<$doc> = C<PickLE::Document>->C<new>()

Initializes an empty document object.

=item I<$doc> = C<PickLE::Document>->C<load>(I<$filename>)

=item I<$doc>->C<load>(I<$filename>)

Parses a component pick list file located at I<$filename>. This method can be
called statically, or as an object method. In both cases a brand new object will
be contructed.

=cut

sub load {
	my ($proto, $filename) = @_;
	my $self = (ref $proto) ? $proto : $proto->new;

	# Use the parser to get ourselves.
	my $parser = PickLE::Parser->load($filename);
	return $parser->picklist;
}

=item I<$doc>->C<add_component>(I<@component>)

Adds any number of components in the form of L<PickLE::Component> objects to the
document.

=cut

sub add_component {
	my $self = shift;
	push @{$self->components}, @_;
}

=item I<$doc>->C<save>(I<$filename>)

Saves the document object to a file.

=cut

sub save {
	my ($self, $filename) = @_;

	# Write object to file.
	open my $fh, '>:encoding(UTF-8)', $filename;
	foreach my $component (@{$self->components}) {
		print $fh, $component->as_string . "\n";
	}
	close $fh;
}

=item I<$doc>->C<as_string>()

String representation of this object, just like it is representated in the file.

=cut

sub as_string {
	my ($self) = @_;
	my $str = "";

	# Go through components getting their string representations.
	foreach my $component (@{$self->components}) {
		$str .= $component->as_string . "\n";
	}

	return $str;
}

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_set_components>(I<$components>)

Sets the I<components> attribute internally.

=cut

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
