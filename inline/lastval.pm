BEGIN
{
    $INC{'List/MoreUtils.pm'} or *last_value = __PACKAGE__->can("lastval");
}

use Test::More;
use Test::LMU;

my $x = lastval { $_ > 5 } 4 .. 9;
is($x, 9);
$x = lastval { $_ > 5 } 1 .. 4;
is($x, undef);
is_undef(lastval { $_ > 5 });

# Test aliases
$x = last_value { $_ > 5 } 4 .. 9;
is($x, 9);
$x = last_value { $_ > 5 } 1 .. 4;
is($x, undef);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is('HellO WorlD', lastval { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is('HellO', lastval { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    lastval => sub {
        $x = lastval { $_ > 5 } 4 .. 9;
    },
    "undef" => sub {
        my $ok = lastval { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = lastval { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = lastval { die } (0 .. 2);
        };
    }
);
is_dying('lastval without sub' => sub { &lastval(42, 4711); });
is_dying(
    'lastval undef *_' => sub {
        lastval { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
