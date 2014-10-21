package XiuMai::Resource;

use strict;
use warnings;
use XiuMai;
use XiuMai::Util::MimeType;

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my ($req, $filename) = @_;

    my $base_dir  = XiuMai::DATA() . '/data';
    my $base_url  = $req->base_url;
    my $path_info = $req->path_info;
    my $full_name = $base_dir . $path_info;

    ! -f $full_name     and return;
    -d $full_name       and return;

    my $type  = XiuMai::Util::MimeType->new()->type($full_name);
    my $size  = -s $full_name;
    my $mtime = (stat($full_name))[9];

    return bless {
        Request     => $req,
        full_name   => $full_name,
        base_url    => $base_url,
        path_info   => $path_info,
        base_dir    => $base_dir,
        type        => $type,
        size        => $size,
        mtime       => $mtime,
        fh          => undef,
    }, $class;
}

sub _req  { $_[0]->{Request}  }
sub type  { $_[0]->{type}     }
sub size  { $_[0]->{size}     }
sub mtime { $_[0]->{mtime}    }

sub open {
    my $self = shift;
    $self->{fh} = new IO::File($self->{full_name}, 'r') or return;
    return $self;
}

sub print {
    my $self = shift;

    my $buf;
    while ($self->{fh}->read($buf, 1024*1024*10)) {
        print $buf;
    }
}

1;
