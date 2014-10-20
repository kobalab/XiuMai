package XiuMai::Util::MimeType;

use strict;
use warnings;
use XiuMai;
use IO::File;

our $VERSION = $XiuMai::VERSION;

my %default;

sub new {
    my $class = shift;
    my @mime_file = @_;

    my $self = {};
    bless $self, $class;

    if (! keys %default) {
        $self->_read(\*DATA);
        %default = %$self;
    }
    else {
        %$self = %default;
    }

    for my $mime_file (@mime_file) {
        $self->_read($mime_file);
    }
    return $self;
}

sub _read {
    my $self = shift;
    my $file = shift                            or return;

    my $fh = new IO::File($file)
          || IO::File->new_from_fd($file, 'r')  or return;
    while (<$fh>) {
        chomp;
        next if (/^#/);
        my ($type, @ext) = split;
        for my $ext (@ext) {
            $self->{lc $ext} = $type;
        }
    }
    close($fh);
    return $self;
}

sub type {
    my $self = shift;
    my ($filename) = @_;

    my ($ext) = $filename =~ /\.([^\.]*)$/;
    ! defined $ext          and return 'text/x-xiumai';
    return $self->{lc $ext} || 'application/octet-stream';
}

1;

__DATA__
#
#   mime.type
#
text/plain          txt text
text/html           htm html
text/css            css
#
image/png           png
image/gif           gif
image/jpeg          jpg jpeg
image/tiff          tif tiff
image/bmp           bmp
image/x-icon        ico
#
application/pdf                 pdf
