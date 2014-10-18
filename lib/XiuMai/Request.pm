package XiuMai::Request;

use strict;
use warnings;
use XiuMai;
use CGI;

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my $cgi = new CGI;
    $cgi->charset('utf-8');
    return bless { CGI => $cgi }, $class;
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
    return $ENV{SCRIPT_NAME};
}

sub param {
    my $self = shift;
    return $self->{CGI}->param(@_);
}

1;
