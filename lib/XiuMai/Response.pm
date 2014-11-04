package XiuMai::Response;

use strict;
use warnings;
use XiuMai::Util::Response;
use XiuMai::HTML;
use XiuMai::Auth;
use XiuMai::Util qw(cdata url_decode canonpath rfc1123_date);

use base 'XiuMai::Util::Response';

our $VERSION = "0.06";

our %STATUS_LINE = (

    301 => 'Moved Permanently',
    303 => 'See Other',

    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',

    500 => 'Internal Server Error',
);

sub _exit { $XiuMai::NOT_EXIT or exit @_ }

sub _header {
    my $self = shift;
    my %param = @_;

    $param{-cookie} = [ $self->_auth_cookie ];

    $self->header(%param);
}

sub _redirect {
    my $self = shift;
    my %param = @_;

    $param{-cookie} = [ $self->_auth_cookie ];

    $self->redirect(%param);
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
    my ($status, $message) = @_;

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
          $status == 406 ? $html->msg('error.406.message', $url) :
          $status == 500 ? $html->msg('error.500.message') :
          '';
    $error_message = qq(<p class="x-error">).cdata($error_message).qq(</p>\n);
    if (defined $message) {
        $error_message
            .= qq(<p class="x-error">)
             . join(qq(<br />), map { cdata($_) } split(/\n/, $message))
             . qq(</p>\n);
    }

    my $content
        = $html->title("$status $status_line")
               ->as_string(
                     qq(<h1>).cdata($status_line).qq(</h1>\n),
                     $error_message,
                 );

    print $self->_header(
                     -status         => "$status $status_line",
                     -content_length => length($content),
                 );
    print $content              if ($self->_req->method ne 'HEAD');
    _exit;
}

sub print_login_form {
    my $self = shift;

    my $html = new XiuMai::HTML($self->_req);

    my $title = cdata($html->msg('login_form.title'));
    my $url   = cdata($self->_req->url);

    my $content
        = $html->title($title)
               ->as_string(
                     qq(<h1><a href="$url">).cdata($title).qq(</a></h1>\n),
                     $html->login_form,
                 );

    print $self->_header;
    print $content              if ($self->_req->method ne 'HEAD');
    _exit;
}

sub login {
    my $self = shift;

    my $login_name = $self->_req->param('login_name');
    my $passwd     = $self->_req->param('passwd');
    my $cookie = XiuMai::Auth::login($login_name, $passwd)
                                                or $self->print_error(401);
    my $path = $self->_req->base_url;

    $self->{auth_cookie}
        = $self->{CGI}->cookie(
                -name    => 'XIUMAI_AUTH',
                -value   => $cookie,
                -path    => $path,
                -expires => qq(+${XiuMai::Auth::EXPDATE}d),
          );

    $self->print_redirect(303, $self->_req->url);
}

sub logout {
    my $self = shift;
    if (defined $self->_req->session_id
        && defined $self->_req->param('session_id')
        && $self->_req->session_id eq $self->_req->param('session_id'))
    {
        XiuMai::Auth::logout($self->{CGI}->cookie('XIUMAI_AUTH'));
    }
    $self->print_redirect(303, $self->_req->url);
}

sub _auth_cookie {
    my $self = shift;
    return $self->{auth_cookie}     if (defined $self->{auth_cookie});

    my $cookie  = $self->{CGI}->cookie('XIUMAI_AUTH')   or return;
    my $path    = $self->_req->base_url;
    my $expdate = defined $self->_req->login_name
                        ? qq(+${XiuMai::Auth::EXPDATE}d) : '-1d';
    return $self->{CGI}->cookie(
                -name    => 'XIUMAI_AUTH',
                -value   => $cookie,
                -path    => $path,
                -expires => $expdate,
           );
}

sub print_signup_form {
    my $self = shift;

    XiuMai::Auth::is_admin($self->_req->login_name)
        or $self->print_error(403);

    my $html = new XiuMai::HTML($self->_req);

    my $title = cdata($html->msg('signup_form.title'));
    my $url   = cdata($self->_req->url);

    my $content
        = $html->title($title)
               ->as_string(
                     qq(<h1><a href="$url">).cdata($title).qq(</a></h1>\n),
                     $html->signup_form(@_),
                 );

    print $self->_header;
    print $content              if ($self->_req->method ne 'HEAD');
    _exit;
}

sub signup {
    my $self = shift;

    XiuMai::Auth::is_admin($self->_req->login_name)
        or $self->print_error(403);

    my $login_name = $self->_req->param('login_name');
    my $passwd     = $self->_req->param('passwd');

    my @error;
    if (! defined $login_name || ! length $login_name) {
        push(@error, ['no_login_name']);
    }
    elsif ($login_name !~ /^[a-zA-Z][\w\-\.]*$/) {
        push(@error, ['bad_login_name', $login_name]);
    }
    if (! defined $passwd || ! length $passwd) {
        push(@error, ['no_passwd']);
    }

    XiuMai::Auth::signup($login_name, $passwd)
        or push(@error, ['already_taken', $login_name])     if (! @error);

    $self->print_signup_form(@error)                        if (@error);

    if ($self->_req->login_name) {
        $self->print_redirect(303, $self->_req->url);
    }
    else {
        $self->login($login_name, $passwd);
    }
}

1;
