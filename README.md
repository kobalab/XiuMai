# NAME

XiuMai - Web site construction tool

# SYNOPSIS

If you use XiuMai as CGI:

    use XiuMai;
    $ENV{XIUMAI_HOME} = '/path/of/datafiles';
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

But now, I'm trying refactoring. This release (on github) **doesn't work yet!**

# ENVIRONMENT VARIABLES

## XIUMAI\_HOME

Directory of authentication and contents repository.

## XIUMAI\_DATA

If you want to run 2 or more XiuMai, and must share authentication,
set authentication repository to XIUMAI\_HOME, and set contents repository to
XIUMAI\_DATA.

# LICENSE

Copyright (C) Satoshi Kobayashi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[http://www.yk.rim.or.jp/~koba/xiumai/](http://www.yk.rim.or.jp/~koba/xiumai/)

# AUTHOR

Satoshi Kobayashi <koba@yk.rim.or.jp>
