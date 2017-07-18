
use Test::More;
use Test::LMU;

my @x = indexes { $_ > 5 } ( 4 .. 9 );
ok( is_deeply( \@x, [ 2 .. 5 ] ) );
@x = indexes { $_ > 5 } ( 1 .. 4 );
is_deeply( \@x, [], 'Got the null list' );

my ( $lr, @s, @n, @o, @e );
leak_free_ok(
    indexes => sub {
	$lr = 1;
	@s  = indexes { $_ > 5 } ( 4 .. 9 );
	@n  = indexes { $_ > 5 } ( 1 .. 5 );
	@o  = indexes { $_ & 1 } ( 10 .. 15 );
	@e  = indexes { !( $_ & 1 ) } ( 10 .. 15 );
    }
);
$lr and is_deeply( \@s, [ 2 .. 5 ], "indexes/leak: some" );
$lr and is_deeply( \@n, [],         "indexes/leak: none" );
$lr and is_deeply( \@o, [ 1, 3, 5 ], "indexes/leak: odd" );
$lr and is_deeply( \@e, [ 0, 2, 4 ], "indexes/leak: even" );

leak_free_ok(
    indexes => sub {
	@s = indexes { grow_stack; $_ > 5 } ( 4 .. 9 );
	@n = indexes { grow_stack; $_ > 5 } ( 1 .. 4 );
	@o = indexes { grow_stack; $_ & 1 } ( 10 .. 15 );
	@e = indexes { grow_stack; !( $_ & 1 ) } ( 10 .. 15 );
    }
);

$lr and is_deeply( \@s, [ 2 .. 5 ], "indexes/leak: some" );
$lr and is_deeply( \@n, [],         "indexes/leak: none" );
$lr and is_deeply( \@o, [ 1, 3, 5 ], "indexes/leak: odd" );
$lr and is_deeply( \@e, [ 0, 2, 4 ], "indexes/leak: even" );

if ($have_scalar_util)
{
    my $ref = \( indexes( sub { 1 }, 123 ) );
    Scalar::Util::weaken($ref);
    is( $ref, undef, "weakened away" );
}
is_dying( 'indexes without sub' => sub { &indexes( 42, 4711 ); } );

done_testing;
