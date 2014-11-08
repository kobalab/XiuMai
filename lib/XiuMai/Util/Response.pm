package XiuMai::Util::Response;

use strict;
use warnings;

our $VERSION = "0.06";

sub new {
    my $class = shift;
    my ($req) = @_;
    return bless {
        Request => $req,
        CGI     => $req->{CGI},
    }, $class;
}

sub _req {  $_[0]->{Request}    }

sub header {
    my $self = shift;

    my %param;
    while (my $key = shift) {
        $param{ lc $key } = shift;
    }

    if (! exists $param{-content_type}) {
        $param{-content_type} = $param{-type} || 'text/html';
        if (exists $param{-charset}) {
            $param{-content_type} .= "; charset=$param{-charset}";
        }
        elsif ($param{-content_type} =~ /^text\//) {
            $param{-content_type} .= "; charset=ISO-8859-1";
        }
    }
    delete $param{-type};
    delete $param{-charset};

    if (exists $param{-cookie}) {
        $param{-set_cookie}
            = join(';', map { $_->as_string } @{$param{-cookie}});
        delete $param{-cookie};
    }

    my $header = '';
    if (exists $param{-status}) {
        $header .= "Status: $param{-status}\n";
        delete $param{-status};
    }
    while (my ($key, $value) = each %param) {
        $key =~ s/^\-//;
        $key =~ s/_/\-/g;
        $key =~ s/\b(\w)/uc($1)/ge;
        $header .= "$key: $value\n";
    }

    return "$header\n";
}

sub cookie {
    my $self = shift;
    $self->{CGI}->cookie(@_);
}

1;
