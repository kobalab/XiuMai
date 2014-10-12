use strict;
use Test::More 0.98;
use HTTP::Request::Common;
use HTTP::Request::AsCGI;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Response');  }

#
#   Class Variables
#
is($XiuMai::Response::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
isa_ok( new XiuMai::Response, 'XiuMai::Response', 'new XiuMai::Response');

done_testing;
