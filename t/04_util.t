use strict;
use Test::More 0.98;
use Time::Local;

#
#   Loading module
#
BEGIN {
    use_ok('XiuMai::Util',
            qw( cdata url_encode url_decode date_str size_str rfc1123_date
                canonpath randstr )
    );
}

#
#   Functions
#
my @cdata_test = (
    [ '&',      '&amp;'     ],
    [ '"',      '&quot;'    ],
    [ '<',      '&lt;'      ],
    [ '>',      '&gt;'      ],
    [ '&amp;',  '&amp;amp;' ],
    [ "'",      "'"         ],
    [ '<tag param="&value" />',
      '&lt;tag param=&quot;&amp;value&quot; /&gt;'  ],
);
for my $test (@cdata_test) {
    my ($src, $res) = @$test;
    is(cdata($src), $res, "cdata($src)");
}


my @url_encode_test = (
    [ "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
    . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
    . "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
    . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
    . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
    . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
    . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
    . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
    . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
    . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
    . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
    . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
    . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
    . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
    . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
    . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
    ,
      '%00%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F'
    . '%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F'
    . '%20%21%22%23%24%25%26%27%28%29*%2B%2C-./'
    . '0123456789%3A%3B%3C%3D%3E%3F'
    . '%40ABCDEFGHIJKLMNO'
    . 'PQRSTUVWXYZ%5B%5C%5D%5E_'
    . '%60abcdefghijklmno'
    . 'pqrstuvwxyz%7B%7C%7D~%7F'
    . '%80%81%82%83%84%85%86%87%88%89%8A%8B%8C%8D%8E%8F'
    . '%90%91%92%93%94%95%96%97%98%99%9A%9B%9C%9D%9E%9F'
    . '%A0%A1%A2%A3%A4%A5%A6%A7%A8%A9%AA%AB%AC%AD%AE%AF'
    . '%B0%B1%B2%B3%B4%B5%B6%B7%B8%B9%BA%BB%BC%BD%BE%BF'
    . '%C0%C1%C2%C3%C4%C5%C6%C7%C8%C9%CA%CB%CC%CD%CE%CF'
    . '%D0%D1%D2%D3%D4%D5%D6%D7%D8%D9%DA%DB%DC%DD%DE%DF'
    . '%E0%E1%E2%E3%E4%E5%E6%E7%E8%E9%EA%EB%EC%ED%EE%EF'
    . '%F0%F1%F2%F3%F4%F5%F6%F7%F8%F9%FA%FB%FC%FD%FE%FF'
    ,
      0, 'url_encode($url, 0)'  ]
    ,
    [ "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
    . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
    . "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
    . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
    . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
    . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
    . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
    . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
    . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
    . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
    . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
    . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
    . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
    . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
    . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
    . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
    ,
      '%00%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F'
    . '%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F'
    . '%20%21%22#%24%25&%27%28%29*+%2C-./'
    . '0123456789:%3B%3C=%3E?'
    . '%40ABCDEFGHIJKLMNO'
    . 'PQRSTUVWXYZ%5B%5C%5D%5E_'
    . '%60abcdefghijklmno'
    . 'pqrstuvwxyz%7B%7C%7D~%7F'
    . '%80%81%82%83%84%85%86%87%88%89%8A%8B%8C%8D%8E%8F'
    . '%90%91%92%93%94%95%96%97%98%99%9A%9B%9C%9D%9E%9F'
    . '%A0%A1%A2%A3%A4%A5%A6%A7%A8%A9%AA%AB%AC%AD%AE%AF'
    . '%B0%B1%B2%B3%B4%B5%B6%B7%B8%B9%BA%BB%BC%BD%BE%BF'
    . '%C0%C1%C2%C3%C4%C5%C6%C7%C8%C9%CA%CB%CC%CD%CE%CF'
    . '%D0%D1%D2%D3%D4%D5%D6%D7%D8%D9%DA%DB%DC%DD%DE%DF'
    . '%E0%E1%E2%E3%E4%E5%E6%E7%E8%E9%EA%EB%EC%ED%EE%EF'
    . '%F0%F1%F2%F3%F4%F5%F6%F7%F8%F9%FA%FB%FC%FD%FE%FF'
    ,
      1, 'url_encode($url, 1)'  ]
);

