use strict;
use Test::More 0.98;
use HTTP::Request::Common;
use HTTP::Request::AsCGI;
use File::Path;

#
#   Set up
#
$ENV{XIUMAI_HOME} = "$ENV{PWD}/t/.xiumai";

my @file = (
    { name => 'test',       size => 10,     type => 'text/x-xiumai' },
    { name => 'test.html',  size => 20,     type => 'text/html'     },
    { name => 'test.png',   size => 30,     type => 'image/png'     },
);

mkpath("$ENV{XIUMAI_HOME}/data/path");
for my $file (@file) {
    my $full_name = "$ENV{XIUMAI_HOME}/data/path/$file->{name}";
    open OUT, ">$full_name"     or die "$full_name: $!";
    print OUT '*' x $file->{size};
    close OUT;
}
my $mtime = time;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Resource::Folder');  }

#
#   Class Variables
#
use XiuMai;
is($XiuMai::Resource::Folder::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class and Instance Methods
#
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/path/'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');
    ok    (! defined $r->type,            '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    ok    (! defined $r->size,            '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   _open
    ok    ($r->_open == $r,               '$r->_open');
    ok    (! defined $r->type,            '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    ok    (! defined $r->size,            '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   file
    cmp_ok(my @file = $r->file, '==', 3,  '$r->file == 3');
    @file = sort { $a->filename cmp $b->filename } @file;
    is    ($file[0]->filename, 'test',    '($r->file)[0]->filename');
    cmp_ok($file[1]->size, '==', 20,      '($r->file)[1]->size'    );
    is    ($file[2]->type, 'image/png',   '($r->file)[2]->type'    );

    #   convert
    ok    ($r->convert == $r,             '$r->convert');
    is    ($r->type, 'text/html',         '$r->type');      # type
    is    ($r->charset, 'utf-8',          '$r->charset');   # charset
    cmp_ok(my $size = $r->size, '>', 0,   '$r->size');      # size
    ok    (! defined $r->mtime,           '$r->mtime');     # mtime

    #   print
    print $res->_header;
    ok    (! $r->print,                   '$r->print');
    my $o = $c->restore->response;
    cmp_ok(length ($o->decoded_content || $o->content), '==', $size,
                                          'output data size');
}
{
    my $c = HTTP::Request::AsCGI->new(
        GET 'http://example.com/path'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');
    ok    (! defined $r->type,            '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    ok    (! defined $r->size,            '$r->size');      # size
    ok    (! $r->mtime,                   '$r->mtime');     # mtime

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 301,                  '$r->redirect code');
    is    ($red[1], '/path/',             '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/', [ filename => 'test.txt' ]
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], 'test.txt?cmd=edit',  '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/', [ filename => 'test.png' ]
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], 'test.png?cmd=edit',  '$r->redirect uri');

    #   file not change
    cmp_ok(-s "$ENV{XIUMAI_HOME}/data/path/test.png", '==', 30,
                                          'file not chang');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/', [ filename => '' ]
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], './?cmd=edit',        '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/', [ dirname => 'newdir' ]
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], 'newdir/?cmd=edit',   '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/', [ dirname => '' ]
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], './?cmd=edit',        '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/newdir/'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    ($r->_update,                   '$r->_update');

    #   redirect
    ok    (my @red = $r->redirect,        '$r->redirect');
    is    ($red[0], 303,                  '$r->redirect code');
    is    ($red[1], '../?cmd=edit',       '$r->redirect uri');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/path/'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    (! $r->_update,                  '$r->_update');
}

rmtree("$ENV{XIUMAI_HOME}/data/path");

{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com/'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    (! $r->_update,                  '$r->_update');
}
{
    my $c = HTTP::Request::AsCGI->new(
        POST 'http://example.com'
    )->setup;
    my $req = new XiuMai::Request;
    my $res = new XiuMai::Response($req);

    #   new
    my $r = new XiuMai::Resource($req);
    isa_ok($r, 'XiuMai::Resource::Folder', 'new XiuMai::Resource::Folder');

    #   _update
    ok    (! $r->_update,                  '$r->_update');
}

rmtree($ENV{XIUMAI_HOME});

done_testing;
