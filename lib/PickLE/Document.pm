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

use PickLE::Category;
use PickLE::Parser;

=head1 SYNOPSIS

  use PickLE::Document;

  # Start from scratch.
  my $doc = PickLE::Document->new;
  $doc->add_category($category);
  $doc->save("example.pkl");

  # Load from file.
  $doc = PickLE::Document->load("example.pkl");

  # List all document properties.
  $doc->foreach_property(sub {
    my $property = shift;
    say $property->name . ': ' . $property->value;
  });

  # List all components in each category.
  $doc->foreach_category(sub {
    my $category = shift;
    $category->foreach_component(sub {
      my ($component) = @_;
      say $component->name;
    });
  });

=head1 ATTRIBUTES

=over 4

=item I<properties>

List of all of the pick list properties in the document.

=cut

has properties => (
	is      => 'ro',
	lazy    => 1,
	default => sub { [] },
	writer  => '_set_properties'
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
	if (not defined $parser) {
		return undef;
	}
	
	return $parser->picklist;
}

=item I<$doc>->C<add_property>(I<@property>)

Adds any number of proprerties in the form of L<PickLE::Property> objects to the
document.

=cut

sub add_property {
	my $self = shift;

	# Go through properties adding them to the properties list.
	foreach my $property (@_) {
		push @{$self->properties}, $property;
	}
}

=item I<$doc>->C<add_category>(I<@category>)

Adds any number of categories in the form of L<PickLE::Category> objects to the
document.

=cut

sub add_category {
	my $self = shift;

	# Go through categories adding them to the categories list.
	foreach my $category (@_) {
		push @{$self->categories}, $category;
	}
}

=item I<$doc>->C<foreach_property>(I<$coderef>)

Executes a block of code (I<$coderef>) for each proprety. The property object
will be passed as the first argument.

=cut

sub foreach_property {
	my ($self, $coderef) = @_;

	# Go through the properties.
	foreach my $property (@{$self->properties}) {
		# Call the coderef given by the caller.
		$coderef->($property);
	}
}

=item I<$doc>->C<foreach_category>(I<$coderef>)

Executes a block of code (I<$coderef>) for each category available in the
document. The category object will be passed as the first argument.

=cut

sub foreach_category {
	my ($self, $coderef) = @_;

	# Go through the categories.
	foreach my $category (@{$self->categories}) {
		$coderef->($category);
	}
}

=item I<$property> = I<$self>->C<get_property>(I<$name>)

Gets a property of the document by its I<$name> and returns it if found,
otherwise returns C<undef>.

=cut

sub get_property {
	my ($self, $name) = @_;
	my $found = undef;

	# Go through the properties checking their names for a match.
	$self->foreach_property(sub {
		my $property = shift;
		if ($property->name eq $name) {
			$found = $property;
		}
	});

	return $found;
}

=item I<$category> = I<$self>->C<get_category>(I<$name>)

Gets a category in the document by its I<$name> and returns it if found,
otherwise returns C<undef>.

=cut

sub get_category {
	my ($self, $name) = @_;
	my $found = undef;

	# Go through the categories checking their names for a match.
	$self->foreach_category(sub {
		my $category = shift;
		if ($category->name eq $name) {
			$found = $category;
		}
	});

	return $found;
}

=item I<$doc>->C<save>(I<$filename>)

Saves the document object to a file.

=cut

sub save {
	my ($self, $filename) = @_;

	# Write object to file.
	open my $fh, '>:encoding(UTF-8)', $filename;
	print $fh $self->as_string;
	close $fh;
}

=item I<$doc>->C<as_string>()

String representation of this object, just like it is representated in the file.

=cut

sub as_string {
	my ($self) = @_;
	my $str = "";

	# Check if we have the required Name property.
	if (not defined $self->get_property('Name')) {
		carp "Document can't be represented because the required 'Name' " .
			'property is not defined';
		return '';
	}

	# Check if we have the required Revision property.
	if (not defined $self->get_property('Revision')) {
		carp "Document can't be represented because the required 'Revision' " .
			'property is not defined';
		return '';
	}

	# Check if we have the required Description property.
	if (not defined $self->get_property('Description')) {
		carp "Document can't be represented because the required 'Description' " .
			'property is not defined';
		return '';
	}

	# Go through properties getting their string representations.
	$self->foreach_property(sub {
		my $property = shift;
		$str .= $property->as_string . "\n";
	});

	# Add the header section separator.
	$str .= "\n---\n\n";

	# Go through categories getting their string representations.
	$self->foreach_category(sub {
		my $category = shift;
		$str .= $category->as_string . "\n";

		# Go through components getting their string representations.
		$category->foreach_component(sub {
			my $component = shift;
			$str .= $component->as_string . "\n\n";
		});
	});

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
