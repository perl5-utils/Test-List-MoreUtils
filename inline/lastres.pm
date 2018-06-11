BEGIN
{
    $INC{'List/MoreUtils.pm'} or *last_result = __PACKAGE__->can("lastres");
}

use Test::More;
use Test::LMU;

my $x = lastres { 2 * ($_ > 5) } 4 .. 9;
is($x, 2);
$x = lastres { $_ > 5 } 1 .. 4;
is($x, undef);

# Test aliases
$x = last_result { $_ > 5 } 4 .. 9;
is($x, 1);
$x = last_result { $_ > 5 } 1 .. 4;
is($x, undef);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, lastres { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(1, lastres { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    lastres => sub {
        $x = lastres { $_ > 5 } 4 .. 9;
    },
    "undef" => sub {
        my $ok = lastres { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = lastres { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = lastres { die } (0 .. 2);
        };
    }
);
is_dying('lastres without sub' => sub { &lastres(42, 4711); });
is_dying(
    'lastres undef *_' => sub {
        lastres { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
