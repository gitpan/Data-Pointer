#!/usr/bin/perl

use Test::More tests => 11;
use vars qw/$pkg/;

BEGIN { 
	$pkg = 'Data::Pointer';
	use_ok($pkg);
}

use strict;

# no. 2
ok($pkg->VERSION > 0,	'version number set');

# no. 3
my $ptr = $pkg->new( value => "nought" );
isa_ok($ptr, $pkg);

# no. 4
$ptr->assign('a string');
is($ptr->deref, 'a string', 'dereferenced properly');

# no. 5
$ptr->incr(2);
is($ptr->deref, 'string', 'increment test');

{
	# no. 6,7
	my $var = "refness";
	$ptr->assign(\$var);
	is($ptr->deref, $var, 'dereferencing a reference');
	$ptr->incr(3);
	is($ptr->deref, 'ness', 'incrementing on reference');
	
	# no. 8
	$ptr->deref = 'lect';
	is($var, 'reflect', 'assign chunk to ptr value');
}

# no. 9
{
	my $tmp_ptr = $ptr->minus(1);
	is($tmp_ptr->deref, 'flect', 'ptr arithmetic & ptr return');
}

# no. 10
$ptr = $pkg->new( value	=> 123 );
cmp_ok($ptr->deref, '==', 123,	'number value');

# mp. 11
eval { $ptr->incr(1) };
like($@, qr/can't increment/, 'expect num increment err');
