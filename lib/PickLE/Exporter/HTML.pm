#!/usr/bin/env perl

=head1 NAME

C<PickLE::Exporter::HTML> - Converts a PickLE document to HTML.

=cut

package PickLE::Exporter::HTML;

use strict;
use warnings;
use autodie;
use XML::Writer;

use PickLE::Document;

=head1 METHODS

=over 4

=item I<$html> = C<PickLE::Exporter::HTML>->C<as_string>(I<$document>)

Converts a PickLE document (I<$document>) into an HTML document and returns it
as a string.

=cut

sub as_string {
	my ($class, $document) = @_;

	# Setup HTML generator.
	my $html = XML::Writer->new(
		OUTPUT => 'self',
		DATA_MODE => 1,
		DATA_INDENT => 2
	);

	# Build HTML skeleton.
	$html->startTag('html');
	$html->startTag('head');
	$html->dataElement('title', 'Pick List');
	$html->endTag('head');
	$html->startTag('body');

	# Start populating the page body.
	$document->foreach_category(sub {
		my $category = shift;
		$html->dataElement('h2', $category);

		# Start creating the table.
		$html->startTag('table');
		$html->startTag('tr');
		$html->dataElement('th', '#');
		$html->dataElement('th', 'Qnt.');
		$html->dataElement('th', 'Part #');
		$html->dataElement('th', 'Value');
		$html->dataElement('th', 'Reference Designators');
		$html->dataElement('th', 'Description');
		$html->dataElement('th', 'Package');
		$html->endTag('tr');

		# Go through components for the given category.
		$document->foreach_component({ category => $category }, sub {
			my $component = shift;

			# Add a component to the table.
			$html->startTag('tr');
			$html->dataElement('td', ($component->picked) ? 'X' : ' ');
			$html->dataElement('td', $component->quantity);
			$html->dataElement('td', $component->name);
			$html->dataElement('td', $component->value);
			$html->dataElement('td', $component->refdes_string);
			$html->dataElement('td', $component->description);
			$html->dataElement('td', $component->case);
			$html->endTag('tr');
		});

		# End the table.
		$html->endTag('table');
	});

	# Finish up and return.
	$html->endTag('body');
	$html->endTag('html');
	return $html->end();
}

1;

__END__

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
