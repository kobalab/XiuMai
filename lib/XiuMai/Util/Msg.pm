package XiuMai::Util::Msg;

use strict;
use warnings;
use XiuMai;
use IO::File;

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my ($msg_file) = @_;
    my $self = {};

    return if (! defined $msg_file);

    my $last_key;
    my $fh = new IO::File($msg_file)    or return;
    while (<$fh>) {
        chomp;
        next if (/^#/);
        s/^\t// and $self->{$last_key} .= "\n$_", next;
        my ($key, $value) = split(/:/, $_, 2);
        $self->{$key} = $value;
        $last_key = $key;
    }
    close($fh);

    return bless $self, $class;
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my $msg = $self->{$key} or return $key;
    $msg =~ s/{\$(\d+)}/$_[$1]/g;
    return $msg;
}

1;
