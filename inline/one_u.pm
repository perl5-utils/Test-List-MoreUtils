
use Test::More;
use Test::LMU;

# Normal cases
my @list = (1 .. 300);
is_true(one_u  { 1 == $_ } @list);
is_true(one_u  { 150 == $_ } @list);
is_true(one_u  { 300 == $_ } @list);
is_false(one_u { 0 == $_ } @list);
is_false(one_u { 1 <= $_ } @list);
is_false(one_u { !(127 & $_) } @list);
is_undef(one_u {});

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is_false(one_u { $_ eq lc $_ } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is_false(one_u { $_ eq lc $_ } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    one_u => sub {
        my $ok  = one_u { 150 <= $_ } @list;
        my $ok2 = one_u { 150 <= $_ } 1 .. 300;
    },
    "undef" => sub {
        my $ok = one_u { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = one_u { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = one_u { die } (0 .. 2);
        };
    }
);
is_dying('one_u without sub' => sub { &one_u(42, 4711); });
is_dying(
    'one_u undef *_' => sub {
        one_u { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
