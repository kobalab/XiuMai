use strict;
use Test::More 0.98;
use XiuMai::Request;

#
#   Loading module
#
BEGIN { use_ok('XiuMai::HTML'); }

#
#   Class Variables
#
is($XiuMai::HTML::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
ok(my $html1 = XiuMai::HTML->new(),     'XiuMai::HTML->new()');
isa_ok($html1, 'XiuMai::HTML', ref $html1);

#
#   Instance Methods
#

#   charset

is($html1->charset, 'utf-8',            '$html1->charset');
ok($html1->charset('EUC') == $html1,    '$html->charset(EUC)');
is($html1->charset, 'EUC',              '$html1->charset eq EUC');

#   lang

is($html1->lang, 'en',                  '$html1->lang');
ok($html1->lang('ja-JP') == $html1,     '$html1->lang(ja-JP)');
is($html1->lang, 'ja-JP',               '$html1->lang eq ja-JP');

#   title

is($html1->title, '',                   '$html1->title');
ok($html1->title('Title') == $html1,    '$html1->title(Title)');
is($html1->title, 'Title',              '$html1->title eq Title');

#   icon

ok(defined $html1->icon,                    '$html1->icon');
ok($html1->icon('/favicon.ico') == $html1,  '$html1->icon(/favicon.ico)');
is($html1->icon, '/favicon.ico',            '$html1->icon eq /favicon.ico');

#   stylesheet

cmp_ok(my $s = $html1->stylesheet, '>', 0,  '$html1->stylesheet');
ok($html1->stylesheet('a', 'b') == $html1,  '$html1->stylesheet(a, b)');
eq_array(\($html1->stylesheet), ['a', 'b'], '$html1->stylesheet eq (a, b)');

#   meta

cmp_ok(my @m = $html1->meta, '==', 0,       '$html1->meta');
ok($html1->meta('a', 'b') == $html1,        '$html1->meta(a, b)');
eq_array(\($html1->meta), ['a', 'b'],       '$html1->meta eq (a, b)');

#   lang, accept_language and msg

$html1->lang('en');
is($html1->msg('lang'), 'English',      '$html1->msg (form lang)');

ok(! defined $html1->accept_language,   '! defined $html1->accept_language');
ok($html1->accept_language('ja-JP') == $html1,
                                        '$html1->accept_language(ja-JP)');
is($html1->accept_language, 'ja',       '$html1->accept_language eq ja');
is($html1->msg('lang'), '日本語',       '$html1->msg (form accept_language)');

#
#   Case of create new instance with XiuMai::Request
#
{
    local $ENV{HTTP_ACCEPT_LANGUAGE} = 'zh-cn';
    my $req = new XiuMai::Request;

    ok(my $html2 = XiuMai::HTML->new($req),     'XiuMai::HTML->new($req)');
    isa_ok($html2, 'XiuMai::HTML', ref $html2);

    is($html2->charset, 'utf-8',         '$html2->charset eq utf-8');
    is($html2->accept_language, 'zh-CN', '$html2->accept_language eq zh-CN');
    is($html2->msg('lang'), '简体中文',  '$html2->msg (from Request)');
}

done_testing;
