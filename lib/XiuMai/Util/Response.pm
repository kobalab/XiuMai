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
    $self->{CGI}->header(@_);
}

sub redirect {
    my $self = shift;
    $self->{CGI}->redirect(@_);
}

sub cookie {
    my $self = shift;
    $self->{CGI}->cookie(@_);
}

1;
