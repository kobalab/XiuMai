use strict;
use Test::More 0.98;

my $msg_tmpl = 't/.msg.tmpl';
open(MSG, ">$msg_tmpl")     or die "$msg_tmpl: $!";
while (<DATA>) {
    print MSG $_;
}
close(MSG);

#
#   Loading module
#
BEGIN {
    use_ok('XiuMai::Util::Msg');
}

#
#   Class Methods
#
ok(! defined XiuMai::Util::Msg->new,    'XiuMai::Util::Msg->new');
ok(! defined XiuMai::Util::Msg->new("/badfile"),
                                        'XiuMai::Util::Msg->new("/badfile")');

ok(my $Msg = new XiuMai::Util::Msg($msg_tmpl),
                                    qq(XiuMai::Util::Msg->new("$msg_tmpl")));
isa_ok($Msg, 'XiuMai::Util::Msg',   '$Msg');

ok(new XiuMai::Util::Msg(\*DATA),     'XiuMai::Util::Mag(DATA)');

my @TEST_CASE = (
    [ [ '#' ],                      '#',                    'comment'       ],
    [ [ 'not found' ],              'not found',            'not found'     ],
    [ [ 'key' ],                    'value',                'no parameter'  ],
    [ [ qw(key1 val1) ],            '(val1)',               '1 parameter'   ],
    [ [ qw(key2 val1 val2) ],       '(val1, val2)',         '2 parameter'   ],
    [ [ qw(key3 val1 val2 val3) ],  '(val1, val2, val3)',   '3 parameter'   ],
    [ [ qw(key4 val1 val2 val3) ],  '(val3, val2, val1)',   'reverse'       ],
    [ [ 'key5', 1+1 ],              'INTEGER: 2',           'integer param' ],
    [ [ 'key6', 1, 2, 3 ],          "line1\nline2\nline3",  'within LF'     ],
);

for my $test (@TEST_CASE) {
    my ($param, $res, $case) = @$test;
    is($Msg->get(@$param), $res, $case);
}

unlink($msg_tmpl);

done_testing;

__END__
#:value
key:value
key1:({$1})
key2:({$1}, {$2})
key3:({$1}, {$2}, {$3})
key4:({$3}, {$2}, {$1})
key5:INTEGER: {$1}
key6:line{$1}
	line{$2}
	line{$3}
