use strict;
use Test::More 0.98;
use File::Path;
use IO::File;

#
#   Set up
#
$ENV{XIUMAI_HOME} = "$ENV{PWD}/t/.xiumai";
mkpath("$ENV{XIUMAI_HOME}/etc");
my $passwd_file = "$ENV{XIUMAI_HOME}/etc/passwd";
my $fh = new IO::File(">$passwd_file");
while (<DATA>) {
    print $fh $_;
}
$fh->close;
mkpath("$ENV{XIUMAI_HOME}/var/cookie");

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Auth');  }

#
#   Class Variables
#
is($XiuMai::Auth::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Functions
#

#   _login

ok(XiuMai::Auth::_login('john','lennon'),   '_login: success');
ok(! XiuMai::Auth::_login('paul','simon'),  '_login: wrong password');
ok(! XiuMai::Auth::_login('pete','best'),   '_login: login_name not found');

#   _make_auth_cookie

ok(my $cookie = XiuMai::Auth::_make_auth_cookie('george'),
                                    '_make_auth_kookie: success');
cmp_ok(length $cookie, '==', 32,    '_make_auth_cookie: length of cookie');
is($cookie, XiuMai::Auth::_make_auth_cookie('george'),
                                    '_make_auth_cookie: re-use cookie');
isnt($cookie, XiuMai::Auth::_make_auth_cookie('ringo'),
                                    '_make_auth_cookie: new cookie');
#   _delete_auth_cookie

ok(XiuMai::Auth::_delete_auth_cookie($cookie),
                                    '_delete_auth_cookie: success');
ok(! XiuMai::Auth::_delete_auth_cookie($cookie),
                                    '_delete_auth_cookie: not found');

#   _cleanup_auth_cookie

$cookie = XiuMai::Auth::_make_auth_cookie('cleanup');
my $cookie_file = "$ENV{XIUMAI_HOME}/var/cookie/$cookie";
XiuMai::Auth::_cleanup_auth_cookie;
ok(-f $cookie_file,         '_cleanup_auth_cookie: not found');
my $old_time = 14*60*60*24 + 1;
utime($old_time, $old_time, $cookie_file);
XiuMai::Auth::_cleanup_auth_cookie;
ok(! -f $cookie_file,       '_cleanup_auth_cookie: success');

#   login

ok($cookie = XiuMai::Auth::login('john','lennon'),
                                            'login: success');
ok(! XiuMai::Auth::_login('paul','simon'),  'login: wrong password');
ok(! XiuMai::Auth::_login('pete','best'),   'login: login_name not found');

#   get_login_name

$cookie_file = "$ENV{XIUMAI_HOME}/var/cookie/$cookie";
utime($old_time, $old_time, $cookie_file);

is(XiuMai::Auth::get_login_name($cookie), 'john',
                                            'get_login_name: success');
XiuMai::Auth::_cleanup_auth_cookie;
is(XiuMai::Auth::get_login_name($cookie), 'john',
                                            'get_login_name: not expire');

ok(! XiuMai::Auth::get_login_name('bad_cookie'),
                                            'get_login_name: fail');

#   logout
XiuMai::Auth::logout($cookie);
ok(! XiuMai::Auth::get_login_name($cookie), 'logout: success');


rmtree($ENV{XIUMAI_HOME});

done_testing;

__DATA__
john:.dMF5T11Lw1GU:
paul:wSJiPN54jRGGM:
george:DRoLS/QLD6b/g:
ringo:ZmyzUAHEwYGPo:
