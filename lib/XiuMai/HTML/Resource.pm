package XiuMai::HTML::Resource;

use strict;
use warnings;
use XiuMai::HTML;
use XiuMai::Util qw(cdata url_encode);

use base 'XiuMai::HTML';

our $VERSION = "0.04";

sub new {
    my $class = shift;
    my ($r) = @_;
    my $self = new XiuMai::HTML($r->req);
    $self->{Resource} = $r;
    return bless $self, $class;
}

sub _r { $_[0]->{Resource} }

sub path_info {
    my $self = shift;
    my ($query) = @_;

    $query = $query ? cdata("?$query") : '';

    my $path_info = $self->_r->path_info;
    $path_info =~ s|/[^/]*$||;
    $path_info =~ s|^/||;

    my $html = qq(<nav class="x-path_info">);
    my $url  = cdata($self->_r->base_url).'/';
    $html .= qq(<a href="$url$query">HOME</a>/);
    for my $path (split('/', $path_info)) {
        $url  .= cdata(url_encode($path)).'/';
        $path  = cdata($path);
        $html .= qq(<a href="$url$query">$path</a>/);
    }
    $html .= qq(</nav>\n);

    return $html;
}

sub upload_form {
    my $self = shift;

    my $url    = cdata($self->_r->req->url);
    my $label  = cdata($self->msg('resource.upload_form.label'));
    my $submit = cdata($self->msg('resource.upload_form.submit'));

    return <<"__END_HTML__";
<form class="x-upload_form" method="post" action="$url" enctype="multipart/form-data">
<fieldset>
    <legend>$label</legend>
    <input name="file" type="file" />
    <input type="submit" value="$submit">
</fieldset>
</form>
__END_HTML__
}

sub _toolbar {
    my $self = shift;

    my $edit = cdata($self->msg('toolbar.resource_menu.edit'));

    return <<"__END_HTML__";

<header id="x-toolbar">
    <ul class="x-resource_menu">
        <li><a href="?cmd=edit" accesskey="e">$edit</a></li>
    </ul>
    <div style="clear: both"></div>
    <hr />
</header>
__END_HTML__
}

1;
