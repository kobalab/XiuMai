package XiuMai::SetUp;

use strict;
use warnings;
use version;
use XiuMai;
use IO::File;
use File::Path;

our $VERSION = "0.05";

sub _get_version {
    my ($dir) = @_;
    my $filename = "$dir/VERSION";
    my $fh = new IO::File($filename)    or return 0;
    my $version = <$fh>;
    $fh->close;
    return $version;
}

sub _set_version {
    my ($dir) = @_;
    $dir =~ m|^(.*)$| and $dir = $1;
    my $version = version->parse($XiuMai::VERSION)->numify;
    my $filename = "$dir/VERSION";
    my $fh = new IO::File(">$filename") or return;
    print $fh $version;
    $fh->close;
    return $version;
}

sub _setup_home {
    my ($dir) = @_;
    $dir =~ m|^(.*)$| and $dir = $1;
    mkpath(["$dir/etc", "$dir/var/cookie", "$dir/var/signup"], 0, 0700);
    new IO::File("$dir/etc/passwd", '>>', 0600)     or die "$!\n";
}

sub _setup_data {
    my ($dir) = @_;
    $dir =~ m|^(.*)$| and $dir = $1;
    mkpath("$dir/data", 0, 0700);
}

sub setup {
    if (_get_version(XiuMai::HOME())
            < version->parse($XiuMai::VERSION)->numify)
    {
        _setup_home(XiuMai::HOME());
        _setup_data(XiuMai::HOME());
        _set_version(XiuMai::HOME())    or die 'SetUp $XIUMAI_HOME failed\n';
    }
    if (_get_version(XiuMai::DATA())
            < version->parse($XiuMai::VERSION)->numify)
    {
        _setup_data(XiuMai::DATA());
        _set_version(XiuMai::DATA())    or die 'SetUp $XIUMAI_DATA failed\n';
    }
    return -s XiuMai::HOME().'/etc/passwd';
}

1;
