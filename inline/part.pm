
use strict;
use warnings;

use Test::More;
use Test::LMU;

my @list = 1 .. 12;
my $i    = 0;
my @part = part { $i++ % 3 } @list;
ok( is_deeply( $part[0], [ 1, 4, 7, 10 ] ) );
ok( is_deeply( $part[1], [ 2, 5, 8, 11 ] ) );
ok( is_deeply( $part[2], [ 3, 6, 9, 12 ] ) );

$list[2] = 0;
is( $part[2][0], 3, 'Values are not aliases' );

@list = 1 .. 12;
@part = part { 3 } @list;
is( $part[0], undef );
is( $part[1], undef );
is( $part[2], undef );
ok( is_deeply( $part[3], [ 1 .. 12 ] ) );

eval {
    @part = part { -1 } @list;
};
like( $@, qr/^Modification of non-creatable array value attempted, subscript -1/ );

$i = 0;
@part = part { $i++ == 0 ? 0 : -1 } @list;
is_deeply( $part[0], [ 1 .. 12 ], "part with negative indices" );

SKIP:
{
    $INC{'List/MoreUtils/XS.pm'} and skip "Only PurePerl will warn here ...", 1;
    my @warns = ();
    local $SIG{__WARN__} = sub { push @warns, [@_] };
    @part = part { undef } @list;
    is_deeply( $part[0], [ 1 .. 12 ], "part with undef" );
    like( join( "\n", @{ $warns[0] } ), qr/Use of uninitialized value in array element.*line\s+\d+\.$/, "warning of undef" );
    is_deeply( \@warns, [ ( $warns[0] ) x 12 ], "amount of similar undef warnings" );
}

@part = part { 10000 } @list;
ok( is_deeply( $part[10000], [@list] ) );
is( $part[0],           undef );
is( $part[ @part / 2 ], undef );
is( $part[9999],        undef );

# Changing the list in place used to destroy
# its elements due to a wrong refcnt
@list = 1 .. 10;
@list = part { $_ } @list;
foreach ( 1 .. 10 )
{
    ok( is_deeply( $list[$_], [$_] ) );
}

leak_free_ok(
    part => sub {
	my @list = 1 .. 12;
	my $i    = 0;
	my @part = part { $i++ % 3 } @list;
    }
);

leak_free_ok(
    'part with stack-growing' => sub {
	# This test is from Kevin Ryde; see RT#38699
	my @part = part { grow_stack(); 1024 } 'one', 'two';
    }
);

done_testing;
