package XiuMai::Request;

use strict;
use warnings;
use XiuMai::Auth;
use XiuMai::Util qw(url_encode);
use CGI;

our $VERSION = "0.04";

sub new {
    my $class = shift;
    my $cgi = new CGI;
    $cgi->charset('utf-8');
    return bless { CGI => $cgi }, $class;
}

sub _qvalue_list {
    my ($str) = @_;
    return ()   if (! defined $str);
    return map { s/;.*$//; $_ } split(/,\s*/, $str);
}

sub method {
    my $self = shift;
    return $ENV{REQUEST_METHOD};
}

sub scheme {
    my $self = shift;
    return $ENV{HTTPS} && $ENV{HTTPS} ne 'OFF' ? 'https' : 'http';
}

sub host {
    my $self = shift;
    return $ENV{HTTP_HOST}
        || ($ENV{SERVER_PORT} == 80
                ? $ENV{SERVER_NAME}
                : "$ENV{SERVER_NAME}:$ENV{SERVER_PORT}");
}

sub url {
    my $self = shift;
    my $url = $ENV{REQUEST_URI};
    $url =~ s/\?.*//;
    return $url;
}

sub query {
    my $self = shift;
    return $ENV{QUERY_STRING};
}

sub path_info {
    my $self = shift;
    return $ENV{PATH_INFO} || '';
}

sub base_url {
    my $self = shift;
    return url_encode($ENV{SCRIPT_NAME}, 'rude');
}

sub param {
    my $self = shift;
    return $self->{CGI}->param(@_);
}

sub accept_language {
    my $self = shift;
    return _qvalue_list($ENV{HTTP_ACCEPT_LANGUAGE});
}

sub charset {
    my $self = shift;
    return $self->{CGI}->charset
}

sub login_name {
    my $self = shift;
    return $self->{login_name}  if (exists $self->{login_name});
    $self->{login_name}
        = XiuMai::Auth::get_login_name($self->{CGI}->cookie('XIUMAI_AUTH'));
}

sub session_id {
    my $self = shift;
    return $self->{CGI}->cookie('XIUMAI_AUTH');
}

1;
