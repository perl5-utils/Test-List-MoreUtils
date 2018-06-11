
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(all  { defined } @list);
is_true(all  { $_ > 0 } @list);
is_false(all { $_ < 5000 } @list);
is_true(all {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(all { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(all { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    all => sub {
        my $ok  = all { $_ == 5000 } @list;
        my $ok2 = all { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = all { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = all { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = all { die } (0 .. 2);
        };
    }
);
is_dying('all without sub' => sub { &all(42, 4711); });
is_dying(
    'all undef *_' => sub {
        all { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
