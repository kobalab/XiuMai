use strict;
use Test::More 0.98;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::HTML::Folder'); }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::HTML::Folder::VERSION, $XiuMai::VERSION, '$VERSION');

done_testing;