for my $test (@url_encode_test) {
    my ($src, $res, $rude, $case) = @$test;
    is(url_encode($src, $rude), $res, $case);
}


my @url_decode_test = (
    [   "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
      . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
      . "\x20\x21\x22\x23\x24\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
      . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
      . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
      . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
      . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
      . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
      . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
      . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
      . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
      . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
      . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
      . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
      . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
      . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
      ,
        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
      . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
      . "\x20\x21\x22\x23\x24\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
      . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
      . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
      . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
      . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
      . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
      . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
      . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
      . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
      . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
      . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
      . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
      . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
      . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
      , 'url_decode ( RAW DATA )'                                          ]
    ,
    [   "%00%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F"
      . "%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F"
      . "%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2D%2E%2F"
      . "%30%31%32%33%34%35%36%37%38%39%3A%3B%3C%3D%3E%3F"
      . "%40%41%42%43%44%45%46%47%48%49%4A%4B%4C%4D%4E%4F"
      . "%50%51%52%53%54%55%56%57%58%59%5A%5B%5C%5D%5E%5F"
      . "%60%61%62%63%64%65%66%67%68%69%6A%6B%6C%6D%6E%6F"
      . "%70%71%72%73%74%75%76%77%78%79%7A%7B%7C%7D%7E%7F"
      . "%80%81%82%83%84%85%86%87%88%89%8A%8B%8C%8D%8E%8F"
      . "%90%91%92%93%94%95%96%97%98%99%9A%9B%9C%9D%9E%9F"
      . "%A0%A1%A2%A3%A4%A5%A6%A7%A8%A9%AA%AB%AC%AD%AE%AF"
      . "%B0%B1%B2%B3%B4%B5%B6%B7%B8%B9%BA%BB%BC%BD%BE%BF"
      . "%C0%C1%C2%C3%C4%C5%C6%C7%C8%C9%CA%CB%CC%CD%CE%CF"
      . "%D0%D1%D2%D3%D4%D5%D6%D7%D8%D9%DA%DB%DC%DD%DE%DF"
      . "%E0%E1%E2%E3%E4%E5%E6%E7%E8%E9%EA%EB%EC%ED%EE%EF"
      . "%F0%F1%F2%F3%F4%F5%F6%F7%F8%F9%FA%FB%FC%FD%FE%FF"
      ,
        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
      . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
      . "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
      . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
      . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
      . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
      . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
      . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
      . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
      . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
      . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
      . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
      . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
      . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
      . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
      . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
      , 'url_decode ( lower case )'                                        ]
    ,
    [   "%00%01%02%03%04%05%06%07%08%09%0a%0b%0c%0d%0e%0f"
      . "%10%11%12%13%14%15%16%17%18%19%1a%1b%1c%1d%1e%1f"
      . "%20%21%22%23%24%25%26%27%28%29%2a%2b%2c%2d%2e%2f"
      . "%30%31%32%33%34%35%36%37%38%39%3A%3B%3C%3D%3E%3F"
      . "%40%41%42%43%44%45%46%47%48%49%4a%4b%4c%4d%4e%4f"
      . "%50%51%52%53%54%55%56%57%58%59%5a%5b%5c%5d%5e%5f"
      . "%60%61%62%63%64%65%66%67%68%69%6a%6b%6c%6d%6e%6f"
      . "%70%71%72%73%74%75%76%77%78%79%7a%7b%7c%7d%7e%7f"
      . "%80%81%82%83%84%85%86%87%88%89%8a%8b%8c%8d%8e%8f"
      . "%90%91%92%93%94%95%96%97%98%99%9a%9b%9c%9d%9e%9f"
      . "%a0%a1%a2%a3%a4%a5%a6%a7%a8%a9%aa%ab%ac%ad%ae%af"
      . "%b0%b1%b2%b3%b4%b5%b6%b7%b8%b9%ba%bb%bc%bd%be%bf"
      . "%c0%c1%c2%c3%c4%c5%c6%c7%c8%c9%ca%cb%cc%cd%ce%cf"
      . "%d0%d1%d2%d3%d4%d5%d6%d7%d8%d9%da%db%dc%dd%de%df"
      . "%E0%E1%E2%E3%E4%E5%E6%E7%E8%E9%EA%EB%EC%ED%EE%EF"
      . "%F0%F1%F2%F3%F4%F5%F6%F7%F8%F9%FA%FB%FC%FD%FE%FF"
      ,
        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
      . "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
      . "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f"
      . "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
      . "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f"
      . "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
      . "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f"
      . "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
      . "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f"
      . "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
      . "\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf"
      . "\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
      . "\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf"
      . "\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
      . "\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef"
      . "\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff"
      , 'url_decode ( upper case )'                                        ],
);

