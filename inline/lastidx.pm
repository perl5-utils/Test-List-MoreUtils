BEGIN
{
    $INC{'List/MoreUtils.pm'} or *last_index = __PACKAGE__->can("lastidx");
}

use Test::More;
use Test::LMU;

my @list = (1 .. 10000);
is(9999, lastidx { $_ >= 5000 } @list);
is(-1,   lastidx { not defined } @list);
is(9999, lastidx { defined } @list);
is(-1, lastidx {});

# Test aliases
is(9999, last_index { $_ >= 5000 } @list);
is(-1,   last_index { not defined } @list);
is(9999, last_index { defined } @list);
is(-1, last_index {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, lastidx { lc $_ eq 'hello world' } sort keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(0, lastidx { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    lastidx => sub {
        my $i  = lastidx { $_ >= 5000 } @list;
        my $i2 = lastidx { $_ >= 5000 } 1 .. 10000;
    },
    "undef" => sub {
        my $ok = lastidx { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = lastidx { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = lastidx { die } (0 .. 2);
        };
    }
);
is_dying('lastidx without sub' => sub { &lastidx(42, 4711); });
is_dying(
    'lastidx undef *_' => sub {
        lastidx { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
