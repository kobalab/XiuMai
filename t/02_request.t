use strict;
use Test::More 0.98;
use HTTP::Request::Common;
use HTTP::Request::AsCGI;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Request');  }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::Request::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
isa_ok( new XiuMai::Request, 'XiuMai::Request', 'new XiuMai::Request');

#
#   Instance Methods
#
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/path/?key1=val1&key2=val2-1&key2=val2-2'
    )->setup;

    local $ENV{HTTP_HOST}; $ENV{HTTP_HOST} =~ s/:80$//;

    my $r = new XiuMai::Request;

    is($r->method, 'GET',                               'GET $r->method');
    is($r->scheme, 'http',                              'GET $r->scheme');
    is($r->host,   'example.com',                       'GET $r->host');
    is($r->url,    '/path/',                            'GET $r->url');
    is($r->query,  'key1=val1&key2=val2-1&key2=val2-2', 'GET $r->query');

    my @key = $r->param;
    eq_set(\@key, [ 'key1','key2' ],        'GET $r->param');
    is($r->param('key2'), 'val2-1',         'GET my $v = $r->param(key)');
    my @val = $r->param('key2');
    eq_array(\@val, [ 'val2-1','val2-2' ],  'GET my @v = $r->param(key)');
}
{
    my $c = HTTP::Request::AsCGI->new(
                POST 'https://example.com:443/path/',
                    [ key1 => 'val1',
                      key2 => [ 'val2-1','val2-2' ] ]
            )->setup;

    my $r = new XiuMai::Request;

    is  ($r->method, 'POST',                        'POST $r->method');
    is  ($r->scheme, 'https',                       'POST $r->scheme');
    is  ($r->host,   'example.com:443',             'POST $r->host');
    is  ($r->url,    '/path/',                      'POST $r->url');
    is  ($r->query,  '',                            'POST $r->query');

    my @key = $r->param;
    eq_set(\@key, [ 'key1','key2' ],        'POST $r->param');
    is($r->param('key2'), 'val2-1',         'POST my $v = $r->param(key)');
    my @val = $r->param('key2');
    eq_array(\@val, [ 'val2-1','val2-2' ],  'POST my @v = $r->param(key)');
}
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/%E3%83%86%E3%82%B9%E3%83%88'
    )->setup;

    my $r = new XiuMai::Request;

    is  ($r->path_info, '/テスト', '$r->path_info');
}
{
    local $ENV{SERVER_NAME} = 'example.com';
    local $ENV{SERVER_PORT} = 88;

    my $r = new XiuMai::Request;

    is  ($r->host, 'example.com:88', '$r->host, no HTTP_HOST, port 88');
}
{
    local $ENV{SERVER_NAME} = 'example.com';
    local $ENV{SERVER_PORT} = 80;

    my $r = new XiuMai::Request;

    is  ($r->host, 'example.com', '$r->host, no HTTP_HOST, port 80');
}
{
    local $ENV{HTTP_ACCEPT_LANGUAGE} = 'ja, en-us;q=0.8,en;q=0.5,zh-cn;q=0.3';

    my $r = new XiuMai::Request;
    ok(eq_array([$r->accept_language], ['ja','en-us','en','zh-cn']),
                                    '$r->accept_language');
}

done_testing;
