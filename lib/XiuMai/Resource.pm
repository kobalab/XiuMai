package XiuMai::Resource;

use strict;
use warnings;
use XiuMai;
use XiuMai::Resource::Folder;
use XiuMai::HTML::Resource;
use XiuMai::Util::MimeType;
use XiuMai::Util qw(cdata canonpath);
use IO::File;

our $VERSION = "0.04";

sub new {
    my $class = shift;
    my ($req, $path_name) = @_;

    my $base_dir  = XiuMai::DATA() . '/data';
    my $base_url  = $req->base_url;
    my $path_info = $req->path_info;
    my $full_name = canonpath($base_dir.$path_info);

    if (defined $path_name) {
        if ($path_name =~ m|^/|) { $full_name = $base_dir;     }
        else                     { $full_name =~ s|/[^/]+$|/|; }
        $full_name .= $path_name;
        $full_name = canonpath($full_name);
        $full_name =~ m|^$base_dir/|    or return;
    }
    my ($dirname, $filename) = $full_name =~ m|^(.*/)([^/]+)|;

    my $self = {
        Request     => $req,
        filename    => $filename,
        full_name   => $full_name,
        base_url    => $base_url,
        path_info   => $path_info,
        base_dir    => $base_dir,
        type        => undef,
        size        => undef,
        mtime       => undef,
        charset     => '',
        fh          => undef,
        redirect    => [],
    };

    -d $full_name       and return new XiuMai::Resource::Folder($self);

    -f $full_name        or return;

    $self->{size}  = -s $full_name;
    $self->{mtime} = (stat($full_name))[9];

    my $type  = XiuMai::Util::MimeType->new()->type($filename);
    $self->{type} = $type;

    return bless $self, $class;
}

sub req       { $_[0]->{Request}   }
sub filename  { $_[0]->{filename}  }
sub base_url  { $_[0]->{base_url}  }
sub path_info { $_[0]->{path_info} }
sub type      { $_[0]->{type}      }
sub size      { $_[0]->{size}      }
sub mtime     { $_[0]->{mtime}     }
sub charset   { $_[0]->{charset}   }

sub _cmd { $_[0]->req->param('cmd') || '' }

sub redirect {
    my $self = shift;
    $self->{redirect} = [ @_ ] and return $self     if (@_);
    return @{$self->{redirect}};
}

sub open {
    my $self = shift;
    $self->{fh} = new IO::File($self->{full_name}, 'r') or return;
    return $self;
}

sub convert {
    my $self = shift;
    return $self->_edit     if ($self->_cmd eq 'edit');
    return $self->_convert;
}

sub print {
    my $self = shift;

    if (defined $self->{html}) {
        print $self->{html};
        return;
    }

    my $buf;
    while ($self->{fh}->read($buf, 1024*1024*10)) {
        print $buf;
    }
    $self->{fh}->close;
    return;
}

sub update {
    my $self = shift;

    $self->redirect(303, './?cmd=edit');

    my $file = $self->req->param('file');
    if (! defined $file || ! length $file) {
        unlink($self->{full_name})  or return;
        return $self;
    }
    my $buf;
    my $fh = new IO::File($self->{full_name}, 'w')  or return;
    while (read($file, $buf, 1024*1024)) {
        print $fh $buf;
    }
    $fh->close;
    return $self;
}

sub _convert { shift }

sub _edit    {
    my $self = shift;

    my $filename = cdata($self->filename);
    my $query    = $self->req->query;

    my $html = new XiuMai::HTML::Resource($self);
    $self->{html}
        = $html->title($filename)
               ->as_string(
                    qq(<h1><a href="$filename">$filename</a></h1>\n),
                    $html->path_info($query),
                    $html->upload_form,
                );

    $self->{charset} = $html->charset;
    $self->{type}    = 'text/html';
    $self->{size}    = length $self->{html};
    undef $self->{mtime};

    return $self;
}

1;
