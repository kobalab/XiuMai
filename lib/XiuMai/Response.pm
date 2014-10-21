package XiuMai::Response;

use strict;
use warnings;
use XiuMai;
use XiuMai::HTML;
use XiuMai::Util qw(cdata url_decode canonpath rfc1123_date);

our $VERSION = $XiuMai::VERSION;

our %STATUS_LINE = (

    301 => 'Moved Permanently',
    303 => 'See Other',

    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
);

sub new {
    my $class = shift;
    my ($req) = @_;
    return bless {
        Request => $req,
        CGI     => $req->{CGI},
    }, $class;
}

sub _exit { $XiuMai::NOT_EXIT or exit @_ }

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
    my ($r) = @_;

    my %param;
    $param{-type}           = $r->type  if (defined $r->type);
    $param{-charset}        = $r->charset;
    $param{-content_length} = $r->size  if (defined $r->size);
    $param{-last_modified}  = rfc1123_date($r->mtime)
                                        if (defined $r->mtime);

    print $self->_header(%param);
    $r->print               if ($self->_req->method eq 'GET');
    _exit;
}

sub print_redirect {
    my $self = shift;
    my ($status, $uri) = @_;

    my $status_line = $STATUS_LINE{$status} || '';
    my ($path, $query, $fragment) = $uri =~ /^(.*?)(\?.*?)?(#.*)?$/;
    if ($path eq '') {
        $path = $self->_req->url;
    }
    elsif ($path !~ m|^/|) {
        $self->_req->url =~ m|^(.*/)|;
        $path = $1 . $path;
    }

    $uri = $self->_req->scheme . '://'
         . $self->_req->host
         . canonpath($path)
         . (defined $query    ? $query    : '')
         . (defined $fragment ? $fragment : '');

    print $self->_redirect(
            -status => "$status $status_line",
            -uri    => $uri
    );
    _exit;
}

sub print_error {
    my $self = shift;
    my ($status) = @_;

    my $status_line = $STATUS_LINE{$status} || '';

    my $method = $self->_req->method;
    my $url    = url_decode($self->_req->url);

    my $html = new XiuMai::HTML($self->_req);
    my $error_message
        = $status == 400 ? $html->msg('error.400.message') :
          $status == 401 ? $html->msg('error.401.message') :
          $status == 403 ? $html->msg('error.403.message', $url) :
          $status == 404 ? $html->msg('error.404.message', $url) :
          $status == 405 ? $html->msg('error.405.message', $method, $url) :
          '';

    my $content
        = $html->title("$status $status_line")
               ->lang($html->accept_language)
               ->as_string(
                     qq(<h1>).cdata($status_line).qq(</h1>),
                     qq(<p class="x-error">).cdata($error_message).qq(</p>)
                 );

    print $self->_header(
                     -status         => "$status $status_line",
                     -content_length => length($content),
                 );
    print $content              if ($self->_req->method ne 'HEAD');
    _exit;
}

1;
