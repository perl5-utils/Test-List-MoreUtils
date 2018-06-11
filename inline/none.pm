
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(none  { not defined } @list);
is_true(none  { $_ > 10000 } @list);
is_false(none { defined } @list);
is_true(none {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_true(none { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_true(none { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    none => sub {
        my $ok  = none { $_ == 5000 } @list;
        my $ok2 = none { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = none { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = none { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = none { die } (0 .. 2);
        };
    }
);
is_dying('none without sub' => sub { &none(42, 4711); });
is_dying(
    'none undef *_' => sub {
        none { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
