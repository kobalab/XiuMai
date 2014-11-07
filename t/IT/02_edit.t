use strict;
use warnings;
use Test::More 0.98;
use t::IT;
use HTTP::Date;

my $xiumai_url = 'http://example.com';

my @TEST_CASE = (
    { name => 'Print login form',
      req  => [ GET => $xiumai_url.'/', [ cmd => 'login' ] ],
    },
    { name => 'Login',
      req  => [ POST => $xiumai_url.'/',
                [ cmd        => 'login',
                  login_name => 'admin',
                  passwd     => 'passwd' ]
              ],
      res  => { code    => 303,
                header  => { set_cookie => qr{^XIUMAI_AUTH=\w{32};} },
                content => [ '' ]
              }
    },
    { name => 'Login done',
      req  => [ GET => $xiumai_url.'/' ],
      res  => { content => [
                    qr{<a href="\?cmd=edit" accesskey="e">Edit</a>},
                ]
              }
    },
    { name => 'Print edit form for /',
      req  => [ GET => $xiumai_url.'/',
                [ cmd => 'edit' ]
              ],
      res  => { code    => 200,
                content => [
                    qr{<form class="x-mkfile_form" },
                    qr{<form class="x-mkdir_form" },
                    qr{^(?:(?!<form class="x-rmdir_form" ).)*$}s,
                ]
              }
    },
    { name => 'Remove / not allowed',
      req  => [ POST => $xiumai_url.'/',
                [ session_id => undef ]
              ],
      res  => { code => 403 }
    },
    { name => 'Create /newdir',
      req  => [ POST => $xiumai_url.'/',
                [ session_id => undef,
                  dirname    => 'newdir' ]
              ],
      res  => { code    => 303,
                header  => { location => $xiumai_url.'/newdir/?cmd=edit' },
                content => [ '' ]
              }
    },
    { name => 'Print edit form for /newdir/',
      req  => [ GET => $xiumai_url.'/newdir/', [ cmd => 'edit' ] ],
      res  => { code    => 200,
                content => [
                    qr{<form class="x-mkfile_form" },
                    qr{<form class="x-mkdir_form" },
                    qr{<form class="x-rmdir_form" },
                ]
              }
    },
    { name => 'Add /newdir/test.png',
      req  => [ POST => $xiumai_url.'/newdir/',
                [ session_id => undef,
                  filename   => 'test.png' ]
              ],
      res  => { code    => 303,
                header  => {
                    location => $xiumai_url.'/newdir/test.png?cmd=edit',
                },
                content => [ '' ]
              }
    },
    { name => 'Print file upload form',
      req  => [ GET => $xiumai_url.'/newdir/test.png', [ cmd => 'edit' ] ],
      res  => { content => [
                    qr{<form\ class="x-upload_form"\ method="post"
                        \ action="/newdir/test.png"
                        \ enctype="multipart/form-data">}x,
                ]
              }
    },
    { name => 'Upload test.png',
      req  => [ POST => $xiumai_url.'/newdir/test.png',
                [ session_id => undef,
                  file       => [ $ENV{PWD}.'/css/xiumai.png' ] ]
              ],
      res  => { code    => 303,
                header  => {
                    location => $xiumai_url.'/newdir/?cmd=edit'
                },
                content => [ '' ]
              }
    },
    { name => 'Print uploaded file',
      req  => [ GET => $xiumai_url.'/newdir/test.png' ],
      res  => { code    => 200,
                type    => 'image/png',
                header  => {
                    content_length => -s $ENV{PWD}.'/css/xiumai.png',
                    last_modified  => time2str(time),
                },
              }
    },
    { name => 'Exists test.png in edit form for /newdir/',
      req  => [ GET => $xiumai_url.'/newdir/', [ cmd => 'edit' ] ],
      res  => { content => [
                    qr{<a href="test\.png\?cmd=edit">test\.png</a>},
                ]
              }
    },
    { name => 'Delete test.png',
      req  => [ POST => $xiumai_url.'/newdir/test.png',
                [ session_id => undef,
                  file       => ''  ]
              ],
      res  => { code    => 303,
                header  => { location => $xiumai_url.'/newdir/?cmd=edit' },
                content => [ '' ]
              }
    },
    { name => 'NOT exists test.png now',
      req  => [ GET => $xiumai_url.'/newdir/', [ cmd => 'edit' ] ],
      res  => { content => [ qr{^(?:(?!\btest\.png\b).)*$}s ] }
    },
    { name => 'Remove /newdir',
      req  => [ POST => $xiumai_url.'/newdir/',
                [ session_id => undef ]
              ],
      res  => { code    => 303,
                header  => { location => $xiumai_url.'/?cmd=edit' },
                content => [ '' ]
              }
    },
    { name => 'NOT exists /newdir now',
      req  => [ GET => $xiumai_url.'/' ],
      res  => { content => [ qr{^(?:(?!\bnewdir/\b).)*$}s ] }
    },
);

for (@TEST_CASE) { do_test(%$_); }

done_testing;
