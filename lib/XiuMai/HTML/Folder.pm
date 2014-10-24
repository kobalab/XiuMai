package XiuMai::HTML::Folder;

use strict;
use warnings;
use XiuMai;
use XiuMai::HTML::Resource;
use XiuMai::Util qw(cdata url_encode date_str size_str);

use base 'XiuMai::HTML::Resource';

our $VERSION = $XiuMai::VERSION;

sub file_list {
    my $self = shift;

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
        my $url   = cdata(url_encode($file->filename));
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

1;
