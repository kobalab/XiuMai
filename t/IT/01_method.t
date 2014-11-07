use strict;
use warnings;
use Test::More 0.98;
use t::IT;

my $xiumai_url = 'http://example.com';

my @TEST_CASE = (
    { name => 'HEAD',
      req  => [ HEAD => $xiumai_url.'/' ],
      res  => { code    => 200,
                header  => { content_length => qr{^[1-9]\d*$} },
                content => [ '' ]
              }
    },
    { name => 'GET',
      req  => [ GET => $xiumai_url.'/' ],
      res  => { code    => 200 }
    },
    { name => 'POST',
      req  => [ POST => $xiumai_url.'/' ],
      res  => { code    => 403 }
    },
    { name => 'PUT',
      req  => [ PUT => $xiumai_url.'/' ],
      res  => { code    => 405 }
    },
    { name => 'DELETE',
      req  => [ DELETE => $xiumai_url.'/' ],
      res  => { code    => 405 }
    },
);

for (@TEST_CASE) { do_test(%$_); }

done_testing;
