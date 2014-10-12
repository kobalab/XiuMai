package XiuMai;
use 5.008001;
use strict;
use warnings;

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

sub handler :method {
    use CGI;
    my $cgi = new CGI;

    print $cgi->header, '<html><h1>It works!</h1></html>';
    return;
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

