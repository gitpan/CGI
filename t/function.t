#!/usr/local/bin/perl -w

# Test ability to retrieve HTTP request info
######################### We start with some black magic to print on failure.
use lib '..','../blib/lib','../blib/arch';

BEGIN {$| = 1; print "1..24\n"; $^W = 1; }
END {print "not ok 1\n" unless $loaded;}
use CGI3::Object (':standard','keywords');
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# util
sub test {
    local($^W) = 0;
    my($num, $true,$msg) = @_;
    print($true ? "ok $num\n" : "not ok $num $msg\n");
}

# Set up a CGI3 environment
$ENV{REQUEST_METHOD}='GET';
$ENV{QUERY_STRING}  ='game=chess&game=checkers&weather=dull';
$ENV{PATH_INFO}     ='/somewhere/else';
$ENV{PATH_TRANSLATED} ='/usr/local/somewhere/else';
$ENV{SCRIPT_NAME}   ='/cgi-bin/foo.cgi';
$ENV{SERVER_PROTOCOL} = 'HTTP/1.0';
$ENV{SERVER_PORT} = 8080;
$ENV{SERVER_NAME} = 'the.good.ship.lollypop.com';
$ENV{HTTP_LOVE} = 'true';

test(2,request_method() eq 'GET',"CGI3::request_method()");
test(3,query_string() eq 'game=chess&game=checkers&weather=dull',"CGI3::query_string()");
test(4,param() == 2,"CGI3::param()");
test(5,join(' ',sort {$a cmp $b} param()) eq 'game weather',"CGI3::param()");
test(6,param('game') eq 'chess',"CGI3::param()");
test(7,param('weather') eq 'dull',"CGI3::param()");
test(8,join(' ',param('game')) eq 'chess checkers',"CGI3::param()");
test(9,param(-name=>'foo',-value=>'bar'),'CGI3::param() put');
test(10,param(-name=>'foo') eq 'bar','CGI3::param() get');
test(11,query_string() eq 'game=chess&game=checkers&weather=dull&foo=bar',"CGI3::query_string() redux");
test(12,http('love') eq 'true',"CGI3::http()");
test(13,script_name() eq '/cgi-bin/foo.cgi',"CGI3::script_name()");
test(14,url() eq 'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi',"CGI3::url()");
test(15,self_url() eq 
     'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi/somewhere/else?game=chess&game=checkers&weather=dull&foo=bar',
     "CGI3::url()");
test(16,url(-absolute=>1) eq '/cgi-bin/foo.cgi','CGI3::url(-absolute=>1)');
test(17,url(-relative=>1) eq 'foo.cgi','CGI3::url(-relative=>1)');
test(18,url(-relative=>1,-path=>1) eq 'foo.cgi/somewhere/else','CGI3::url(-relative=>1,-path=>1)');
test(19,url(-relative=>1,-path=>1,-query=>1) eq 
     'foo.cgi/somewhere/else?game=chess&game=checkers&weather=dull&foo=bar',
     'CGI3::url(-relative=>1,-path=>1,-query=>1)');
Delete('foo');
test(20,!param('foo'),'CGI3::delete()');

CGI3::_reset_globals();
$ENV{QUERY_STRING}='mary+had+a+little+lamb';
test(21,join(' ',keywords()) eq 'mary had a little lamb','CGI3::keywords' . keywords());
test(22,join(' ',param('keywords')) eq 'mary had a little lamb','CGI3::keywords');

CGI3::_reset_globals();
$test_string = 'game=soccer&game=baseball&weather=nice';
$ENV{REQUEST_METHOD}='POST';
$ENV{CONTENT_LENGTH}=length($test_string);
$ENV{QUERY_STRING}='big_balls=basketball&small_balls=golf';

foreach my $filename ('function2','./t/function2','../t/function2')
{
    if (-e $filename)
    {
        if (open(CHILD,"|perl $filename")) {  # cparent
            print CHILD $test_string;
            close CHILD;
            exit 0;
        }
    }
}

