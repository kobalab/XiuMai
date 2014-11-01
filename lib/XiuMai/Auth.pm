package XiuMai::Auth;

use strict;
use warnings;
use XiuMai;
use XiuMai::Util qw(randstr);
use IO::File;
use IO::Dir;

our $VERSION = "0.04";

our $EXPDATE = 14;

sub _cookie_dir {
    my $cookie_dir = XiuMai::HOME().'/var/cookie';
    $cookie_dir =~ /^(\/.*)$/ and $cookie_dir = $1;
    return $cookie_dir;
}

sub _login {
    my ($login_name, $passwd) = @_;

    my $passwd_file = XiuMai::HOME().'/etc/passwd';
    my $fh = new IO::File($passwd_file)     or die "$passwd_file: $!\n";
    while (<$fh>) {
        chomp;
        my ($login, $crypt) = split(/:/);
        next if ($login ne $login_name);
        return crypt($passwd, $crypt) eq $crypt;
    }
    return;
}

sub _make_auth_cookie {
    my ($login_name) = @_;

    my $cookie_dir = _cookie_dir;
    my $dh = new IO::Dir($cookie_dir)       or die "$cookie_dir: $!\n";
    while (my $cookie = $dh->read) {
        next if ($cookie =~ /^\./);
        my $cookie_file = "$cookie_dir/$cookie";
        my $fh = new IO::File($cookie_file) or die "$cookie_file: $!\n";
        my $login = <$fh>;
        $fh->close;
        return $cookie  if ($login eq $login_name);
    }
    $dh->close;

    my $cookie;
    for (;;) {
        $cookie = randstr(32);
        last if (! -f "$cookie_dir/$cookie");
    }
    my $cookie_file = "$cookie_dir/$cookie";
    my $fh = new IO::File(">$cookie_file")  or die "$cookie_file: $!\n";
    print $fh $login_name;
    $fh->close;
    return $cookie;
}

sub _delete_auth_cookie {
    my ($cookie) = @_;
    $cookie =~ /^(\w+)$/ and $cookie = $1 or return;
    unlink(_cookie_dir."/$cookie");
}

sub _cleanup_auth_cookie {
    my $cookie_dir = _cookie_dir;
    my $dh = new IO::Dir($cookie_dir)   or die "$cookie_dir: $!\n";
    while (my $cookie = $dh->read) {
        next if ($cookie =~ /^\./);
        $cookie =~ /^(.*)$/ and $cookie = $1;
        my $cookie_file = "$cookie_dir/$cookie";
        next if (time < (stat($cookie_file))[9] + $EXPDATE*60*60*24);
        unlink($cookie_file)    or die "$cookie_file: $!\n";
    }
}

sub login {
    my ($login_name, $passwd) = @_;
    _cleanup_auth_cookie;
    _login($login_name, $passwd)    or return;
    return _make_auth_cookie($login_name);
}

sub get_login_name {
    my ($cookie) = @_   or return;

    $cookie =~ /^(\w+)$/ and $cookie = $1 or return;
    my $cookie_file = _cookie_dir."/$cookie";
    my $fh = new IO::File($cookie_file)  or return;
    my $login_name = <$fh>;
    $fh->close;

    $login_name =~ /^(.*)$/ and $login_name = $1;

    my $now = time;
    utime($now, $now, $cookie_file)     or die "$cookie_file: $!\n";

    return $login_name;
}

sub logout {
    _delete_auth_cookie(@_) || 1;
}

1;
