
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(all_u  { defined } @list);
is_true(all_u  { $_ > 0 } @list);
is_false(all_u { $_ < 5000 } @list);
is_undef(all_u {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(all_u { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(all_u { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    all_u => sub {
        my $ok  = all_u { $_ == 5000 } @list;
        my $ok2 = all_u { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = all_u { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = all_u { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = all_u { die } (0 .. 2);
        };
    }
);
is_dying('all_u without sub' => sub { &all_u(42, 4711); });
is_dying(
    'all undef *_' => sub {
        all_u { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
