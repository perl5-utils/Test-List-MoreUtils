
use Test::More;
use Test::LMU;

my @even = map { $_ * 2 } 1 .. 100;
my @odd  = map { $_ * 2 - 1 } 1 .. 100;
my @expected;

@in = @even;
@expected = mesh @odd, @even;
foreach my $v (@odd) { btree_insert { $_ <=> $v } $v, @in }
is_deeply(\@in, \@expected, "btree_insert odd elements into even list succeeded");

@in = @odd;
foreach my $v (@even) { btree_insert { $_ <=> $v } $v, @in }
is_deeply(\@in, \@expected, "btree_insert even elements into odd list succeeded");

leak_free_ok(
    btree_insert => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        btree_insert { $_ <=> $elem } $elem, @list;
    }
);

leak_free_ok(
    'btree_insert with stack-growing' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        btree_insert { grow_stack(); $_ <=> $elem } $elem, @list;
    }
);

leak_free_ok(
    'btree_insert with stack-growing and exception' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        eval {
            btree_insert { grow_stack(); $_ <=> $elem or die "Goal!"; $_ <=> $elem } $elem, @list;
        };
    }
);

is_dying( 'btree_insert without sub' => sub { &btree_insert( 42, @even ); } );

done_testing;
