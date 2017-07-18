
use Test::More;
use Test::LMU;
use Tie::Array ();

SCOPE:
{
    my @s = ( 1001 .. 1200 );
    my @d = ( 1 .. 1000 );
    my @a = ( @d, @s, @d );
    my @u = duplicates @a;
    is_deeply( \@u, [@d] );
    my $u = duplicates @a;
    is( scalar @d, $u );
}

# Test strings
SCOPE:
{
    my @s = ( "AA" .. "ZZ" );
    my @d = ( "aa" .. "zz" );
    my @a = ( @d, @s, @d );
    my @u = duplicates @a;
    is_deeply( \@u, [@d] );
    my $u = duplicates @a;
    is( scalar @d, $u );
}

# Test mixing strings and numbers
SCOPE:
{
    my @s  = ( 1001 .. 1200, "AA" .. "ZZ" );
    my @d  = ( 1 .. 1000, "aa" .. "zz" );
    my $fd = freeze( \@d );
    my @a  = ( @d, @s, @d );
    my $fa = freeze( \@a );
    my @u  = duplicates map { $_ } @a;
    my $fu = freeze( \@u );
    is_deeply( \@u, [@d] );
    is( $fd, freeze( \@d ) );
    is( $fa, freeze( \@a ) );
    is( $fu, $fd );
    my $u = duplicates @a;
    is( scalar @d, $u );
}

SCOPE:
{
    my @a;
    tie @a, "Tie::StdArray";
    my @s = ( 1001 .. 1200, "AA" .. "ZZ" );
    my @d = ( 1 .. 1000, "aa" .. "zz" );
    @a = ( @d, @s, @d );
    my @u = duplicates map { $_ } @a;
    is_deeply( \@u, [@d] );
    @a = ( @u, @d );
    my $u = duplicates @a;
    is( scalar @d, $u );
}

SCOPE:
{
    my @foo = ( 'a', 'b', '', undef, 'b', 'c', '', undef );
    my @dfoo = ( 'b', '', undef );
    is_deeply( [ duplicates @foo ], \@dfoo, "two undef's are supported correctly by duplicates" );
    @foo = ( 'a', undef, 'b', '', 'b', 'c', '' );
    @dfoo = ( 'b', '' );
    is_deeply( [ duplicates @foo ], \@dfoo, 'one undef is ignored correctly by duplicates' );
    is( ( scalar duplicates @foo ), scalar @dfoo, 'scalar one undef is ignored correctly by duplicates' );
}

leak_free_ok(
    uniq => sub {
	my @s = ( 1001 .. 1200, "AA" .. "ZZ" );
	my @d = map { ( 1 .. 1000, "aa" .. "zz" ) } 0 .. 1;
	my @a = ( @d, @s );
	my @u = duplicates @a;
	scalar duplicates @a;
    }
);

# This test (and the associated fix) are from Kevin Ryde; see RT#49796
leak_free_ok(
    'duplicates with exception in overloading stringify',
    sub {
	eval {
	    my $obj = DieOnStringify->new;
	    my @u = duplicates $obj, $obj;
	};
	eval {
	    my $obj = DieOnStringify->new;
	    my $u = duplicates $obj, $obj;
	};
    }
);

done_testing;

