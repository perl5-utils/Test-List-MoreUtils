BEGIN
{
    $INC{'List/MoreUtils.pm'} or *only_value = __PACKAGE__->can("onlyval");
}

use Test::More;
use Test::LMU;

my @list = (1 .. 300);
is(1,     onlyval { 1 == $_ } @list);
is(150,   onlyval { 150 == $_ } @list);
is(300,   onlyval { 300 == $_ } @list);
is(undef, onlyval { 0 == $_ } @list);
is(undef, onlyval { 1 <= $_ } @list);
is(undef, onlyval { !(127 & $_) } @list);

# Test aliases
is(1,     only_value { 1 == $_ } @list);
is(150,   only_value { 150 == $_ } @list);
is(300,   only_value { 300 == $_ } @list);
is(undef, only_value { 0 == $_ } @list);
is(undef, only_value { 1 <= $_ } @list);
is(undef, only_value { !(127 & $_) } @list);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is('HellO WorlD', onlyval { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is('HellO', onlyval { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    onlyval => sub {
        my $ok  = onlyval { 150 <= $_ } @list;
        my $ok2 = onlyval { 150 <= $_ } 1 .. 300;
    },
    "undef" => sub {
        my $ok = onlyval { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = onlyval { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = onlyval { die } (0 .. 2);
        };
    }
);
is_dying('onlyval without sub' => sub { &onlyval(42, 4711); });
is_dying(
    'onlyval undef *_' => sub {
        onlyval { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
