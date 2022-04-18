#!/usr/bin/env perl

=head1 NAME

C<PickLE::Converter::EagleBOM> - Converts an EAGLE exported BOM CSV file

=cut

package PickLE::Converter::EagleBOM;

use strict;
use warnings;
use autodie;
use Moo;
use Text::CSV;

use PickLE::Document;
use PickLE::Component;

=head1 ATTRIBUTES

=over 4

=item I<document>

Converted BOM into a L<PickLE::Document> object.

=cut

has document => (
	is      => 'ro',
	lazy    => 1,
	default => sub { PickLE::Document->new },
	writer  => '_set_document'
);

=back

=head1 METHODS

=over 4

=item I<$bom> = C<PickLE::Converter::EagleBOM>->C<load>(I<$csvfile>)

Initializes the converter with a CSV file of a BOM exported straight out of
Eagle.

=cut

sub load {
	my ($proto, $csvfile) = @_;
	my $self = (ref $proto) ? $proto : $proto->new;

	# Setup the CSV parser.
	my $csv = Text::CSV->new({
		sep_char => ';',
		auto_diag => 2
	});

	# Open the CSV file to be parsed.
	$self->_set_document(PickLE::Document->new);
	open my $fh, "<:encoding(UTF-8)", $csvfile;
	$csv->getline($fh);                           # Dicard row with headers.
	while (my $row = $csv->getline($fh)) {
		my $component = PickLE::Component->new;

		# Get the easy ones out of the way.
		$component->name($row->[2]);
		$component->value($row->[1]) if ($row->[1] ne $row->[2]);
		$component->description($row->[5]);
		$component->case($row->[3]);
		$component->category($row->[5]);
		$component->add_refdes(split /, /, $row->[4]);

		# Append the parsed component to our converted document.
		$self->document->add_component($component);
    }
	close $fh;

	return $self;
}

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
