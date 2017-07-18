
use Test::More;
use Test::LMU;

my @x = after_incl { $_ % 5 == 0 } 1 .. 9;
ok( is_deeply( \@x, [ 5, 6, 7, 8, 9 ] ) );
@x = after_incl { /foo/ } my @dummy = qw{ bar baz };
is_deeply( \@x, [], 'Got the null list' );
@x = after_incl { /b/ } @dummy = qw{ bar baz foo };
ok( is_deeply( \@x, [qw{ bar baz foo }] ) );

leak_free_ok(
    after_incl => sub {
	@x = after_incl { /z/ } @dummy = qw{ bar baz foo };
    }
);
is_dying( 'after_incl without sub' => sub { &after_incl( 42, 4711 ); } );

done_testing;
