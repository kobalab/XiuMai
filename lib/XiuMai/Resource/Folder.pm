package XiuMai::Resource::Folder;

use strict;
use warnings;
use XiuMai;
use XiuMai::Resource;
use XiuMai::HTML::Folder;
use XiuMai::Util qw(cdata);
use IO::Dir;

use base 'XiuMai::Resource';

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my $self  = shift;

    bless $self, $class;

    if ($self->req->url !~ m|/$|) {
        $self->redirect(301, $self->req->url . '/');
    }
    else {
        $self->{mtime} = (stat($self->{full_name}))[9];
        $self->{filename} .= '/';
    }

    return $self;
}

sub file { @{$_[0]->{file}} }

sub open {
    my $self = shift;

    my @file;
    my $dir = new IO::Dir($self->{full_name})    or return;
    while ($_ = $dir->read) {
        next    if (/^\.\.?$/);
        push(@file, new XiuMai::Resource($self->req, $_));
    }
    $dir->close;
    $self->{file} = \@file;

    return $self;
}

sub convert {
    my $self = shift;

    my $path_info = cdata($self->{path_info});

    my $html = new XiuMai::HTML::Folder($self);
    $self->{html} = $html->as_string(
                        qq(<h1>Folder:$path_info</h1>),
                        $html->path_info,
                        $html->file_list,
                    );
    $self->{charset} = $html->charset;
    $self->{type}    = 'text/html';
    $self->{size}    = length $self->{html};
    undef $self->{mtime};

    return $self;
}

sub print {
    my $self = shift;
    print $self->{html};
    return;
}

1;
