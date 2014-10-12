package XiuMai;

use 5.008001;
use strict;
use warnings;
use XiuMai::Request;

our $VERSION = "0.01";

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
    my $self->{Request} = new XiuMai::Request;
    return bless $self, $class;
}

sub _req {   $_[0]->{Request}   }
sub _res {   $_[0]->{Response}  }

sub handler {
    my $self = new XiuMai;
    $self->_do_get      if ($self->_req->method eq 'HEAD');
    $self->_do_get      if ($self->_req->method eq 'GET');
    $self->_do_post     if ($self->_req->method eq 'POST');
    $self->_do_post;    #### TODO: fix it. ####
}

sub _do_get {
    my $self = shift;
    my $cgi = $self->_req->{CGI};
    print $cgi->header;
    print '<html><h1>It works!</h1></html>' if ($self->_req->method eq 'GET');
    exit;
}

sub _do_post {
    my $self = shift;
    my $cgi = $self->_req->{CGI};
    print $cgi->redirect($self->_req->url);
    exit;
}

1;
__END__

=encoding utf-8

=head1 NAME

XiuMai - Web site construction tool

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

XiuMai is web site construction tool. It works on perl 5.8.1 or later.

But now, I'm trying refactoring. This release (on github) B<does't work yet!>

=head1 LICENSE

Copyright (C) Satoshi Kobayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://www.yk.rim.or.jp/~koba/xiumai/>

=head1 AUTHOR

Satoshi Kobayashi E<lt>koba@yk.rim.or.jpE<gt>

=cut

