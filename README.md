# NAME

XiuMai - Web site construction tool

# SYNOPSIS

If you use XiuNai as CGI:

    use XiuMai;
    $ENV{XIUMA_HOME} = '/path/of/datafiles';
    XiuMai::handler;

or mod\_perl2:

    <IfModule perl_module>
        <Location /xiumai>
            SetHandler      perl-script
            PerlHandler     XiuMai
            PerlSetEnv      XIUMAI_HOME /path/of/datafiles
        </Location>
    </IfModule>

# DESCRIPTION

XiuMai is web site construction tool. It works on perl 5.8.1 or later.
But now, I'm trying refactoring. This release (on github) **does't work yet!**

# LICENSE

Copyright (C) Satoshi Kobayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[http://www.yk.rim.or.jp/~koba/xiumai/](http://www.yk.rim.or.jp/~koba/xiumai/)

# AUTHOR

Satoshi Kobayashi <koba@yk.rim.or.jp>
