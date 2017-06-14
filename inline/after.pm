
use Test::More;
use Test::LMU;

my @x = after { $_ % 5 == 0 } 1 .. 9;
ok( is_deeply( \@x, [ 6, 7, 8, 9 ] ) );
@x = after { /foo/ } my @dummy = qw{ bar baz };
is_deeply( \@x, [], 'Got the null list' );
@x = after { /b/ } @dummy = qw{ bar baz foo };
ok( is_deeply( \@x, [qw{ baz foo }] ) );

leak_free_ok(
    after => sub {
	@x = after { /z/ } @dummy = qw{ bar baz foo };
    }
);
is_dying( sub { &after( 42, 4711 ); } );

@x = ( 1, after { /foo/ } qw(abc def) );
is_deeply(\@x, [ 1 ], "check XS implementation doesn't mess up stack");

done_testing;
