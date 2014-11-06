use strict;
use warnings;
use Test::More 0.98;
use t::IT;
use File::Path;

rmtree($ENV{XIUMAI_HOME});

my $xiumai_url = 'http://example.com';

my @TEST_CASE = (
    { name => 'Set up',
      req  => [ GET => $xiumai_url ],
      res  => { code    => 200,
                type    => 'text/html; charset=utf-8',
                content => [
                    qr{<title>SignUp</title>},
                    qr{<form class="x-signup_form" },
                ]
              }
    },
    { name => 'First sign up and login',
      req  => [ POST => $xiumai_url,
                [ cmd        => 'signup',
                  login_name => 'admin',
                  passwd     => 'passwd' ]
              ],
      res  => { code    => 303,
                header  => { location   => $xiumai_url,
                             set_cookie => qr{^XIUMAI_AUTH=\w{32};} },
              }
    },
    { name => 'Access top page and redirect',
      req  => [ GET => $xiumai_url ],
      res  => { code    => 301,
                header  => { location => "$xiumai_url/" }
              }
    },
    { name => 'Display initial page',
      req  => [ GET => "$xiumai_url/" ],
      res  => { code => 200,
                content => [
                    qr{<title>Folder:/</title>},
                    qr{<a\ href="\?cmd=logout&amp;session_id=\w{40}">
                        Logout</a>}x,
                    qr{<a href="\?cmd=edit" accesskey="e">Edit</a>},
                    qr{<table\ class="x-file_list">(?:(?!</table>).)*
                        <tbody>\s*</tbody>\s*</table>}xs,
                ],
              }
    },
    { name => 'Logout and redirect',
      req  => [ GET => "$xiumai_url/",
                [ cmd        => 'logout',
                  session_id => undef ]
              ],
      res  => { code   => 303,
                header  => { location   => "$xiumai_url/",
                             set_cookie => qr{^XIUMAI_AUTH=\w{32};} },
              }
    },
    { name => 'Logout done',
      req  => [ GET => "$xiumai_url/" ],
      res  => { code => 200,
                header  => { set_cookie => undef },
                content => [ qr{<a href="\?cmd=login">Login</a>}, ],
              }
    },
    { name => 'Display login_form',
      req  => [ GET => "$xiumai_url/",
                [ cmd => 'login' ]
              ],
      res  => { content => [
                    qr{<title>Login</title>},
                    qr{<form class="x-login_form" },
                ]
              }
    },
    { name => 'Login error',
      req  => [ POST => "$xiumai_url/",
                [ cmd        => 'login',
                  login_name => 'admin',
                  passwd     => '' ]
              ],
      res  => { code => 401 }
    },
    { name => 'Login and redirect',
      req  => [ POST => "$xiumai_url/",
                [ cmd        => 'login',
                  login_name => 'admin',
                  passwd     => 'passwd' ]
              ],
      res  => { code => 303,
                header => { location => "$xiumai_url/",
                            set_cookie => qr{^XIUMAI_AUTH=\w{32};} },
              }
    },
    { name => 'Login dene',
      req  => [ GET => "$xiumai_url/" ],
      res  => { code => 200,
                header => { set_cookie => qr{^XIUMAI_AUTH=\w{32};} },
                content => [
                    qr{<title>Folder:/</title>},
                    qr{<a\ href="\?cmd=logout&amp;session_id=\w{40}">
                        Logout</a>}x,
                    qr{<a href="\?cmd=edit" accesskey="e">Edit</a>},
                ],
              }
    },
);

{
    local %ENV;
    delete $ENV{XIUMAI_HOME};

    do_test(
        name => 'XIUMAI_HOME not set',
        req  => [ GET => $xiumai_url ],
        res  => { code => 500,
                  content => [
                      qr{<p class="x-error">\$XIUMAI_HOME not set\.</p>},
                  ]
                }
    );
}
for (@TEST_CASE) { do_test(%$_); }

done_testing;
