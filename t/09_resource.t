use strict;
use Test::More 0.98;
use HTTP::Request::Common;
use HTTP::Request::AsCGI;
use File::Path;

#
#   Set up
#
$ENV{XIUMAI_HOME} = "$ENV{PWD}/t/.xiumai";

mkpath("$ENV{XIUMAI_HOME}/data");
open OUT, ">$ENV{XIUMAI_HOME}/data/test.png"
                                or die "$ENV{XIUMAI_HOME}/data/test.png: $!";
print OUT '*' x 1024;
close OUT;
my $mtime = time;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Resource');  }

#
#   Class Variables
#
is($XiuMai::Resource::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class and Instance Methods
#
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/test.png'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r,          'XiuMai::Resource', 'new XiuMai::Resource');
    is    ($r->type,    'image/png',      '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    cmp_ok($r->size,    '==', 1024,       '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   redirect
    ok    (! $r->redirect,                '$r->redirect');
    ok    ($r->redirect(303, '/') == $r,  '$r->redirect(code, uri)');
    eq_array(\($r->redirect), [303, '/'], '$r->redirect -> (code, uri)');

    #   open
    ok    ($r->open == $r,                '$r->open');
    is    ($r->type,    'image/png',      '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    cmp_ok($r->size,    '==', 1024,       '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   convert
    ok    ($r->convert == $r,             '$r->convert');
    is    ($r->type,    'image/png',      '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    cmp_ok($r->size,    '==', 1024,       '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   print
    print $res->_header;
    ok    (! $r->print,                   '$r->print');
    my $o = $c->restore->response;
    cmp_ok(length ($o->decoded_content || $o->content), '==', 1024,
                                          'output data size');
}
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/not_found'
    )->setup;
    my $req = new XiuMai::Request;

    #   not found
    ok(! XiuMai::Resource->new($req),     'Not Found');
}

rmtree($ENV{XIUMAI_HOME});

done_testing;
