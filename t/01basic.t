#!/usr/bin/perl

use Test::More tests => 3;
use vars qw/$pkg/;

BEGIN { 
	$pkg = 'Data::Pointer';
	# no. 1
	use_ok($pkg);
}

use strict;

# no. 2
ok($pkg->VERSION > 0,	'version number set');

# no. 3
my $ptr = $pkg->new( value => "nought" );
isa_ok($ptr, $pkg);
