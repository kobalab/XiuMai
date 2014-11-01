package XiuMai::HTML;

use strict;
use warnings;
use XiuMai;
use XiuMai::Locale;
use XiuMai::Util qw(cdata);

our $VERSION = "0.05";

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
        $self->lang($self->accept_language);
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

    my $toolbar = $self->_toolbar;
    my $footer  = $self->_footer;

    my $html = <<"__END_HTML__";
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
$toolbar
$content
$footer
</body>
</html>
__END_HTML__

    { my $x = $html, kill 0 }
    return $html;
}

sub _toolbar {
    my $self = shift;
    return ''   if (! $self->{Request});

    my $user_menu     = $self->_user_menu;
    my $resource_menu = $self->_resource_menu;

    return  qq(\n<header id="x-toolbar">\n)
          . $user_menu
          . $resource_menu
          . qq(\t<div style="clear: both"><div />\n)
          . qq(\t<hr />\n)
          . qq(</header>\n);
}

sub _user_menu {
    my $self = shift;

    my ($cmd, $login_or_logout);
    if (defined $self->{Request}->login_name) {
        $cmd = 'logout';
        $login_or_logout = cdata($self->msg('toolbar.user_menu.logout'));
    }
    else {
        $cmd = 'login';
        $login_or_logout = cdata($self->msg('toolbar.user_menu.login'));
    }

    return qq(\t<ul class="x-user_menu">\n)
         . qq(\t\t<li><a href="?cmd=$cmd">$login_or_logout</a></li>\n)
         . qq(\t</ul>\n);
}

sub _resource_menu { '' };

sub _footer {
    my $self = shift;
    return ''   if (! $self->{Request});

    return <<"__END_HTML__";
<footer id="x-footer">
    <hr />
    <a href="$XiuMai::PRODUCT_URL">$XiuMai::PRODUCT_NAME</a>
</footer>
__END_HTML__
}

sub login_form {
    my $self = shift;

    my $url        = cdata($self->{Request}->url);
    my $login_name = cdata($self->msg('login_form.login_name'));
    my $passwd     = cdata($self->msg('login_form.passwd'));
    my $submit     = cdata($self->msg('login_form.submit'));

    return <<"__END_HTML__";
<form class="x-login_form" method="post" action="$url">
<div>
    <input name="cmd" value="login" type="hidden" />
    <dl>
    <dt>$login_name</dt>
    <dd><input name="login_name" /></dd>
    <dt>$passwd</dt>
    <dd><input name="passwd" type="password" /></dd>
    </dl>
    <input type="submit" value="$submit" />
</div>
</form>
__END_HTML__
}

1;
