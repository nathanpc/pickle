#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;

use PickLE::Component;
BEGIN { use_ok('PickLE::Category'); }

# Blank start.
my $cat = new_ok('PickLE::Category');
throws_ok { $cat->as_string } 'PickLE::Exception::Simple', 'as_string throws exception for a blank object';

# Name
is $cat->name, undef, 'name initialized as undefined';
$cat->name('Test Category');
is $cat->name, 'Test Category', 'name now set to "Test Category"';
is $cat->as_string, 'Test Category:', 'as_string properly formatted';

# Components
is_deeply $cat->components, [], 'components initialized as an empty array';
$cat->add_component(PickLE::Component->new);
is scalar(@{$cat->components}), 1, '1 component in the array';
$cat->add_component(PickLE::Component->new);
is scalar(@{$cat->components}), 2, '2 components in the array';
