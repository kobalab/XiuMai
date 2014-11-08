use strict;
use Test::More 0.98;

sub parse_header {
    my $header = shift;
    $header =~ s/\r//gs;
    $header =~ s/\n\n$//s;
    $header =~ s/\n\s/ /g;
    my @header = map { s/\s+/ /g; $_ } split("\n", $header, -1);
    return \@header;
}

sub param_as_string {
    my %param = @_;
    return '( ' . join(', ', map { "$_ => '$param{$_}'" } keys %param) . ' )';
}

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Util::Response');  }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::Util::Response::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
use XiuMai::Util::Request;
my $req = new XiuMai::Util::Request(new CGI);
my $res = new XiuMai::Util::Response($req);
isa_ok($res, 'XiuMai::Util::Response', '$res');

#
#   Instance Methods
#

#   _req

ok($res->_req == $req, '$req->_req == $req');

#   header

my @header_test = (
    { param  => [],
      result => [ "Content-Type: text/html; charset=ISO-8859-1" ]
    },
    { param  => [ -type => 'text/plain' ],
      result => [ "Content-Type: text/plain; charset=ISO-8859-1" ]
    },
    { param  => [ -charset => 'utf-8' ],
      result => [ "Content-Type: text/html; charset=utf-8" ]
    },
    { param  => [ -type => 'text/plain', -charset => 'utf-8' ],
      result => [ "Content-Type: text/plain; charset=utf-8" ]
    },
    { param  => [ -content_type => 'text/plain; charset=utf-8' ],
      result => [ "Content-Type: text/plain; charset=utf-8" ]
    },
    { param  => [ -status => '200' ],
      result => [ "Status: 200",
                  "Content-Type: text/html; charset=ISO-8859-1" ]
    },
    { param  => [ -status => '200', -content_length => 1024 ],
      result => [ "Status: 200",
                  "Content-Type: text/html; charset=ISO-8859-1",
                  "Content-Length: 1024" ]
    },
    { param  => [ -status => 303, -location => './' ],
      result => [ "Status: 303",
                  "Content-Type: text/html; charset=ISO-8859-1",
                  "Location: ./" ]
    },
);
for my $case (@header_test) {
    my $req = new XiuMai::Util::Request(new CGI);
    my $res = new XiuMai::Util::Response($req);

    my $result = $res->header(@{$case->{param}});
    my $param  = param_as_string(@{$case->{param}});

    ok(eq_set(parse_header($result), $case->{result}), '$res->header'.$param)
        or diag("==> got\n", $result,
                "<== expected\n", join("\r\n", @{$case->{result}}));
}

done_testing;
