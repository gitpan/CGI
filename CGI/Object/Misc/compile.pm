use strict 'vars','subs';

sub compile
{
    my ($pack,$sub);
    PACK: foreach $pack (qw(
CGI::Object::Html    
CGI::Object::Request 
CGI::Object::Cookie  
CGI::Object::CGIlib  
CGI::Object::Response
CGI::Object::Multipart ) )
    {
        foreach $sub (keys %{"$pack\::"})
        {
            if (defined &{"$pack\::$sub"} && $sub ne "AUTOLOAD")
            {
                next PACK;
            }
        }
        eval "require $pack"; die if $@;
    }

    my @keys = keys %{"CGI::Object::Misc::"};
    foreach $sub (@keys)
    {
        if (defined *{"CGI::Object::Misc::$sub"}{CODE} && !defined &{"CGI::Object::Misc::$sub"})
        {
            eval "require CGI::Object::Misc::$sub";
        }
    }
}
1;