BEGIN {
    $^W = 1;
    $| = 1;
}

use lib '.','..','../blib/lib','../blib/arch','blib/lib','blib/arch';
use CGI qw(:compile :all);
$compiled = 1;
print "1..2\nok 1\n";

    my $self = new CGI::Object;
    foreach (keys %CGI::Object::)
    {
        next if (/^_|^read|^croak|^Dump|^new_Multipart|^confess|^carp|^cluck|^DESTROY|^AUTOLOAD/);
        next unless /[a-zA-Z]/;
        if (*{"CGI::Object::$_"}{CODE})
        {
            $self->$_();
        }
        
    }
    print "ok 2\n";
    $done = 1;

END {
    if (!$compiled) { print "not ok 1\n"; }
    if (!$done) { print "not ok 2\n"; }
}


