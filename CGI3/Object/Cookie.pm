package CGI3::Object::Cookie;

use strict;

my $read_cookie_data = 0;

my $cookie_map = {  NAME => 0,
                    VALUE => 1,
                    VALUES => 1,
                    PATH => 2,
                    DOMAIN => 3,
                    SECURE => 4,
                    EXPIRES => 5 }  ;
my $cookie_default = [];

sub cookie;
sub cookie_fetch;
sub expires;
sub expire_calc;
sub _read_cookie_data;


sub _read_cookie_data
{
    my $self = shift;
    my %cookies;
    my $cookie = $ENV{HTTP_COOKIE} || $ENV{COOKIE};
    if ($cookie)
    {
        # Convert pluses to spaces
        $cookie =~ tr/+/ /;

        # Convert %XX from hex numbers to alphanumeric
        $cookie =~ s/%([a-fA-F0-9]{2})/pack("c",hex($1))/ge;

        # Get each key=value pair
        $cookie =~ /([^=]+)=([^;]+)/g;
        do
        {
            # Ignore duplicate keys caused by Netscape bug
            if (!exists $cookies{$1})
            {
                # Update cookies hash
                if (index($2,"&") != -1)
                {
                    $cookies{$1} = [ split /&/, $2 ]
                }
                else
                {
                    $cookies{$1}=$2;
                }
            }
        } while ($cookie =~ /; ([^=]+)=([^;]+)/g)
    }
    $self->{'.cookies'} = \%cookies;
}


sub cookie {
    my $self = shift;

    if ($read_cookie_data==0)
    {
        $self->_read_cookie_data();
        $read_cookie_data=1;
    }

    # If there are no arguments
    if (@_ == 0)
    {
        return keys %{ $self->{'.cookies'} };
    }

    if (substr($_[0],0,1) eq "-" or ref($_[0]))
    {
        @_ = $self->rearrange($cookie_map,$cookie_default, @_);
    }
    elsif (@_ == 1)
    {
        my $name = shift;
        if (ref $self->{'.cookies'}->{$name})
        {
            return wantarray ? @{$self->{'.cookies'}->{$name}} : $self->{'.cookies'}->{$name}->[0];
        }
        elsif (defined $self->{'.cookies'}->{$name})
        {
            return $self->{'.cookies'}->{$name};
        }
        return;
    }

    if (@_ >= 2)
    {
        my ($name,$value,$path,$domain,$secure,$expires);
        foreach ($name,$value,$path,$domain,$secure,$expires)
        {
            next unless defined($_ = shift);
            s/([^\/?:@+\$,A-Za-z0-9\-_.!~*'()])/sprintf("%%%02x",ord($1))/eg;
        }

        if (ref $value eq "ARRAY")
        {
            $value = join("&",@$value);
        }
        elsif (ref $value eq "HASH")
        {
            $value = join("&",%$value);
        }
        $domain = "domain=$domain" if $domain;

        if ($path)
        {
            $path = "path=$path"
        }
        elsif (defined $ENV{'SCRIPT_NAME'})
        {
            $path = join('',"path=",$ENV{'SCRIPT_NAME'} =~ m{^(.*/)});
        }
        $secure = "secure" if $secure;
        $expires = "expires=" . $self->expires($expires) if $expires;

        return join("; ","$name=$value", grep { $_ } ($domain,$path,$secure,$expires));
    }
}

sub cookie_fetch {
    my $self = shift;
    return wantarray ? %{ $self->{'.cookies'} } : $self->{'.cookies'};
}

sub expires {

    my @MON =qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
    my @WDAY  = qw/Sun Mon Tue Wed Thu Fri Sat/;

    my($self,$time,$format) = @_;
    $format ||= 'http';

    # pass through preformatted dates for the sake of expire_calc()
    $time = $self->expire_calc($time);
    return $time unless $time =~ /^\d+$/;

    # make HTTP/cookie date string from GMT'ed time
    # (cookies use '-' as date separator, HTTP uses ' ')
    my($sc) = ' ';
    $sc = '-' if $format eq "cookie";
    my($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($time);
    $year += 1900;
    return sprintf("%s, %02d$sc%s$sc%04d %02d:%02d:%02d GMT",
                   $WDAY[$wday],$mday,$MON[$mon],$year,$hour,$min,$sec);
}

sub expire_calc {
    my($self,$time) = @_;
    my(%mult) = ('s'=>1,
                 'm'=>60,
                 'h'=>60*60,
                 'd'=>60*60*24,
                 'M'=>60*60*24*30,
                 'y'=>60*60*24*365);
    # format for time can be in any of the forms...
    # "now" -- expire immediately
    # "+180s" -- in 180 seconds
    # "+2m" -- in 2 minutes
    # "+12h" -- in 12 hours
    # "+1d"  -- in 1 day
    # "+3M"  -- in 3 months
    # "+2y"  -- in 2 years
    # "-3m"  -- 3 minutes ago(!)
    # If you don't supply one of these forms, we assume you are
    # specifying the date yourself
    my($offset);
    if (!$time || (lc($time) eq 'now')) {
        $offset = 0;
    } elsif ($time=~/^([+-]?[.\d]+)([mhdMy]?)/) {
        $offset = ($mult{$2} || 1)*$1;
    } else {
        return $time;
    }
    return (time+$offset);
}



use CGI3::Object;



1;

# Copyright Lincoln Stein & David James 1999