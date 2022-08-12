#!/usr/bin/env perl

=head1 NAME

C<PickLE::Parser> - Parses a component pick list file

=cut

package PickLE::Parser;

use 5.010;
use strict;
use warnings;
use autodie;
use Moo;
use Carp;

use PickLE::Property;
use PickLE::Category;
use PickLE::Component;
use PickLE::Document;

=head1 SYNOPSIS

  use PickLE::Parser;

  # Parse a pick list file.
  my $parser = PickLE::Parser->load('example.pkl');
  my $picklist = $parser->picklist;	 # Gets a PickLE::Document object.

=head1 ATTRIBUTES

=over 4

=item I<picklist>

List of items to be picked in the form of an L<PickLE::Document> object.

=cut

has picklist => (
	is		=> 'ro',
	lazy	=> 1,
	default => sub { [] },
	writer	=> '_set_picklist'
);

=back

=head1 METHODS

=over 4

=item I<$parser> = C<PickLE::Parser>->C<new>()

Initializes an empty parser object.

=item I<$parser> = C<PickLE::Parser>->C<load>(I<$filename>)

=item I<$parser>->C<load>(I<$filename>)

Parses a component pick list file located at I<$filename>. This method can be
called statically, in which case it'll return a contructed object, or as an
object method, in which case it'll just populate the I<picklist> attribute.

=cut

sub load {
	my ($proto, $filename) = @_;
	my $self = (ref $proto) ? $proto : $proto->new;

	# Parse the file.
	open my $fh, '<:encoding(UTF-8)', $filename;
	$self->_parse($fh) or return undef;
	close $fh;

	return $self;
}

=back

=head1 PRIVATE METHODS

=over 4

=item I<$status> = I<$self>->C<_parse>(I<$fh>)

Parses the contents of a file handle (I<$fh>) and populates the I<picklist>
attribute. Returns C<0> if there were parsing errors.

=cut

sub _parse {
	my ($self, $fh) = @_;
	my $status = 1;
	my $phases = {
		empty	   => 0,
		property   => 1,
		descriptor => 2,
		refdes	   => 3,
	};
	my $phase = $phases->{property};
	my $component = undef;
	my $category = undef;

	# Initialize a brand new pick list document.
	$self->_set_picklist(PickLE::Document->new);

	# Go through the file line-by-line.
	while (my $line = <$fh>) {
		# Clean up the line string.
		$line =~ s/^\s+|[\s\r\n]+$//g;

		# Check if we are about to parse a descriptor.
		if ($phase == $phases->{empty}) {
			if (substr($line, 0, 1) eq '[') {
				# Looks like we have to parse a descriptor line.
				$phase = $phases->{descriptor};
			} elsif (substr($line, -1, 1) eq ':') {
				# Got a category line.
				if (defined $category) {
					# Append the last category we parsed to the list.
					$self->picklist->add_category($category);
				}

				# Parse the new category.
				$category = PickLE::Category->from_line($line);
				if (not defined $category) {
					# Looks like the category line was malformed.
					carp "Error parsing category '$line'";
					$status = 0;
				}

				next;
			} elsif ($line eq '') {
				# Just another empty line...
				next;
			}
		} elsif ($phase == $phases->{refdes}) {
			# Parse the reference designators.
			$component->parse_refdes_line($line);

			# Append the component to the pick list and go to the next line.
			$category->add_component($component);
			$component = undef;
			$phase = $phases->{empty};
			next;
		} elsif ($phase == $phases->{property}) {
			# Looks like we are in the properties header.
			if ($line eq '') {
				# Just another empty line...
				next;
			} elsif ($line eq '---') {
				# We've finished parsing the properties header.
				$phase = $phases->{empty};
				next;
			}
			
			# Parse the property.
			my $prop = PickLE::Property->from_line($line);
			if (not defined $prop) {
				# Looks like the property line was malformed.
				carp "Error parsing property '$line'";
				$status = 0;
			}

			# Append the property to the properties list of the document.
			$self->picklist->add_property($prop);
			next;
		}

		# Parse the descriptor line into a component.
		$component = PickLE::Component->from_line($line);
		$phase = $phases->{refdes};
		if (not defined $component) {
			# Looks like the descriptor line was malformed.
			carp "Error parsing component descriptor '$line'";
			$status = 0;
		}
	}

	# Make sure we get that last category.
	if (defined $category) {
		# Append the last category we parsed to the list.
		$self->picklist->add_category($category);
	}

	return $status;
}

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
