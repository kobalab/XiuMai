package XiuMai::Request;

use strict;
use warnings;
use XiuMai::Util::Request;
use XiuMai::Auth;
use CGI;
use Digest::SHA1 qw(sha1_hex);

use base 'XiuMai::Util::Request';

our $VERSION = "0.06";

sub new {
    my $class = shift;
    my $cgi = new CGI;
    $cgi->charset('utf-8');
    my $self = new XiuMai::Util::Request($cgi);
    return bless $self, $class;
}

sub _qvalue_list {
    my ($str) = @_;
    return ()   if (! defined $str);
    return map { s/;.*$//; $_ } split(/,\s*/, $str);
}

sub accept_language {
    my $self = shift;
    return _qvalue_list($ENV{HTTP_ACCEPT_LANGUAGE});
}

sub login_name {
    my $self = shift;
    return $self->{login_name}  if (exists $self->{login_name});
    $self->{login_name}
        = XiuMai::Auth::get_login_name($self->cookie('XIUMAI_AUTH'));
}

sub session_id {
    my $self = shift;
    return $self->{CGI}->cookie('XIUMAI_AUTH')
            && sha1_hex($self->cookie('XIUMAI_AUTH'));
}

1;
