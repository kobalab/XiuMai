use strict;
use Test::More 0.98;

#
#   Loading module
#
BEGIN { use_ok('XiuMai');  }

# 
#   Class Variables
#
ok  ($XiuMai::VERSION < 1, '$XiuMai::VERSION < 1');
like($XiuMai::PRODUCT_NAME, qr/^XiuMai\/0.\d+(?:\.\d+)?/,
                                             'Product name format');
like($XiuMai::PRODUCT_URL, qr/^https?:\/\//, 'Product URL format');

#
#   Class Methods
#
{
    local $ENV{XIUMAI_HOME} = '/xiumai/home';
    is(XiuMai::HOME, '/xiumai/home', 'XiuMai::HOME()');
    is(XiuMai::DATA, '/xiumai/home', 'XiuMai::DATA(), $XIUMAI_DATA not set');

    local $ENV{XIUMAI_DATA} = '/xiumai/data';
    is(XiuMai::DATA, '/xiumai/data', 'XiuMai::DATA(), $XIUMAI_DATA set now');
}
{
    eval{ XiuMai::HOME };
    ok($@, 'XiuMai::HOME, not set $XIUMAI_HOME or die');
    eval{ XiuMai::DATA };
    ok($@, 'XiuMai::DATA, not set $XIUMAI_HOME or die');

    local $ENV{XIUMAI_DATA} = '/xiumai/data';
    eval{ XiuMai::HOME };
    ok($@, 'Not set $XIUMAI_HOME or die, however set $XIUMAI_DATA');
    eval{ XiuMai::DATA };
    ok(!$@, 'Not set $XIUMAI_HOME but XiuMai::DATA alive');
}

done_testing;
