BEGIN
{
    $INC{'List/MoreUtils.pm'} or *first_value = __PACKAGE__->can("firstval");
}

use Test::More;
use Test::LMU;

my $x = firstval { $_ > 5 } 4 .. 9;
is($x, 6);
$x = firstval { $_ > 5 } 1 .. 4;
is($x, undef);
is_undef(firstval { $_ > 5 });

# Test aliases
$x = first_value { $_ > 5 } 4 .. 9;
is($x, 6);
$x = first_value { $_ > 5 } 1 .. 4;
is($x, undef);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is('HellO WorlD', firstval { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is('HellO', firstval { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    firstval => sub {
        $x = firstval { $_ > 5 } 4 .. 9;
        my @l = (4 .. 9);
        my $x2 = firstval { $_ > 5 } @l;
    },
    "undef" => sub {
        my $ok = firstval { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = firstval { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = firstval { die } (0 .. 2);
        };
    }
);
is_dying('firstval without sub' => sub { &firstval(42, 4711); });
is_dying(
    'firstval undef *_' => sub {
        firstval { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
