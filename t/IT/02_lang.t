use strict;
use warnings;
use Test::More 0.98;
use t::IT;
use HTTP::Date;

my $xiumai_url = 'http://example.com';

my @TEST_CASE = (
    { name => 'Default language',
      req  => [ GET => $xiumai_url.'/' ],
      res  => { content => [ qr{<html lang="en">},
                             qr{<a href="\?cmd=login">Login</a>} ] }
    },
    { name => 'Accept-Language: ja',
      req  => [ GET => $xiumai_url.'/', accept_language => 'ja' ],
      res  => { content => [ qr{<html lang="ja">},
                             qr{<a href="\?cmd=login">ログイン</a>} ] }
    },
    { name => 'Accept-Language: ja-JP',
      req  => [ GET => $xiumai_url.'/', accept_language => 'ja-JP' ],
      res  => { content => [ qr{<html lang="ja">},
                             qr{<a href="\?cmd=login">ログイン</a>} ] }
    },
    { name => 'Accept-Language: zh-CN',
      req  => [ GET => $xiumai_url.'/', accept_language => 'zh-CN' ],
      res  => { content => [ qr{<html lang="zh-CN">},
                             qr{<a href="\?cmd=login">登录</a>} ] }
    },
    { name => 'Accept-Language: zh',
      req  => [ GET => $xiumai_url.'/', accept_language => 'zh' ],
      res  => { content => [ qr{<html lang="en">},
                             qr{<a href="\?cmd=login">Login</a>} ] }
    },
    { name => 'Accept-Language: ja-JP, zh-CN',
      req  => [ GET => $xiumai_url.'/',
                accept_language => 'ja-JP,zh-CN;q=0.8' ],
      res  => { content => [ qr{<html lang="zh-CN">},
                             qr{<a href="\?cmd=login">登录</a>} ] }
    },
    { name => 'Accept-Language: ja-JP, en-US',
      req  => [ GET => $xiumai_url.'/',
                accept_language => 'ja-JP,en-US;q=0.8' ],
      res  => { content => [ qr{<html lang="ja">},
                             qr{<a href="\?cmd=login">ログイン</a>} ] }
    },
);

for (@TEST_CASE) { do_test(%$_); }

done_testing;
