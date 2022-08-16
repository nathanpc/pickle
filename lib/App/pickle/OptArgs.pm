#!/usr/bin/env perl

=head1 NAME

C<App::pickle::OptArgs> - Defines the command line arguments to be parsed.

=cut

package App::pickle::OptArgs;

use OptArgs2;
 
cmd 'App::pickle' => (
	comment => 'An electronic component pick list utility',
	optargs => sub {
		arg 'file' => (
			comment  => 'PickLE file to be parsed',
			isa      => 'Str',
			required => 1,
		);
	},
);

1;

__END__

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2022- Nathan Campos.

=cut
