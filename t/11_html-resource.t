use strict;
use Test::More 0.98;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::HTML::Resource'); }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::HTML::Resource::VERSION, $XiuMai::VERSION, '$VERSION');

done_testing;
