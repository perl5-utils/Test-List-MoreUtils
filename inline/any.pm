
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(any  { $_ == 5000 } @list);
is_true(any  { $_ == 5000 } 1 .. 10000);
is_true(any  { defined } @list);
is_false(any { not defined } @list);
is_true(any  { not defined } undef);
is_false(any {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(any { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(any { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    any => sub {
        my $ok  = any { $_ == 5000 } @list;
        my $ok2 = any { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = any { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = any { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        # This test is from Kevin Ryde; see RT#48669
        eval {
            my $ok = any { die } 1;
        };
    }
);
is_dying('any without sub' => sub { &any(42, 4711); });
is_dying(
    'any undef *_' => sub {
        any { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
