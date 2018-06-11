
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 10000);
is_true(notall  { !defined } @list);
is_true(notall  { $_ < 10000 } @list);
is_false(notall { $_ <= 10000 } @list);
is_false(notall {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_true(notall { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_true(notall { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    notall => sub {
        my $ok  = notall { $_ == 5000 } @list;
        my $ok2 = notall { $_ == 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = notall { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = notall { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = notall { die } (0 .. 2);
        };
    }
);
is_dying('notall without sub' => sub { &notall(42, 4711); });
is_dying(
    'notall undef *_' => sub {
        notall { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
