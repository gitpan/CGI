package CGI3::Object::Misc;

sub AUTOLOAD
{
    print STDERR "CGI3::Object::Misc::AUTOLOAD for $AUTOLOAD" if $CGI3::AUTOLOAD_DEBUG;
    eval "use $AUTOLOAD";
    if (!$@)
    {
        goto &$AUTOLOAD;
    }
    else
    {
        die "Could not load $AUTOLOAD.pm";
    }
}

1;



