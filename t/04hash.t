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
my $ptr = $pkg->new( value => {}, fatal => 1 );
isa_ok($ptr, $pkg);

{
	my %val = qw(foo bar baz quux);
	# no. 4
	$ptr->assign(%val);
	# no. 5 
	like($ptr->deref, qr{^ (?: bar | quux ) \z }x, 'deref in scalar context');
	ok(eq_hash({$ptr->deref}, \%val), 'ptr and %val equal');
}

# no. 6
$ptr->incr(1);
like($ptr->deref, qr{^ (?: bar | quux ) \z }x, 'increment test');

{
	my $var = {qw(ichi ni san shi)};
	$ptr->assign($var);
	# no. 7
	$ptr->deref = 'two';
	{
		no warnings 'void';
		ok(($var->{ichi} eq 'two') or ($var->{san} eq 'two'),
		   'assign scalar to ptr element');
	}
	# no. 8
	($ptr->deref) = qw(two four);
	ok(eq_hash({$ptr->deref}, {qw(ichi two san four)}), 'assign list to ptr');
}

# no. 9
eval { $ptr->incr(4) };
like($@, qr/beyond boundary/, 'expect num increment err');
