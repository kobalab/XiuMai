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

sub _convert {
    my $self = shift;

    my $title = cdata("Folder:$self->{path_info}");

    my $html = new XiuMai::HTML::Folder($self);
    $self->{html}
        = $html->title($title)
               ->as_string(
                     qq(<h1>$title</h1>\n),
                     $html->path_info,
                     $html->file_list,
                 );
    $self->{charset} = $html->charset;
    $self->{type}    = 'text/html';
    $self->{size}    = length $self->{html};
    undef $self->{mtime};

    return $self;
}

sub _edit {
    my $self = shift;

    my $title = cdata("Folder:$self->{path_info}");
    my $query = $self->req->query;

    my $html = new XiuMai::HTML::Folder($self);

    my $rmdir_form = (! $self->file && $self->{path_info} ne '/')
                        ? $html->rmdir_form : '';

    $self->{html}
        = $html->title($title)
               ->as_string(
                     qq(<h1><a href="./">$title</a></h1>\n),
                     $html->path_info($query),
                     $html->mkfile_form,
                     $html->mkdir_form,
                     $rmdir_form,
                     $html->file_list($query),
                 );
    $self->{charset} = $html->charset;
    $self->{type}    = 'text/html';
    $self->{size}    = length $self->{html};
    undef $self->{mtime};

    return $self;
}

1;
