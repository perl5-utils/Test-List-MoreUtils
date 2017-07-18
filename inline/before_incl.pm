
use Test::More;
use Test::LMU;

my @x = before_incl { $_ % 5 == 0 } 1 .. 9;
ok( is_deeply( \@x, [ 1, 2, 3, 4, 5 ] ) );
@x = before_incl { /foo/ } my @dummy = qw{ bar baz };
ok( is_deeply( \@x, [qw{ bar baz }] ) );
@x = before_incl { /f/ } @dummy = qw{ bar baz foo };
ok( is_deeply( \@x, [qw{ bar baz foo }] ) );

leak_free_ok(
    before_incl => sub {
	@x = before_incl { /z/ } @dummy = qw{ bar baz foo };
    }
);
is_dying( 'before_incl without sub' => sub { &before_incl( 42, 4711 ); } );

done_testing;
