BEGIN
{
    $INC{'List/MoreUtils.pm'} or *first_result = __PACKAGE__->can("firstres");
}

use Test::More;
use Test::LMU;

my $x = firstres { 2 * ($_ > 5) } 4 .. 9;
is($x, 2);
$x = firstres { $_ > 5 } 1 .. 4;
is($x, undef);

# Test aliases
$x = first_result { $_ > 5 } 4 .. 9;
is($x, 1);
$x = first_result { $_ > 5 } 1 .. 4;
is($x, undef);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, firstres { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(1, firstres { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    firstres => sub {
        $x = firstres { $_ > 5 } 4 .. 9;
        my @l = (4 .. 9);
        my $x2 = firstres { $_ > 5 } @l;
    },
    "undef" => sub {
        my $ok = firstres { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = firstres { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = firstres { die } (0 .. 2);
        };
    }
);
is_dying('firstres without sub' => sub { &firstres(42, 4711); });
is_dying(
    'firstres undef *_' => sub {
        firstres { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
