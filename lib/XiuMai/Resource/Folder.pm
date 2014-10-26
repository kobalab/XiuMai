package XiuMai::Resource::Folder;

use strict;
use warnings;
use XiuMai::Resource;
use XiuMai::HTML::Folder;
use XiuMai::Util qw(cdata url_encode);
use IO::Dir;
use IO::File;

use base 'XiuMai::Resource';

our $VERSION = "0.03";

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

sub update {
    my $self = shift;

    $self->redirect(303, './?cmd=edit');

    if (defined $self->req->param('filename')) {
        return $self->_mkfile($self->req->param('filename'));
    }
    elsif (defined $self->req->param('dirname')) {
        return $self->_mkdir($self->req->param('dirname'));
    }
    else {
        return $self->_rmdir;
    }
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

sub _mkfile {
    my $self = shift;
    my ($filename) = @_;

    return $self    if (! length $filename);

    $filename =~ s/^\./_/;
    $filename =~ s/[\:\\\/]/_/g;
    $filename =~ /^(.*)$/       and $filename = $1;

    my $fh = new IO::File(">>$self->{full_name}/$filename")     or return;
    $fh->close;

    $self->redirect(303, url_encode($filename).'?cmd=edit');

    return $self;
}

sub _mkdir {
    my $self = shift;
    my ($dirname) = @_;

    return $self    if (! length $dirname);

    $dirname =~ s/^\./_/;
    $dirname =~ s/[\:\\\/]/_/g;
    $dirname =~ /^(.*)$/        and $dirname = $1;

    mkdir($self->{full_name}.$dirname, 0777)   or return;

    $self->redirect(303, url_encode($dirname).'/?cmd=edit');

    return $self;
}

sub _rmdir {
    my $self = shift;

    return if ($self->{full_name} eq $self->{base_dir}.'/');

    rmdir($self->{full_name})   or return;

    $self->redirect(303, '../?cmd=edit');

    return $self;
}

1;
