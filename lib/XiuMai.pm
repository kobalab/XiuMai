package XiuMai;

use 5.008001;
use strict;
use warnings;
use XiuMai::Request;
use XiuMai::Response;

our $VERSION = "0.02";

our $PRODUCT_NAME = "XiuMai/$VERSION";
our $PRODUCT_URL  = 'http://www.yk.rim.or.jp/~koba/xiumai/';

sub HOME {
    defined $ENV{XIUMAI_HOME}   or die '$XIUMAI_HOME not set.';
    return $ENV{XIUMAI_HOME};
}
sub DATA {
    return defined $ENV{XIUMAI_DATA} ? $ENV{XIUMAI_DATA} : HOME;
}

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
    $self->_do_get      if ($self->_req->method eq 'HEAD');
    $self->_do_get      if ($self->_req->method eq 'GET');
    $self->_do_post     if ($self->_req->method eq 'POST');
    $self->_res->print_error(405);
    exit;
}

sub _do_get {
    my $self = shift;

    # use for DEMO
    use XiuMai::HTML;
    use XiuMai::Util qw(cdata);

    my $status = $self->_req->param('status');
    if (defined $status && $status =~ /^400|401|403|404|405$/) {
        $self->_res->print_error($status);
        exit;
    }

    my $html = new XiuMai::HTML($self->_req);
    my $content = $html->title('Welcome to XiuMai!')
                       ->lang($html->accept_language)
                       ->as_string(
                            qq(<h1>).cdata($html->msg('greeting')).qq(</h1>));
    $self->_res->print($content);

    exit;
}

sub _do_post {
    my $self = shift;
    $self->_res->print_redirect(303, $self->_req->url);

    exit;
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

