
use Test::More;
use Test::LMU;

# The null set should return zero
my $null_scalar = true {};
my @null_list   = true {};
is($null_scalar, 0, 'true(null) returns undef');
is_deeply(\@null_list, [0], 'true(null) returns undef');

# Normal cases
my @list = (1 .. 10000);
is(10000, true { defined } @list);
is(0,     true { not defined } @list);
is(1,     true { $_ == 5000 } @list);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(true { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(true { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    true => sub {
        my $n  = true { $_ == 5000 } @list;
        my $n2 = true { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = true { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = true { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = true { die } (0 .. 2);
        };
    }
);
is_dying('true without sub' => sub { &true(42, 4711); });
is_dying(
    'true undef *_' => sub {
        true { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
