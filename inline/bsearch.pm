
use Test::More;
use Test::LMU;

my @list = my @in = 1 .. 1000;
for my $elem (@in)
{
    ok((scalar bsearch { $_ - $elem } @list), "bsearch $elem in scalar context");
}
for my $elem (@in)
{
    is_deeply([$elem], [bsearch { $_ - $elem } @list], "bsearch $elem in list context");
}
my @out = (-10 .. 0, 1001 .. 1011);
for my $elem (@out)
{
    my $r = bsearch { $_ - $elem } @list;
    ok(!defined $r, "bsearch $elem in scalar context");
}

leak_free_ok(
    bsearch => sub {
        my $elem = int(rand(1000)) + 1;
        scalar bsearch { $_ - $elem } @list;
    }
);

leak_free_ok(
    'bsearch with stack-growing' => sub {
        my $elem = int(rand(1000));
        scalar bsearch { grow_stack(); $_ - $elem } @list;
    }
);

leak_free_ok(
    'bsearch with stack-growing and exception' => sub {
        my $elem = int(rand(1000));
        eval {
            scalar bsearch { grow_stack(); $_ - $elem or die "Goal!"; $_ - $elem } @list;
        };
    },
    "undef" => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int(rand(100)) + 1;
        bsearch { my $rc = $_ <=> $elem; undef $_; $rc } @list;
    },
    'undef *_' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int(rand(100)) + 1;
        eval {
            bsearch { my $rc = $_ <=> $elem; undef *_; $rc } @list;
        };
        note $@;
        *_ = \'';
    },
    'finally undef *_' => sub {
        my @list = map { $_ * 2 } 1 .. 100;
        my $elem = int(rand(100)) + 1;
        eval {
            bsearch { my $rc = $_ <=> $elem; undef *_ if $rc == 0; $rc } @list;
        };
        note $@;
        *_ = \'';
    }
);
is_dying('bsearch without sub' => sub { &bsearch(42, (1 .. 100)); });

done_testing;
