package XiuMai::HTML;

use strict;
use warnings;
use XiuMai;
use XiuMai::Locale;
use XiuMai::Util qw(cdata);

our $VERSION = $XiuMai::VERSION;

sub new {
    my $class = shift;
    my ($req) = @_;

    my $self = bless {
        charset     => 'utf-8',
        lang        => 'en',
        title       => '',
        icon        => $XiuMai::PRODUCT_URL.'css/icon.png',
        stylesheet  => [{href => $XiuMai::PRODUCT_URL.'css/xiumai.css'}],
        meta        => [],
        Request     => $req,
    }, $class;
    if ($req) {
        $self->charset($req->charset);
        $self->accept_language($req->accept_language);
    }
    return $self;
}

sub charset {
    my $self = shift;
    $self->{charset} = shift, return $self          if (@_);
    return $self->{charset};
}

sub lang {
    my $self = shift;
    $self->{lang} = shift, return $self             if (@_);
    return $self->{lang};
}

sub title {
    my $self = shift;
    $self->{title} = shift, return $self            if (@_);
    return $self->{title};
}

sub icon {
    my $self = shift;
    $self->{icon} = shift, return $self             if (@_);
    return $self->{icon};
}

sub stylesheet {
    my $self = shift;
    @{$self->{stylesheet}} = @_ and return $self    if (@_);
    return @{$self->{stylesheet}};
}

sub meta {
    my $self = shift;
    @{$self->{meta}} = @_ and return $self          if (@_);
    return @{$self->{meta}};
}

sub accept_language {
    my $self = shift;
    ($self->{Msg}, $self->{accept_language})
        = XiuMai::Locale::get(@_) and return $self  if (@_);
    return $self->{accept_language};
}

sub msg {
    my $self = shift;
    $self->{Msg} = XiuMai::Locale::get($self->{lang})
                                            if (! exists $self->{Msg});
    return $self->{Msg}->get(@_);
}

sub as_string {
    my $self = shift;
    my $content = join("\n", @_);

    my $charset = cdata($self->{charset});
    my $lang    = cdata($self->{lang});
    my $title   = cdata($self->{title});

    my $icon_url = cdata($self->{icon});

    my $stylesheet
            = join("\n\t",
                   map {
                       qq(<link rel="stylesheet" type="text/css" href=")
                     . cdata($_->{href}) . qq(")
                     . (defined $_->{media}
                            ? qq( media=").cdata($_->{media}).qq(")
                            : '')
                     . qq( />)
                   } @{$self->{stylesheet}}
              );

    push(@{$self->{meta}}, {
            name    => 'generator',
            content => "$XiuMai::PRODUCT_NAME ($XiuMai::PRODUCT_URL)"
        });
    my $meta = join("\n\t",
                    map {
                        my %meta = %$_;
                        qq(<meta )
                      . join(' ',
                             map {
                                my $key   = cdata($_);
                                my $value = cdata($meta{$_});
                                qq($key="$value")
                             } keys %meta
                        )
                      . qq( />)
                    } @{$self->{meta}}
               );

    my $html = <<"END_HTML";
<!DOCTYPE html>
<html lang="$lang">
<head>
    <meta charset="$charset" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>$title</title>
    <link rel="icon" type="image/png" href="$icon_url" />
    $stylesheet
    $meta
</head>
<body>
$content
</body>
</html>
END_HTML

    { my $x = $html, kill 0 }
    return $html;
}

1;
