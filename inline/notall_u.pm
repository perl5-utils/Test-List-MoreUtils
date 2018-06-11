
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(notall_u  { !defined } @list);
is_true(notall_u  { $_ < 10000 } @list);
is_false(notall_u { $_ <= 10000 } @list);
is_undef(notall_u {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_true(notall_u { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_true(notall_u { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    notall_u => sub {
        my $ok  = notall_u { $_ == 5000 } @list;
        my $ok2 = notall_u { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = notall_u { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = notall_u { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = notall_u { die } (0 .. 2);
        };
    }
);
is_dying('notall_u without sub' => sub { &notall_u(42, 4711); });
is_dying(
    'notall undef *_' => sub {
        notall_u { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
