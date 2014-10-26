package XiuMai::Locale;

use strict;
use warnings;
use XiuMai::Util::Msg;

our $VERSION = "0.03";

my %locale = ( en => undef, ja => undef, zh_CN => undef );

sub lang { return sort map { s/_/\-/g; $_ } keys %locale }

sub get {
    my @lang = @_;
    while (my $lang = shift @lang) {
        $lang =~ s/\-/_/g;
        if (my ($pm) = grep { lc($_) eq lc($lang) } keys %locale) {
            my $msg = ($locale{$pm}
                    or $locale{$pm} = eval qq{ require XiuMai::Locale::$pm });
            $pm =~ s/_/\-/g;
            return wantarray ? ($msg, $pm) : $msg;
        }
        $lang =~ s/\_[^_]*$//   and push(@lang, $lang);
    }
    return get('en');
}

1;
