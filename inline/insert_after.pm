
use Test::More;
use Test::LMU;

my @list = qw{This is a list};
insert_after { $_ eq "a" } "longer" => @list;
is(join(' ', @list), "This is a longer list", "defaut use case: found");
insert_after { 0 } "bla" => @list;
is(join(' ', @list), "This is a longer list", "default use cause: not found");
insert_after { $_ eq "list" } "!" => @list;
is(join(' ', @list), "This is a longer list !", "edge use case: append");
@list = (qw{This is}, undef, qw{list});
insert_after { not defined($_) } "longer" => @list;
$list[2] = "a";
is(join(' ', @list), "This is a longer list", "edge use case: undef in list");

my @vl = qw{This is a list};
insert_after { lc $_ eq "a" } "longer" => @vl;
is(join(' ', @vl), "This is a longer list", "\@list remains untouched");

leak_free_ok(
    insert_after => sub {
        @list = qw{This is a list};
        insert_after { $_ eq 'a' } "longer" => @list;
    },
    'insert_after with exception on overload' => sub {
        eval {
            my @list = (qw{This is}, DieOnStringify->new, qw{a list});
            insert_after { $_ eq 'a' } "longer" => @list;
        };
        undef $_;    # $_ is refcounted on it's own, this is not an issue
    },
    'insert_after with exception' => sub {
        eval {
            my @list = (qw{This is a list});
            insert_after { $_ eq 'is' and die "Bad word"; $_ eq 'a' } "longer" => @list;
        };
    }
);
is_dying('insert_after without sub' => sub { &insert_after(42, 4711, [qw(die bart die)]); });
is_dying('insert_after without sub and array' => sub { &insert_after(42, 4711, "13"); });
is_dying(
    'insert_after without array' => sub {
        &insert_after(sub { }, 4711, "13");
    }
);
is_dying(
    'insert_after undef *_' => sub {
        my @list = (qw{This is a list});
        insert_after { $_ eq 'is' and undef *_ unless $_ eq 'a' } "longer" => @list;
    }
);

done_testing;
