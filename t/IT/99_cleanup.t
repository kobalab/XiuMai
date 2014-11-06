use strict;
use warnings;
use Test::More 0.98;
use t::IT;
use File::Path;

rmtree($ENV{XIUMAI_HOME});

ok(! -d $ENV{XIUMAI_HOME}, "Clean up");

done_testing;
