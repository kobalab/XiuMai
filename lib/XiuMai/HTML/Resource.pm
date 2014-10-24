package XiuMai::HTML::Resource;

use strict;
use warnings;
use XiuMai;
use XiuMai::HTML;
use XiuMai::Util qw(cdata url_encode);

use base 'XiuMai::HTML';

our $VERSION = $XiuMai::VERSION;

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

    my $path_info = $self->_r->path_info;
    $path_info =~ s|/(.*)/[^/]*$|$1|;

    my $html = qq(<nav class="x-path_info">);
    my $url  = cdata($self->_r->base_url).'/';
    $html .= qq(<a href="$url">HOME</a>/);
    for my $path (split('/', $path_info)) {
        $url  .= cdata(url_encode($path)).'/';
        $path  = cdata($path);
        $html .= qq(<a href="$url">$path</a>/);
    }
    $html .= qq(</nav>\n);

    return $html;
}

1;
