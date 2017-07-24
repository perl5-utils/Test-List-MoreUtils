
use Test::More;
use Test::LMU;

my @even = map { $_ * 2 } 1 .. 100;
my @odd  = map { $_ * 2 - 1 } 1 .. 100;
my @expected;

@expected = @even;
@in = mesh @odd, @even;
foreach my $v (@odd) { is( $v, (btree_remove { $_ <=> $v } @in), "$v in order removed" ) }
is_deeply(\@in, \@expected, "btree_remove all odd elements succeeded");

@in = mesh @odd, @even;
foreach my $v (reverse @odd) { is( $v, (btree_remove { $_ <=> $v } @in), "$v reverse ordered removed" ) }
is_deeply(\@in, \@expected, "btree_remove all odd elements reversely succeeded");

@expected = @odd;
@in = mesh @odd, @even;
foreach my $v (@even) { is( $v, (btree_remove { $_ <=> $v } @in), "$v in order removed" ); }
is_deeply(\@in, \@expected, "btree_remove all even elements succeeded");

@in = mesh @odd, @even;
foreach my $v (reverse @even) { is( $v, (btree_remove { $_ <=> $v } @in), "$v reverse ordered removed" ); }
is_deeply(\@in, \@expected, "btree_remove all even elements reversely succeeded");

leak_free_ok(
    'btree_remove first' => sub {
        my @list = (1 .. 100);
	my $v = $list[0];
        btree_remove { $_ <=> $v } @list
    },
    'btree_remove last' => sub {
        my @list = (1 .. 100);
	my $v = $list[-1];
        btree_remove { $_ <=> $v } @list
    },
    'btree_remove middle' => sub {
        my @list = (1 .. 100);
	my $v = $list[int($#list/2)];
        btree_remove { $_ <=> $v } @list
    },
);

leak_free_ok(
    'btree_remove first with stack-growing' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[0];
        btree_remove { grow_stack(); $_ <=> $v } @list
    },
    'btree_remove last with stack-growing' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[-1];
        btree_remove { grow_stack(); $_ <=> $v } @list
    },
    'btree_remove middle with stack-growing' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[int($#list/2)];
        btree_remove { grow_stack(); $_ <=> $v } @list
    },
);

leak_free_ok(
    'btree_remove first with stack-growing and exception' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[0];
        eval { btree_remove { grow_stack(); $_ <=> $v or die "Goal!"; $_ <=> $v } @list };
    },
    'btree_remove last with stack-growing and exception' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[-1];
        eval { btree_remove { grow_stack(); $_ <=> $v or die "Goal!"; $_ <=> $v } @list };
    },
    'btree_remove middle with stack-growing and exception' => sub {
        my @list = mesh @odd, @even;
	my $v = $list[int($#list/2)];
        eval { btree_remove { grow_stack(); $_ <=> $v or die "Goal!"; $_ <=> $v } @list };
    },
);
is_dying( 'btree_remove without sub' => sub { &btree_remove( 42, @even ); } );

done_testing;
