package CGI::Object::Misc;

sub AUTOLOAD
{
    print STDERR "CGI::Object::Misc::AUTOLOAD for $AUTOLOAD" if $CGI::AUTOLOAD_DEBUG;
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



