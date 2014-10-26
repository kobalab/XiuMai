use strict;
use Test::More 0.98;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Locale'); }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::Locale::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
ok(my @lang = XiuMai::Locale::lang, 'XiuMai::Lang::lang > 0');

for my $l (XiuMai::Locale::lang) {
    ok(XiuMai::Locale::get($l),          "XiuMai::Locale::get($l)");
    is((XiuMai::Locale::get($l))[1], $l, "XiuMai::Locale::get($l)[1]");
}

my @TEST_CASE = (
    [ [ 'ja-JP' ],              'ja'    ],
    [ [ 'zh-cn' ],              'zh-CN' ],
    [ [ 'zh'    ],              'en'    ],
    [ [ 'ja-JP', 'zh-cn' ],     'zh-CN' ],
    [ [ 'ja-JP', 'en-US' ],     'ja'    ],
    [ [ ],                      'en'    ],
);
for my $case (@TEST_CASE) {
    my ($l, $m) = @$case;
    is((XiuMai::Locale::get(@$l))[1], $m, "XiuMai::Locale::get(@$l) -> $m");
}

done_testing;
