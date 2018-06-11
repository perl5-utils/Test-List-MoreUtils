
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 300);
is_true(one  { 1 == $_ } @list);
is_true(one  { 150 == $_ } @list);
is_true(one  { 300 == $_ } @list);
is_false(one { 0 == $_ } @list);
is_false(one { 1 <= $_ } @list);
is_false(one { !(127 & $_) } @list);
is_false(one { 0 } ());

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(one { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(one { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    one => sub {
        my $ok  = one { 150 <= $_ } @list;
        my $ok2 = one { 150 <= $_ } 1 .. 300;
    },
    "undef" => sub {
        my $ok = one { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = one { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = one { die } (0 .. 2);
        };
    }
);
is_dying('one without sub' => sub { &one(42, 4711); });
is_dying(
    'one undef *_' => sub {
        one { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
