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
	$self->_parse($fh);
	close $fh;

	return $self;
}

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_parse>(I<$fh>)

Parses the contents of a file handle (I<$fh>) and populates the I<picklist>
attribute.

=cut

sub _parse {
	my ($self, $fh) = @_;
	my $phases = {
		empty	   => 0,
		descriptor => 1,
		refdes	   => 2,
	};
	my $phase = $phases->{empty};
	my $component = undef;
	my $category = undef;

	# Initialize a brand new pick list document.
	$self->_set_picklist(PickLE::Document->new);

	# Go through the file line-by-line.
	while (my $line = <$fh>) {
		chomp $line;

		# Check if we are about to parse a descriptor.
		if ($phase == $phases->{empty}) {
			if (substr($line, 0, 1) eq '[') {
				# Looks like we have to parse a descriptor line.
				$phase = $phases->{descriptor};
				$component = PickLE::Component->new;
			} elsif (substr($line, -1, 1) eq ':') {
				# Got a category line.
				$category = substr($line, 0, -1);
				next;
			} elsif ($line eq '') {
				# Just another empty line...
				next;
			}
		} elsif ($phase == $phases->{refdes}) {
			# Parse the reference designators.
			if (substr($line, 0, 1) ne '') {
				$component->add_refdes(split ' ', $line);
			}

			# Append the component to the pick list and go to the next line.
			$self->picklist->add_component($component);
			$component = undef;
			$phase = $phases->{empty};
			next;
		}

		# Parse the descriptor line into a component.
		if ($line =~ /\[(?<picked>.)\]\s+(?<quantity>\d+)\s+(?<name>[^\s]+)\s*(\((?<value>[^\)]+)\)\s*)?("(?<description>[^"]+)"\s*)?(\[(?<case>[^\]]+)\]\s*)?/) {
			# Populate the component with required parameters.
			$component->picked(($+{picked} ne ' ') ? 1 : 0);
			$component->name($+{name});
			$component->category($category);

			# Component value.
			if (exists $+{value}) {
				$component->value($+{value});
			}

			# Component description.
			if (exists $+{description}) {
				$component->description($+{description});
			}

			# Component package.
			if (exists $+{case}) {
				$component->case($+{case});
			}

			# Move to the next phase.
			$phase = $phases->{refdes};
		} else {
			# Looks like the descriptor line was malformed.
			carp "Error parsing component descriptor '$line'";
		}
	}
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
