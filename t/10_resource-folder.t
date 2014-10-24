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

    #   open
    ok    ($r->open == $r,                '$r->open');
    ok    (! defined $r->type,            '$r->type');      # type
    is    ($r->charset, '',               '$r->charset');   # charset
    ok    (! defined $r->size,            '$r->size');      # size
    cmp_ok($r->mtime,   '==', $mtime,     '$r->mtime');     # mtime

    #   file
    cmp_ok(my @file = $r->file, '==', 3,  '$r->file == 3');
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

rmtree($ENV{XIUMAI_HOME});

done_testing;
