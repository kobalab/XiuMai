use strict;
use Test::More 0.98;
use File::Path;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::SetUp');  }

#
#   Class Variables
#
is($XiuMai::SetUp::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Functions
#
my $dir = $ENV{PWD}.'/t/.tmp';

#   Initial
rmtree($dir);
cmp_ok(XiuMai::SetUp::_get_version($dir), '==', 0,  '_get-version: initial');
ok    (! defined XiuMai::SetUp::_set_version($dir), '_set_version: initial');

#   Dir exists
mkpath($dir);
cmp_ok(XiuMai::SetUp::_get_version($dir), '==', 0,  '_get-version => 0');
ok    (my $v = XiuMai::SetUp::_set_version($dir),   '_set_version => version');
cmp_ok(XiuMai::SetUp::_get_version($dir), '==', $v, '_get_version == version');

#   Set up
rmtree($dir);
XiuMai::SetUp::_setup_home($dir);
ok    (-f "$dir/etc/passwd",    '_setup_home: etc/passwd');
ok    (-d "$dir/var/cookie",    '_setup_home: var/cookie');
ok    (-d "$dir/var/signup",    '_setup_home: var/signup');
XiuMai::SetUp::_setup_data($dir);
ok    (-d "$dir/data",          '_setup_data: data');
rmtree($dir);

#
#   Set Up XiuMai
#
$ENV{XIUMAI_HOME} = "$ENV{PWD}/t/.xiumai";
rmtree($ENV{XIUMAI_HOME});
ok    (! XiuMai::SetUp::setup,              'setup => undef');
ok    (-f XiuMai::HOME().'/etc/passwd',     'setup: HOME/etc/passwd');
ok    (-d XiuMai::HOME().'/var/cookie',     'setup: HOME/var/cookie');
ok    (-d XiuMai::HOME().'/var/signup',     'setup: HOME/var/signup');
ok    (-d XiuMai::DATA().'/data',           'setup: HOME/data');

$ENV{XIUMAI_DATA} = "$ENV{PWD}/t/.xiumai-data";
rmtree($ENV{XIUMAI_DATA});
ok    (! XiuMai::SetUp::setup,              'setup => undef');
ok    (-d XiuMai::DATA().'/data',           'setup: DATA/data');

rmtree($ENV{XIUMAI_HOME});
rmtree($ENV{XIUMAI_DATA});

done_testing;
