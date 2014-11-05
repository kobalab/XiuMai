package XiuMai;

use 5.008001;
use strict;
use warnings;
use XiuMai::Request;
use XiuMai::Response;
use XiuMai::Resource;
use XiuMai::SetUp;

our $VERSION = "0.06";

our $PRODUCT_NAME = "XiuMai/$VERSION";
our $PRODUCT_URL  = 'http://kobalab.net/xiumai/';

sub HOME { $ENV{XIUMAI_HOME} or die '$XIUMAI_HOME not set.'."\n"; }
sub DATA { $ENV{XIUMAI_DATA} || HOME; }

sub new {
    my $class = shift;
    my $self = {};
    $self->{Request}  = new XiuMai::Request;
    $self->{Response} = new XiuMai::Response($self->{Request});
    return bless $self, $class;
}

sub _req {   $_[0]->{Request}   }
sub _res {   $_[0]->{Response}  }

sub handler {
    my $self = new XiuMai;
    eval {
        my $method = $self->_req->method;
        $method eq 'HEAD'   and return $self->_do_get;
        $method eq 'GET'    and return $self->_do_get;
        $method eq 'POST'   and return $self->_do_post;
        return $self->_res->print_error(405);
    };
    if ($@ && $@ !~ /^ModPerl::Util::exit:/) {
        $self->_res->print_error(500, $@);
    }
}

sub _do_get {
    my $self = shift;

    XiuMai::SetUp::setup()  or return $self->_res->print_signup_form;

    if (my $cmd = $self->_req->param('cmd')) {
        $cmd eq 'signup'    and return $self->_res->print_signup_form;
        $cmd eq 'login'     and return $self->_res->print_login_form;
        $cmd eq 'logout'    and return $self->_res->logout;
    }

    my $r = new XiuMai::Resource($self->_req)
                     or return $self->_res->print_error(404);
    $r->redirect    and return $self->_res->print_redirect($r->redirect);
    $r->open         or return $self->_res->print_error(403);
    $r->convert      or return $self->_res->print_error(406);
    $self->_res->print($r);
}

sub _do_post {
    my $self = shift;

    my $session_id = $self->_req->param('session_id');
    my $cookie     = $self->_req->session_id;
    if (defined $cookie && $session_id ne $cookie) {
        return $self->_res->print_error(400);
    }

    if (my $cmd = $self->_req->param('cmd')) {
        $cmd eq 'signup'    and return $self->_res->signup;
        $cmd eq 'login'     and return $self->_res->login;
    }

    my $r = new XiuMai::Resource($self->_req)
                     or return $self->_res->print_error(404);
    $r->update       or return $self->_res->print_error(403);
    $r->redirect    and return $self->_res->print_redirect($r->redirect);
    $self->_res->print_error(406);
}

1;
__END__

=encoding utf-8

=head1 NAME

XiuMai - Website construction tool

=head1 SYNOPSIS

If you use XiuMai as CGI:

    use XiuMai;
    $ENV{XIUMAI_HOME} = '/path/of/datafiles';
    XiuMai::handler;

or mod_perl2:

    <IfModule perl_module>
        <Location /xiumai>
            SetHandler      perl-script
            PerlHandler     XiuMai
            PerlSetEnv      XIUMAI_HOME /path/of/datafiles
        </Location>
    </IfModule>

=head1 DESCRIPTION

XiuMai is website construction tool. It works on perl 5.8.1 or later.

But now, I'm trying refactoring. This release (on github) B<doesn't work yet!>

=head1 ENVIRONMENT VARIABLES

=head2 XIUMAI_HOME

Directory of authentication and contents repository.

=head2 XIUMAI_DATA

If you want to run 2 or more XiuMai, and must share authentication,
set authentication repository to XIUMAI_HOME, and set contents repository to
XIUMAI_DATA.

=head1 LICENSE

Copyright (C) Satoshi Kobayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://www.yk.rim.or.jp/~koba/xiumai/>

=head1 AUTHOR

Satoshi Kobayashi E<lt>koba@yk.rim.or.jpE<gt>

=cut

