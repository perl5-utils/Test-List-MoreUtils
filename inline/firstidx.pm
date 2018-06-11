BEGIN
{
    $INC{'List/MoreUtils.pm'} or *first_index = __PACKAGE__->can("firstidx");
}

use Test::More;
use Test::LMU;

my @list = (1 .. 10000);
is(4999, (firstidx { $_ >= 5000 } @list),  "firstidx");
is(-1,   (firstidx { not defined } @list), "invalid firstidx");
is(0,    (firstidx { defined } @list),     "real firstidx");
is(-1, (firstidx {}), "empty firstidx");

# Test the alias
is(4999, first_index { $_ >= 5000 } @list);
is(-1,   first_index { not defined } @list);
is(0,    first_index { defined } @list);
is(-1, first_index {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, firstidx { lc $_ eq 'hello world' } sort keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(0, firstidx { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    firstidx => sub {
        my $i  = firstidx { $_ >= 5000 } @list;
        my $i2 = firstidx { $_ >= 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = firstidx { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = firstidx { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = firstidx { die } (0 .. 2);
        };
    }
);
is_dying('firstidx without sub' => sub { &firstidx(42, 4711); });
is_dying(
    'firstidx undef *_' => sub {
        firstidx { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
