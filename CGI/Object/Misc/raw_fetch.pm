# fetch a list of cookies from the environment and
# return as a hash.  the cookie values are not unescaped
# or altered in any way.
sub raw_fetch {
    my $raw_cookie = $ENV{HTTP_COOKIE} || $ENV{COOKIE} || "";
    my %results;
    my(@pairs) = split("; ",$raw_cookie);
    foreach (@pairs) {
        if (/^([^=]+)=(.*)/) {
            $results{$1} = $2;
        }
        else {
            $results{$_} = '';
        }
    }
    return wantarray ? %results : \%results;
}
1;