for my $test (@url_decode_test) {
    my ($src, $res, $case) = @$test;
    ok(url_decode($src) eq $res, $case);
}


my $now = time;
my $offset = timegm((localtime($now))[0..5]) - $now;

my @date_str_test = (
    [ 60*60*24 - $offset,          '1970/01/02',           'epoch'      ],
    [ 60*60*24 * 24854 - $offset,  '2038/01/18',           'last date'  ],
    [ undef,                       '\d{2}:\d{2}',          'now'        ],
    [ time - 60*60*12 + 60,        '\d{2}:\d{2}',          '* <- 12h'   ],
    [ time - 60*60*12,             '\d+/\d+ \d{2}:\d{2}',  '12h -> *'   ],
    [ time - 60*60*24*365/2 + 60,  '\d+/\d+ \d{2}:\d{2}',  '* <- 0.5Y'  ],
    [ time - 60*60*24*365/2,       '\d{4}/\d{2}/\d{2}',    '0.5Y -> *'  ],
);

is(date_str, date_str(time), "date_str(undef)");

for my $test (@date_str_test) {
    my ($src, $res, $case) = @$test;
    like(date_str($src), qr/^$res$/, "date_str ( $case )");
}


my @size_str_test = (
    [ undef,        '-'         ],
    [ 0,            '0'         ],
    [ 1023,         '1023'      ],
    [ 1024,         '1K'        ],
    [ 1024**2 -1,   '1023K'     ],
    [ 1024**2,      '1.0M'      ],
    [ 1024**3 -1,   '1024.0M'   ],
    [ 1024**3,      '1.0G'      ],
    [ 1024**4 -1,   '1024.0G'   ],
    [ 1024**4,      '1.0T'      ],
);

for my $test (@size_str_test) {
    my ($src, $res) = @$test;
    is(size_str($src), $res, "size_str ( $res )");
}


