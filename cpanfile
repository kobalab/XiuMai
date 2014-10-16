requires 'perl', '5.008001';

requires 'CGI', '2.57';
requires 'Exporter';

on 'configure' => sub {
    requires 'Module::Build::Tiny', '0.039';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'HTTP::Request::Common';
    requires 'HTTP::Request::AsCGI';
    requires 'Time::Local';
};

