BEGIN
{
    $INC{'List/MoreUtils.pm'} or *only_index = __PACKAGE__->can("onlyidx");
}

use Test::More;
use Test::LMU;

my @list = (1 .. 300);
is(0,   onlyidx { 1 == $_ } @list);
is(149, onlyidx { 150 == $_ } @list);
is(299, onlyidx { 300 == $_ } @list);
is(-1,  onlyidx { 0 == $_ } @list);
is(-1,  onlyidx { 1 <= $_ } @list);
is(-1,  onlyidx { !(127 & $_) } @list);

# Test aliases
is(0,   only_index { 1 == $_ } @list);
is(149, only_index { 150 == $_ } @list);
is(299, only_index { 300 == $_ } @list);
is(-1,  only_index { 0 == $_ } @list);
is(-1,  only_index { 1 <= $_ } @list);
is(-1,  only_index { !(127 & $_) } @list);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, onlyidx { lc $_ eq 'hello world' } sort keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(0, onlyidx { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    onlyidx => sub {
        my $ok  = onlyidx { 150 <= $_ } @list;
        my $ok2 = onlyidx { 150 <= $_ } 1 .. 300;
    },
    "undef" => sub {
        my $ok = onlyidx { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = onlyidx { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = onlyidx { die } (0 .. 2);
        };
    }
);
is_dying('onlyidx without sub' => sub { &onlyidx(42, 4711); });
is_dying(
    'onlyidx undef *_' => sub {
        onlyidx { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
