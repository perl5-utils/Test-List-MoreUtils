BEGIN {
    $INC{'List/MoreUtils.pm'} or *zip = __PACKAGE__->can("mesh");
}

use strict;
use warnings;

use Test::More;
use Test::LMU;

SCOPE:
{
    my @x = qw/a b c d/;
    my @y = qw/1 2 3 4/;
    my @z = mesh @x, @y;
    ok( is_deeply( \@z, [ 'a', 1, 'b', 2, 'c', 3, 'd', 4 ] ) );
}

SCOPE:
{
    # alias check
    my @x = qw/a b c d/;
    my @y = qw/1 2 3 4/;
    my @z = zip @x, @y;
    ok( is_deeply( \@z, [ 'a', 1, 'b', 2, 'c', 3, 'd', 4 ] ) );
}

SCOPE:
{
    my @a = ('x');
    my @b = ( '1', '2' );
    my @c = qw/zip zap zot/;
    my @z = mesh @a, @b, @c;
    ok( is_deeply( \@z, [ 'x', 1, 'zip', undef, 2, 'zap', undef, undef, 'zot' ] ) );
}

SCOPE:
{
    # alias check
    my @a = ('x');
    my @b = ( '1', '2' );
    my @c = qw/zip zap zot/;
    my @z = zip @a, @b, @c;
    ok( is_deeply( \@z, [ 'x', 1, 'zip', undef, 2, 'zap', undef, undef, 'zot' ] ) );
}

# Make array with holes
SCOPE:
{
    my @a = ( 1 .. 10 );
    my @d;
    $#d = 9;
    my @z = mesh @a, @d;
    ok(
	is_deeply(
	    \@z, [ 1, undef, 2, undef, 3, undef, 4, undef, 5, undef, 6, undef, 7, undef, 8, undef, 9, undef, 10, undef, ]
	)
    );
}

leak_free_ok(
    mesh => sub {
	my @x = qw/a b c d/;
	my @y = qw/1 2 3 4/;
	my @z = mesh @x, @y;
    }
);
is_dying( sub { &mesh( 1, 2 ); } );

done_testing;
