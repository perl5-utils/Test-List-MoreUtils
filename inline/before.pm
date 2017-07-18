
use Test::More;
use Test::LMU;

my @x = before { $_ % 5 == 0 } 1 .. 9;
ok( is_deeply( \@x, [ 1, 2, 3, 4 ] ) );
@x = before { /b/ } my @dummy = qw{ bar baz };
is_deeply( \@x, [], 'Got the null list' );
@x = before { /f/ } @dummy = qw{ bar baz foo };
ok( is_deeply( \@x, [qw{ bar baz }] ) );

leak_free_ok(
    before => sub {
	@x = before { /f/ } @dummy = qw{ bar baz foo };
    }
);
is_dying( 'before without sub' => sub { &before( 42, 4711 ); } );

done_testing;
