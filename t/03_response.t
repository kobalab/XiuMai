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

#   print_error

my @TEST_CASE = (
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
