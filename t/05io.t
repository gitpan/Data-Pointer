#!/usr/bin/perl

use Data::Dumper;
use Test::More tests => 15;
use vars qw/$pkg/;

no warnings 'misc';

BEGIN { 
	$pkg = 'Data::Pointer';
	# no. 1
	use_ok($pkg);
}

use strict;

# no. 2
ok($pkg->VERSION > 0,	'version number set');

my $tmpfile = "tmpfile$$";

my $ptr;
{
	# no. 3
	ok(open(my $fh, '>', $tmpfile), 'dupe STDOUT file');

	# no. 4
	$ptr = $pkg->new( value => $fh );
	isa_ok($ptr, $pkg);
}

eval {
	# no. 5
	ok(open(my $fh, '>', $tmpfile), 'open temp file');
	print $fh $_ while <DATA>;
	
	# no. 6
	ok(open(my $fh, '<', $tmpfile), 're-open temp file');
	
	$ptr->assign( $fh );
};
# no. 7
is($@, "", 'assignment to new file');

# no. 8
is($ptr->deref, 'a line of chars', 'dereference test');

# no. 9
$ptr->incr();
is($ptr->deref, 'one', 'increment properly');

# no. 10
is($ptr->plus(2)->deref, 'three', 'plus then deref');

# no. 11
ok(open(my $fh, '+>', $tmpfile), 're-re-open temp file');
$ptr->assign( $fh );

# no. 12
eval { $ptr->deref = 'ichi' };
is($@, "", 'assignment to dereference');

# no. 13
ok(open(my $fh, '<', $tmpfile), 're x 4 open temp file');
$ptr->assign( $fh );

(my $first_line = $ptr->deref) =~ s< \r $/? \z>()x;
# no. 14
is($first_line, 'ichi', 'wrote to file');

# no. 15
ok(unlink($tmpfile) == 1, "removed $tmpfile");

__DATA__
a line of chars
one
two
three
