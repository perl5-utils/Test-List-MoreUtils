
use Test::More;
use Test::LMU;

my @even = map { $_ * 2 } 1 .. 100;
my @odd  = map { $_ * 2 - 1 } 1 .. 100;
my @expected;

@in = @even;
@expected = mesh @odd, @even;
foreach my $v (@odd) { binsert { $_ <=> $v } $v, @in }
is_deeply(\@in, \@expected, "binsert odd elements into even list succeeded");

@in = @odd;
foreach my $v (@even) { binsert { $_ <=> $v } $v, @in }
is_deeply(\@in, \@expected, "binsert even elements into odd list succeeded");

leak_free_ok(
    binsert => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        binsert { $_ <=> $elem } $elem, @list;
    }
);

leak_free_ok(
    'binsert with stack-growing' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        binsert { grow_stack(); $_ <=> $elem } $elem, @list;
    }
);

leak_free_ok(
    'binsert with stack-growing and exception' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int( rand(100) ) + 1;
        eval {
            binsert { grow_stack(); $_ <=> $elem or die "Goal!"; $_ <=> $elem } $elem, @list;
        };
    }
);

is_dying( 'binsert without sub' => sub { &binsert( 42, @even ); } );

done_testing;
