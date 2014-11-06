package t::IT;

use strict;
use Test::More 0.98;
use Exporter ();
use HTTP::Request::Common 5.814 qw(HEAD GET POST PUT DELETE);
use HTTP::Request::AsCGI;
use HTTP::Date;
use XiuMai;

use base 'Exporter';

our @EXPORT = qw( do_test );

BEGIN {
    $ENV{XIUMAI_HOME} = $ENV{PWD}.'/t/.xiumai';
}

my $cookie;
my $session_id;

sub _url_encode {
    local $_ = shift;
    s/([^\w\-\*\.\~])/sprintf('%%%02X', unpack('C', $1))/ge;
    $_;
}

sub _request {
    my $method = shift;
    my $url    = shift;
    my ($param, @header);
    while (my $key = shift) {
        $param = $key and next    if (ref $key eq 'ARRAY');
        push(@header, $key, shift);
    }

    push(@header, cookie => $cookie);
    for (my $i = 0; ref $param eq 'ARRAY' && $i < @$param; $i += 2) {
        $param->[$i] eq 'session_id' && ! defined $param->[$i+1]
            and $param->[$i+1] = $session_id;
    }

    if ($method eq 'POST') {
        return (grep { ref $_ eq 'ARRAY' } @$param)
            ? POST $url, Content_Type => 'form-data',
                         Content      => $param,
                         @header
            : POST $url, $param, @header;
    }
    else {
        my $query;
        while (my $key = _url_encode(shift @$param)) {
            my $value = _url_encode(shift @$param);
            $query .= $query ? "&$key=$value" : "?$key=$value";
        }
        return $method eq 'HEAD'   ? HEAD   "$url$query", @header :
               $method eq 'GET'    ? GET    "$url$query", @header :
               $method eq 'PUT'    ? PUT    "$url$query", @header :
               $method eq 'DELETE' ? DELETE "$url$query", @header :
                                     undef;
    }
}

sub _cookie {
    my ($header) = @_;
    my ($cookie)  = $header =~ m|\b(XIUMAI_AUTH=\w*)|;
    my ($expires) = $header =~ m|\bexpires=([^;]*)|;
    return if (str2time($expires) < time);
    return $cookie;
}

sub _session_id {
    my ($html) = @_;
    my ($session_id)
        = $html =~ m|<input name="session_id" value="(.*?)" type="hidden" />|
            || $html =~ m|\bsession_id=(\w*)|;
    return $session_id;
}

sub do_test {
    my %case = @_;

    my $c = HTTP::Request::AsCGI->new(_request(@{$case{req}}))->setup;
    $ENV{HTTP_HOST} =~ s/:80$//;

    XiuMai::handler;

    my $r = $c->restore->response;

    $cookie     = _cookie($r->header('set-cookie'));
    $session_id = _session_id($r->content);

    cmp_ok($r->code, '==', $case{res}{code} || 200,
                                "$case{name}: check status code");

    cmp_ok($r->header('content-length'), '==', length $r->content,
                                "$case{name}: check header Content-Length")
                        if ($case{res}{code} !~ /^3/);

    is($r->header('content-type'),
       $case{res}{type} || 'text/html; charset=utf-8',
                                "$case{name}: check header Content-Type")
                        if ($case{res}{code} !~ /^3/);

    while (my ($key, $value) = each %{$case{res}{header}}) {
        $key =~ s/_/-/g; $key =~ s/\b(\w)/uc($1)/ge;
        if (ref $value eq 'Regexp') {
            like($r->header($key), $value, "$case{name}: check header $key");
        }
        elsif (defined $value) {
            is($r->header($key), $value, "$case{name}: check header $key");
        }
        else {
            ok(! $r->header($key), "$case{name}: check header $key")
                or diag($r->header($key));
        }
    }

    for my $content (@{$case{res}{content}}) {
        if (ref $content eq 'Regexp') {
            like($r->content, $content,
                                "$case{name}: check content like $content");
        }
        else {
            is($r->content, $content,
                                "$case{name}: check content is $content");
        }
    }
}

1;
