use strict 'vars','subs';

sub compile
{
    my ($pack,$sub);
    PACK: foreach $pack (qw(
CGI3::Object::Html    
CGI3::Object::Request 
CGI3::Object::Cookie  
CGI3::Object::CGI3lib  
CGI3::Object::Response
CGI3::Object::Multipart ) )
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

    my @keys = keys %{"CGI3::Object::Misc::"};
    foreach $sub (@keys)
    {
        if (defined *{"CGI3::Object::Misc::$sub"}{CODE} && !defined &{"CGI3::Object::Misc::$sub"})
        {
            eval "require CGI3::Object::Misc::$sub";
        }
    }
}
1;