package XiuMai::HTML::Folder;

use strict;
use warnings;
use XiuMai::HTML::Resource;
use XiuMai::Util qw(cdata url_encode date_str size_str);

use base 'XiuMai::HTML::Resource';

our $VERSION = "0.05";

sub file_list {
    my $self = shift;
    my ($query) = @_;

    $query    = $query ? "?$query" : '';

    my @file = sort { $a->filename cmp $b->filename } $self->_r->file;

    my $html = qq(<table class="x-file_list">\n);

    my $name  = cdata($self->msg('folder.file_list.name'));
    my $mtime = cdata($self->msg('folder.file_list.mtime'));
    my $size  = cdata($self->msg('folder.file_list.size'));
    my $type  = cdata($self->msg('folder.file_list.type'));
    $html .= qq(<thead><tr>)
           . qq(<th class="x-name">$name</th>)
           . qq(<th class="x-mtime">$mtime</th>)
           . qq(<th class="x-size">$size</th>)
           . qq(<th class="x-type">$type</th>)
           . qq(</tr></thead>\n);

    $html .= qq(<tbody>\n);
    for my $file (@file) {
        my $url   = cdata(url_encode($file->filename).$query);
        my $name  = cdata($file->filename);
        my $mtime = cdata(date_str($file->mtime));
        my $size  = cdata(size_str($file->size));
        my $type  = cdata($file->type);

        $html .= qq(\t<tr>)
               . qq(<td class="x-name"><a href="$url">$name</a></td>)
               . qq(<td class="x-mtime">$mtime</td>)
               . qq(<td class="x-size">$size</td>)
               . qq(<td class="x-type">$type</td>)
               . qq(</tr>\n);
    }
    $html .= qq(</tbody>\n);

    $html .= qq(</table>\n);

    return $html;
}

sub mkfile_form {
    my $self = shift;

    my $url        = cdata($self->_r->req->url);
    my $session_id = cdata($self->_r->req->session_id);
    my $label    = cdata($self->msg('folder.mkfile_form.label'));
    my $filename = cdata($self->msg('folder.mkfile_form.filename'));
    my $submit   = cdata($self->msg('folder.mkfile_form.submit'));

    return <<"__END_HTML__";
<form class="x-mkfile_form" method="post" action="$url">
<fieldset>
    <legend>$label</legend>
    <input name="session_id" value="$session_id" type="hidden" />
    $filename
    <input name="filename" />
    <input type="submit" value="$submit" />
</fieldset>
</form>
__END_HTML__
}

sub mkdir_form {
    my $self = shift;

    my $url        = cdata($self->_r->req->url);
    my $session_id = cdata($self->_r->req->session_id);
    my $label   = cdata($self->msg('folder.mkdir_form.label'));
    my $dirname = cdata($self->msg('folder.mkdir_form.dirname'));
    my $submit  = cdata($self->msg('folder.mkdir_form.submit'));

    return <<"__END_HTML__";
<form class="x-mkdir_form" method="post" action="$url">
<fieldset>
    <legend>$label</legend>
    <input name="session_id" value="$session_id" type="hidden" />
    $dirname
    <input name="dirname" />
    <input type="submit" value="$submit" />
</fieldset>
</form>
__END_HTML__
}

sub rmdir_form {
    my $self = shift;

    my $url        = cdata($self->_r->req->url);
    my $session_id = cdata($self->_r->req->session_id);
    my $label   = cdata($self->msg('folder.rmdir_form.label'));
    my $submit  = cdata($self->msg('folder.rmdir_form.submit'));

    return <<"__END_HTML__";
<form class="x-rmdir_form" method="post" action="$url">
<fieldset>
    <legend>$label</legend>
    <input name="session_id" value="$session_id" type="hidden" />
    <input type="submit" value="$submit" />
</fieldset>
</form>
__END_HTML__
}

1;
