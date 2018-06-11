BEGIN
{
    $INC{'List/MoreUtils.pm'} or *only_result = __PACKAGE__->can("onlyres");
}

use Test::More;
use Test::LMU;

my @list = (1 .. 300);
is("Hallelujah", onlyres { 150 == $_ and "Hallelujah" } @list);
is(1,            onlyres { 300 == $_ } @list);
is(undef,        onlyres { 0 == $_ } @list);
is(undef,        onlyres { 1 <= $_ } @list);
is(undef,        onlyres { !(127 & $_) } @list);

# Test aliases
is(1,            only_result { 150 == $_ } @list);
is("Hallelujah", only_result { 300 == $_ and "Hallelujah" } @list);
is(undef,        only_result { 0 == $_ } @list);
is(undef,        only_result { 1 <= $_ } @list);
is(undef,        only_result { !(127 & $_) } @list);

# Test derived from RT#96343
my %hash = (
    'Jim'         => 1,
    'HellO WorlD' => 1,
    'Baudelaire'  => 1
);
is(1, onlyres { lc $_ eq 'hello world' } keys %hash);
ok(defined $hash{Jim}, "It's Jim");

my @words = qw(HellO WorlD);
is(1, onlyres { lc $_ eq 'hello' } @words);
is_deeply(\@words, [qw(HellO WorlD)], 'HellO WorlD');

leak_free_ok(
    onlyres => sub {
        my $ok  = onlyres { 150 <= $_ } @list;
        my $ok2 = onlyres { 150 <= $_ } 1 .. 300;
    },
    "undef" => sub {
        my $ok = onlyres { undef $_; 1 } (0 .. 2);
    },
    'undef *_' => sub {
        eval {
            my $ok = onlyres { undef *_; 1 } (0 .. 2);
        };
        *_ = \'';
    },
    'dying ...' => sub {
        eval {
            my $ok = onlyres { die } (0 .. 2);
        };
    }
);
is_dying('onlyres without sub' => sub { &onlyres(42, 4711); });
is_dying(
    'onlyres undef *_' => sub {
        onlyres { undef *_; 1 } (0 .. 2);
    }
);

done_testing;
