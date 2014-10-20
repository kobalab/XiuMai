use strict;
use Test::More 0.98;

#
#   Set up
#
my $mime_type = 't/.mime_type';
open(MIME, ">$mime_type")   or die "$mime_type: $!";
while (<DATA>) {
    print MIME  $_;
}
close(MIME);

#
#   Loading module
#
BEGIN { use_ok('XiuMai::Util::MimeType'); }

#
#   Class Variables
#
is($XiuMai::Util::MimeType::VERSION, $XiuMai::VERSION, '$VERSION');

#
#   Class Methods
#
ok(my $mime = XiuMai::Util::MimeType->new(),
                                        'XiuMai::Util::MimeType->new()');
isa_ok($mime, 'XiuMai::Util::MimeType', ref $mime);

ok($mime = XiuMai::Util::MimeType->new(\*DATA, $mime_type),
                                        'XiuMai::Util::MimeType->new()');
isa_ok($mime, 'XiuMai::Util::MimeType', ref $mime);

#
#   Instance Methods
#
my %TEST_CASE = (
    'test.text'       => 'text/plain',
    'TEST.TXT'        => 'text/plain',
    'test.bin'        => 'application/octet-stream',
    'test.txt.png'    => 'image/png',
    'test'            => 'text/x-xiumai',
    'test.1-2'        => 'application/octet-stream',
    'test.css'        => 'text/html',
);
for my $file (sort keys %TEST_CASE) {
    is($mime->type($file), $TEST_CASE{$file}, $file);
}

unlink($mime_type);

done_testing;

__DATA__
text/html       css
