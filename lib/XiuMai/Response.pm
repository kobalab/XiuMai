package XiuMai::Response;

use strict;
use warnings;
use XiuMai;

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my ($req) = @_;
    return bless {
        Request => $req,
        CGI     => $req->{CGI},
    }, $class;
}

sub _req {  $_[0]->{Request}    }
sub _cgi {  $_[0]->{CGI}        }

sub _header {
    my $self = shift;
    my %param = @_ == 1 ? ( -type => shift @_ ) : @_;

    $self->_cgi->header(%param);
}

sub _redirect {
    my $self = shift;
    my %param = @_ == 1 ? ( -uri => shift @_ ) : @_;

    $self->_cgi->redirect(%param);
}

sub print {
    my $self = shift;
    my ($content) = @_;

    print $self->_header;
    print $content          if ($self->_req->method eq 'GET');
    exit;
}

sub print_redirect {
    my $self = shift;
    my ($status, $uri) = @_;

    print $self->_redirect(
            -status => $status,
            -uri    => $uri
    );
    exit;
}

sub print_error {
    my $self = shift;
    my ($status) = @_;

    print $self->_header(-status => $status);
    exit;
}

1;
