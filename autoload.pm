package autoload;


$VERSION = "1.00";

sub import
{
    shift;
    foreach my $pm (@_)
    {
        if (not defined %{"${pm}::"})
        {
            *{"${pm}::AUTOLOAD"} = sub
            {
                undef *{"${pm}::AUTOLOAD"};
                eval "require $pm";
                goto &{ "${pm}::" . *$AUTOLOAD{NAME} };
            };
            die "$@ " if $@;
        }
    }
}


1;

__END__;

=head1 NAME

autoload - only load modules when they're used

=head1 SYNOPSIS

# For a better example, see CGI::Object.pm. It uses
# autoload.pm in quite a nice way.

package MySimpleCookie;
use autoload qw(Exporter CGI::Object::Cookie);

@ISA = qw(Exporter CGI::Object::Cookie);
@EXPORT = qw(raw_fetch cookie raw_cookie);

# raw_fetch a list of cookies from the environment and
# return as a hash.  The cookie values are not unescaped
# or altered in any way.
sub raw_fetch {
    my $raw_cookie = $ENV{HTTP_COOKIE} || $ENV{COOKIE};
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

my $cookies;
sub raw_cookie
{
    my $name = shift;
    if (!$cookies) { $cookies = raw_fetch() }
    return $cookies->{$name};
}

package main;
# Now, people can use you just for your raw_cookie...
use MySimpleCookie('raw_fetch','raw_cookie');
$result = raw_cookie('blah');

# And it won't cost 'em a cent. They didn't use any
# functions from CGI::Object::Cookie, so the module
# wasn't loaded.

# But if they do use the functions, the module will load automatically
package main;
use MySimpleCookie('raw_fetch','cookie');
$result = cookie('blah');

# Or, if they even did this, the module would load automatically and work.
package main;
use MySimpleCookie;
$me = new MySimpleCookie;
print "Set-Cookie: ", $me->raw_cookie('blah');
print "Set-Cookie: ", $me->cookie('blah');

=head1 DESCRIPTION



=head1 AUTHOR

David James (david@jamesgang.com)

=head1 SEE ALSO

CGI::Object(1).

=cut
