#!/usr/bin/perl

use Data::Dumper;
use Test::More tests => 9;
use vars qw/$pkg/;

BEGIN { 
	$pkg = 'Data::Pointer';
	use_ok($pkg);
}

use strict;

# no. 2
ok($pkg->VERSION > 0,	'version number set');

# no. 3
my $ptr = $pkg->new( value => [], fatal => 1 );
isa_ok($ptr, $pkg);

{
	my @val = qw(foo bar baz quux);
	# no. 4,5 
	$ptr->assign(@val);
	is($ptr->deref, 'foo', 'deref in scalar context');
	local $" = ', ';
	ok(eq_array([$ptr->deref], \@val), 'ptr and @val equal');
}

# no. 6
$ptr->incr(2);
is($ptr->deref, 'baz', 'increment test');

{
	my $var = [qw(ichi ni san)];
	$ptr->assign($var);
	# no. 7
	$ptr->deref = 'one';
	is($var->[0], 'one', 'assign scalar to ptr element');

	# no. 8
	$ptr->incr(1);
	($ptr->deref) = qw(two three);
	$ptr->decr(1);
	ok(eq_array([$ptr->deref], [qw(one two three)]), 'assign list to ptr');
}

# no. 9
eval { $ptr->incr(4) };
like($@, qr/beyond boundary/, 'expect num increment err');
