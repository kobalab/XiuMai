package XiuMai::Util;

use strict;
use warnings;
use Exporter ();

use base 'Exporter';

our $VERSION = "0.06";

our @EXPORT_OK = qw(
    cdata url_encode url_decode
    date_str size_str
    rfc1123_date
    canonpath
    randstr
);

sub cdata {
    my ($str) = @_;
    return ''   if (! defined $str);
    $str =~ s/&/&amp;/g;
    $str =~ s/"/&quot;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str =~ /^(.*)$/s       and $str = $1;
    return $str;
}

sub url_encode {
    my ($url, $rude) = @_;
    if ($rude) {
        $url =~ s/([^\w\-\*\.\~\/\:\?\+\=\&\#])/
                        sprintf("%%%02X", unpack('C', $1))/gex;
    }
    else {
        $url =~ s/([^\w\-\*\.\~\/])/
                        sprintf("%%%02X", unpack('C', $1))/gex;
    }
    return $url;
}

sub url_decode {
    my ($str) = @_;
    $str =~ s/%([\da-fA-F]{2})/pack('H2', $1)/ge;
    return $str;
}

sub date_str {
    my ($time) = @_;

    my $now = time;

    $time = $now    if (! defined $time);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($time);

    if (abs($now - $time) < 60*60*12) {
        return sprintf("%02d:%02d", $hour, $min);
    }
    elsif (abs($now - $time) < 60*60*24*365/2) {
        return sprintf("%d/%d %02d:%02d", $mon+1, $mday, $hour, $min);
    }
    else {
        return sprintf("%d/%02d/%02d", $year+1900, $mon+1, $mday);
    }
}

sub size_str {
    my ($size) = @_;

    return '-'  if (! defined $size);

    my $size_str;
    my @unit = ('%d','%dK','%.1fM','%.1fG','%.1fT');
    while (my $unit = shift @unit) {
        $size_str = sprintf $unit, $size;
        last if ($size < 1024);
        $size = $size / 1024;
    }
    return $size_str;
}

sub rfc1123_date {
    my ($time) = @_;

    $time = time    if (! defined $time);

    my @wday = qw(Sun Mon Tue Wed Thu Fri Sat);
    my @mon  = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($time);

    return sprintf("%s, %02d %s %d %02d:%02d:%02d GMT",
                    $wday[$wday], $mday, $mon[$mon], $year+1900,
                    $hour, $min, $sec);
}

sub canonpath {
    my ($path) = @_;
    return      if (! defined $path);
    return ''   if ($path !~ m|^/|);
    my @path;
    foreach ($path =~ m|([^/]*/?)|g) {
        next if (m|^\.?/?$|);
        if   (m|^\.\./?$|)  { pop(@path);       }
        else                { push(@path, $_);  }
    }
    return '/' . join('', @path);
}

sub randstr {
    my ($len, $base_str) = @_;

    $len = 8    if (! defined $len);
    $base_str = '0123456789'
              . 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'    if (! $base_str);
    my $str = '';
    for (1..$len) {
        $str .= substr($base_str, int(rand() * (length $base_str)), 1);
    }
    return $str;
}

1;
