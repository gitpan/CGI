package CGI3::Object::SelfLoader;
require 5.004;
require Carp;

sub autoload
{
    my $pack = *$AUTOLOAD{PACKAGE};
    my $name = *$AUTOLOAD{NAME};
    my $subs = \%{"${pack}::SUBS"};
    if ($subs->{$name})
    {
        eval qq(package $pack;\n$subs->{$name});
        goto &$AUTOLOAD if defined &$AUTOLOAD;
    }
    elsif (defined %$subs)
    {
        if (defined &{"${pack}::AUTOLOAD_FAIL"})
        {
            ${"${pack}::AUTOLOAD"} = $AUTOLOAD;
            goto &{"${pack}::AUTOLOAD_FAIL"}
        }
        if ($name eq "DESTROY")
        {
            *$AUTOLOAD = sub { };
            return;
        }
    }
    else
    {
        Carp::confess ("Could not find \%${pack}::SUBS");
    }
    Carp::confess ("Error autoloading $AUTOLOAD: $@") if $@;
    Carp::confess ("Undefined subroutine $AUTOLOAD");
}

sub import
{
    my $caller = caller();
    undef *{"${caller}::AUTOLOAD"};
    *{"${caller}::AUTOLOAD"} = \&autoload;
}


__END__

