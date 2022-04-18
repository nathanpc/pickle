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
use List::Util qw(any);
use Scalar::Util qw(reftype);

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

  # List all components.
  $doc->foreach_component(sub {
  	my ($component) = @_;
  	say $component->name;
  });

  # Filter out some components.
  $doc->foreach_component({ category => 'Resistors' }, sub {
  	my ($component) = @_;
  	say $component->name;
  });

=head1 ATTRIBUTES

=over 4

=item I<components>

List of components to be picked.

=cut

has components => (
	is      => 'ro',
	lazy    => 1,
	default => sub { [] },
	writer  => '_set_components'
);

=item I<categories>

List of all of the categories available in the document.

=cut

has categories => (
	is      => 'ro',
	lazy    => 1,
	default => sub { [] },
	writer  => '_set_categories'
);

=item I<packages>

List of all of the component packages available in the document.

=cut

has packages => (
	is      => 'ro',
	lazy    => 1,
	default => sub { [] },
	writer  => '_set_packages'
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

	# Go through components.
	foreach my $component (@_) {
		# Add the component to the components list.
		push @{$self->components}, $component;

		# Make sure to update the categories and packages list.
		$self->_auto_add_category($component->category);
		$self->_auto_add_package($component->case);
	}
}

=item I<$doc>->C<foreach_component>([I<\%filter>,] I<$coderef>)

Executes a block of code (I<$coderef>) for each component. Where the component
object is passed as the first argument.

There's an optional I<\%filter> hash reference that can be passed with
attributes I<category> and/or I<case> in order to only iterate through
components match the criteria.

=cut

sub foreach_component {
	my $self = shift;
	my $filter = undef;
	my $coderef;

	# Check if we actually have a filter.
	if (reftype($_[0]) eq 'HASH') {
		$filter = shift;
	}
	$coderef = shift;

	# Go through the components.
	foreach my $component (@{$self->components}) {
		# Do we have filters?
		if (defined $filter) {
			# Category filter.
			if (exists $filter->{category}) {
				if ($component->category ne $filter->{category}) {
					next;
				}
			}

			# Package filter.
			if (exists $filter->{case}) {
				if ($component->case ne $filter->{case}) {
					next;
				}
			}
		}

		# Call the coderef given by the caller.
		$coderef->($component);
	}
}

=item I<$doc>->C<foreach_category>(I<$coderef>)

Executes a block of code (I<$coderef>) for each category available in the
document. Where the category name is passed as the first argument.

=cut

sub foreach_category {
	my ($self, $coderef) = @_;

	# Go through the categories.
	foreach my $category (@{$self->categories}) {
		$coderef->($category);
	}
}

=item I<$doc>->C<foreach_package>(I<$coderef>)

Executes a block of code (I<$coderef>) for each package available in the
document. Where the package name is passed as the first argument.

=cut

sub foreach_package {
	my ($self, $coderef) = @_;

	# Go through the package.
	foreach my $case (@{$self->packages}) {
		$coderef->($case);
	}
}

=item I<$doc>->C<save>(I<$filename>)

Saves the document object to a file.

=cut

sub save {
	my ($self, $filename) = @_;

	# Write object to file.
	open my $fh, '>:encoding(UTF-8)', $filename;
	foreach my $component (@{$self->components}) {
		print $fh $component->as_string . "\n";
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

=item I<$self>->C<_auto_add_category>(I<$category>)

Adds a I<category> to the I<categories> attribute in case it isn't in the list
yet.

=cut

sub _auto_add_category {
	my ($self, $category) = @_;

	# Check if we actually got something useful.
	if (not defined $category) {
		return;
	}

	# Check if it's already in the categories list.
	if (any { $_ eq $category } @{$self->categories}) {
		return;
	}

	# Add the new one to the list.
	push @{$self->categories}, $category;
}

=item I<$self>->C<_auto_add_package>(I<$case>)

Adds a package (I<case>) to the I<packages> attribute in case it isn't in the
list yet.

=cut

sub _auto_add_package {
	my ($self, $case) = @_;

	# Check if we actually got something useful.
	if (not defined $case) {
		return;
	}

	# Check if it's already in the packages list.
	if (any { $_ eq $case } @{$self->packages}) {
		return;
	}

	# Add the new one to the list.
	push @{$self->packages}, $case;
}

=back

=cut

1;

__END__

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
