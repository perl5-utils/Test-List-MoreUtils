
use Test::More;
use Test::LMU;

# The null set should return zero
my $null_scalar = false {};
my @null_list   = false {};
is($null_scalar, 0, 'false(null) returns undef');
is_deeply(\@null_list, [0], 'false(null) returns undef');

# Normal cases
my @list = (1 .. 10000);
is(10000, false { not defined } @list);
is(0,     false { defined } @list);
is(1,     false { $_ > 1 } @list);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_true(false { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_true(false { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    false => sub {
        my $n  = false { $_ == 5000 } @list;
        my $n2 = false { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = false { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = false { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = false { die } (0 .. 2);
        };
    }
);
is_dying('false without sub' => sub { &false(42, 4711); });
is_dying(
    'false undef *_' => sub {
        false { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