my @rfc1123_date_test = (
    [ 2007, 1, 1, 'Mon, 01 Jan 2007 00:00:00 GMT', 'Jan'    ],
    [ 2007, 2, 1, 'Thu, 01 Feb 2007 00:00:00 GMT', 'Feb'    ],
    [ 2007, 3, 1, 'Thu, 01 Mar 2007 00:00:00 GMT', 'Mar'    ],
    [ 2007, 4, 1, 'Sun, 01 Apr 2007 00:00:00 GMT', 'Apr'    ],
    [ 2007, 5, 1, 'Tue, 01 May 2007 00:00:00 GMT', 'May'    ],
    [ 2007, 6, 1, 'Fri, 01 Jun 2007 00:00:00 GMT', 'Jun'    ],
    [ 2007, 7, 1, 'Sun, 01 Jul 2007 00:00:00 GMT', 'Jul'    ],
    [ 2007, 8, 1, 'Wed, 01 Aug 2007 00:00:00 GMT', 'Aug'    ],
    [ 2007, 9, 1, 'Sat, 01 Sep 2007 00:00:00 GMT', 'Sep'    ],
    [ 2007,10, 1, 'Mon, 01 Oct 2007 00:00:00 GMT', 'Oct'    ],
    [ 2007,11, 1, 'Thu, 01 Nov 2007 00:00:00 GMT', 'Nov'    ],
    [ 2007,12, 1, 'Sat, 01 Dec 2007 00:00:00 GMT', 'Dec'    ],

    [ 2006,12,31, 'Sun, 31 Dec 2006 00:00:00 GMT', 'Sun'    ],
    [ 2007, 1, 1, 'Mon, 01 Jan 2007 00:00:00 GMT', 'Mon'    ],
    [ 2007, 1, 2, 'Tue, 02 Jan 2007 00:00:00 GMT', 'Tue'    ],
    [ 2007, 1, 3, 'Wed, 03 Jan 2007 00:00:00 GMT', 'Wed'    ],
    [ 2007, 1, 4, 'Thu, 04 Jan 2007 00:00:00 GMT', 'Thu'    ],
    [ 2007, 1, 5, 'Fri, 05 Jan 2007 00:00:00 GMT', 'Fri'    ],
    [ 2007, 1, 6, 'Sat, 06 Jan 2007 00:00:00 GMT', 'Sat'    ],
);

like(rfc1123_date, qr/^\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} GMT$/,
        "rfc1123_date - FORMAT");
is(rfc1123_date, rfc1123_date(time), "rfc1123_date(now)");

for my $test (@rfc1123_date_test) {
    my ($y, $m, $d, $res, $case) = @$test;
    is(rfc1123_date(timegm(0,0,0,$d,$m-1,$y-1900)), $res,
            "rfc1123_date - $case");
}


my @canonpath_test = (
    [ '',                   ''          ],
    [ 'a',                  ''          ],
    [ 'a/b',                ''          ],
    [ '/',                  '/'         ],
    [ '/a',                 '/a'        ],
    [ '/a/',                '/a/'       ],
    [ '/a/b',               '/a/b'      ],
    [ '/a/b/',              '/a/b/'     ],
    [ '/a/b/c',             '/a/b/c'    ],
    [ '//a/b/c',            '/a/b/c'    ],
    [ '/a//b/c',            '/a/b/c'    ],
    [ '/a/b//',             '/a/b/'     ],
    [ '//a//b//',           '/a/b/'     ],
    [ '/./a/b',             '/a/b'      ],
    [ '/a/./b',             '/a/b'      ],
    [ '/a/b/./',            '/a/b/'     ],
    [ '/a/b/.',             '/a/b/'     ],
    [ '/a/b/../',           '/a/'       ],
    [ '/a/b/..',            '/a/'       ],
    [ '/a/b/../c',          '/a/c'      ],
    [ '/a/b/../c/',         '/a/c/'     ],
    [ '/a/b/../../',        '/'         ],
    [ '/a/b/../../../',     '/'         ],
    [ '/a/b/../../../c',    '/c'        ],
    [ '/a/b/../../../c/',   '/c/'       ],
);

ok(! defined canonpath, "canonpath(undef)");

for my $test (@canonpath_test) {
    my ($src, $res, $case) = @$test;
    is(canonpath($src), $res, "canonpath($src)");
}


my @randstr_test = (
    [ [    ],                   '[0-9A-Z]{8}'   ],
    [ [  0 ],                   ''              ],
    [ [ 16 ],                   '[0-9A-Z]{16}'  ],
    [ [ 16, '0123456789' ],     '[0-9]{16}'     ],
    [ [  8, 'x' ],              'xxxxxxxx'      ],
);

for my $test (@randstr_test) {
    my ($param, $res) = @$test;
    my $case = "randstr(".join(', ', @$param).")";
    like(randstr(@$param), qr/^$res$/, $case);
}

my $times = 10_000;
my %rand;
my $i;
for ($i = 0; $i < $times; $i++) {
    my $rand = randstr;
    last if (exists $rand{$rand});
    $rand{$rand}++;
}
is($i, $times, "randstr x $times");


done_testing;
