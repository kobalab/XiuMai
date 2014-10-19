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

#
#   Instance Methods
#

$XiuMai::NOT_EXIT = 1;      ####    Now, method print_* dones NOT exit !

#   print_redirect

my @TEST_CASE = (
  [ 301, '/index.html',      'http://example.com/index.html'             ],
  [ 301, 'index.html',       'http://example.com/path/index.html'        ],
  [ 301, './index.html',     'http://example.com/path/index.html'        ],
  [ 301, '../index.html',    'http://example.com/index.html'             ],
  [ 303, '/?key=val#frag',   'http://example.com/?key=val#frag'          ],
  [ 303, '?key=val#frag',    'http://example.com/path/file?key=val#frag' ],
  [ 303, './?key=val#frag',  'http://example.com/path/?key=val#frag'     ],
  [ 303, '../?key=val#frag', 'http://example.com/?key=val#frag'          ],
  [ 303, '/#frag',           'http://example.com/#frag'                  ],
  [ 303, '#frag',            'http://example.com/path/file#frag'         ],
  [ 303, './#frag',          'http://example.com/path/#frag'             ],
  [ 303, '../#frag',         'http://example.com/#frag'                  ],
);
for my $case (@TEST_CASE) {
    my ($status, $uri, $exp_uri) = @$case;

    my $c = HTTP::Request::AsCGI->new(GET 'http://example.com/path/file')
                                ->setup;
    local $ENV{HTTP_HOST}; $ENV{HTTP_HOST} =~ s/:80$//;
    my $r = new XiuMai::Response(new XiuMai::Request);

    $r->print_redirect($status, $uri);

    my $res     = $c->restore->response;
    my $new_uri = $res->header('Location');

    cmp_ok($res->code, '==', $status,       "Status code: $status");
    is    ($res->message, $XiuMai::Response::STATUS_LINE{$status},
                                            "Status line: $status");
    is    ($new_uri, $exp_uri,              "Location: $status, $uri");
}

#   print_error

@TEST_CASE = (
    [ 400, [                 ] ],
    [ 401, [                 ] ],
    [ 403, [ '/path/'        ] ],
    [ 404, [ '/path/'        ] ],
    [ 405, [ 'GET', '/path/' ] ],
);
for my $case (@TEST_CASE) {

    my $status = $case->[0];
    my @param  = @{$case->[1]};

    my $c = HTTP::Request::AsCGI->new(GET 'http://example.com/path/')
                                ->setup;
    my $r = new XiuMai::Response(new XiuMai::Request);

    $r->print_error($status);

    my $res     = $c->restore->response;
    my $html    = $res->decoded_content || $res->content;
    my ($title) = $html =~ /<title>(.*?)<\/title>/s;
    my ($msg)   = $html =~ /<p class="x\-error">(.*?)<\/p>/s;

    my $exp_msg = XiuMai::Locale::get->get("error.$status.message", @param);

    cmp_ok($res->code, '==', $status,       "Status code: $status");
    is    ($res->message, $XiuMai::Response::STATUS_LINE{$status},
                                            "Status line: $status");
    is    ($title, "$status $XiuMai::Response::STATUS_LINE{$status}",
                                            "HTML title: $status");
    is    ($msg, $exp_msg,                  "HTML error message: $status");
}

done_testing;
