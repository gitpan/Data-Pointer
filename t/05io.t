#!/usr/bin/perl

use Data::Dumper;
use Test::More tests => 9;
use vars qw/$pkg $fh/;

BEGIN { 
	$pkg = 'Data::Pointer';
	# no. 1
	use_ok($pkg);
}

use strict;

# no. 2
ok($pkg->VERSION > 0,	'version number set');

# no. 3
use_ok('File::Temp', 'tempfile');

my $ptr;
{
	my($tmp) = tempfile();
	# no. 4
	$ptr = $pkg->new( value => $tmp );
	isa_ok($ptr, $pkg);
}

eval {
	($fh) = tempfile();
	print $fh $_ while <DATA>;

	$ptr->assign( $fh );
};
# no. 5
is($@, "", 'assignment to new file');

# no. 6
is($ptr->deref, 'a line of chars', 'dereference test');

# no. 7
$ptr->incr();
is($ptr->deref, 'one', 'increment properly');

# no. 8
is($ptr->plus(2)->deref, 'three', 'plus then deref');

# no. 9
$ptr->deref = 'ichi';
is($ptr->deref, 'ichi',	'assignment to dereference');

__DATA__
a line of chars
one
two
three
