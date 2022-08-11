#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 4;

BEGIN { use_ok('PickLE::Parser'); }

my $parser;

new_ok 'PickLE::Parser';

$parser = PickLE::Parser->load('examples/example.pkl');
isa_ok $parser, 'PickLE::Parser';
isa_ok $parser->picklist, 'PickLE::Document';
