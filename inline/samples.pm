
use Test::More;
use Test::LMU;

SCOPE:
{
    my @l = (1 .. 100);
    my @s = samples 10, @l;
    is(scalar @s, 10, "samples stops correctly after 10 integer probes");
    my @u = uniq @s;
    is(scalar @u, 10, "samples doesn't add any integer twice");
}

SCOPE:
{
    my @l = ('AA' .. 'ZZ');
    my @s = samples 10, @l;
    is(scalar @s, 10, "samples stops correctly after 10 strings probes");
    my @u = uniq @s;
    is(scalar @u, 10, "samples doesn't add any string twice");
}

is_dying('to much samples' => sub { my @l = (1 .. 3); samples 5, @l });
is_dying('samples without list' => sub { samples 5 });

done_testing;
