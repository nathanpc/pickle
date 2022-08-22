#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;

BEGIN { use_ok('PickLE::Property'); }

# Blank start.
my $prop = new_ok('PickLE::Property');
throws_ok { $prop->as_string } 'PickLE::Exception::Simple', 'as_string throws exception for a blank object';

# Name
is $prop->name, undef, 'name initialized as undefined';
$prop->name('Test Name');
is $prop->name, 'Test Name', 'name now set to "Test Name"';
throws_ok { $prop->as_string } 'PickLE::Exception::Simple', 'as_string throws exception for an incomplete object';

# Value
is $prop->value, undef, 'value initialized as undefined';
$prop->value('Test Value');
is $prop->value, 'Test Value', 'value now set to "Test Value"';
ok $prop->as_string eq 'Test Name: Test Value', 'as_string is empty for an incomplete object';
