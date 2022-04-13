#!/usr/bin/env perl

=head1 NAME

C<PickLE::Parser> - Parses a component pick list file

=cut

package PickLE::Parser;

use strict;
use warnings;
use autodie;
use Moo;
use Carp;

use PickLE::Component;
use PickLE::PickList;

=head1 SYNOPSIS

  use PickLE::Parser;

  # Parse a pick list file.
  $pickle = PickLE::Parser->load('example.pkl');
  $picklist = $pickle->picklist;  # Gets a PickLE::PickList object.

=head1 ATTRIBUTES

=over 4

=item I<picklist>

List of items to be picked in the form of an L<PickLE::PickList> object.

=cut

has picklist => {
	is => 'ro',
	lazy => 1,
	init_arg => [],
	writer => '_set_picklist'
};

=back

=head1 METHODS

=over 4

=item I<$pickle> = C<PickLE::Parser>->C<new>()

Initializes an empty parser object.

=item I<$pickle> = C<PickLE::Parser>->C<load>(I<$filename>)

=item I<$pickle>->C<load>(I<$filename>)

Parses a component pick list file located at I<$filename>. This method can be
called statically, in which case it'll return a contructed object, or as an
object method, in which case it'll just populate the I<picklist> attribute.

=cut

sub load {
	my ($proto, $filename) = @_;
	my $self = (ref $proto) ? $proto : $proto->new;

	# Open the file for parsing.
	open my $fh, '<', $filename;
	$self->_parse($fh);

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
		empty      => 0,
		descriptor => 1,
		refdes     => 2,
	};
	my $phase = $phases->{empty};
	my $component = undef;

	# Go through the file line-by-line.
	while (my $line = <$fh>) {
		chomp $line;

		# Check if we are about to parse a descriptor.
		if ($phase == $phases->{empty}) {
			if (substr($line, 0, 1) eq '') {
				# Looks like we have to parse a descriptor line.
				$phase = $phases->{descriptor};
				$component = PickLE::Component->new;
			} elsif ($line eq '') {
				# Just another empty line...
				next;
			}
		} elsif ($phase == $phases->{refdes}) {
			# Parse the reference designators.
			if (substr($line, 0, 1) ne '') {
				# TODO:
			}

			# Append the component to the pick list and go to the next line.
			$self->picklist->add($component);
			$component = undef;
			$phase = $phases->{empty};
			next;
		}

		# Parse the descriptor line into a component.
		# TODO:
	}
}

=item I<$self>->C<_set_picklist>(I<$picklist>)

Sets the I<picklist> attribute internally.

=cut

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
