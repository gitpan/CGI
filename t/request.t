#!/usr/local/bin/perl -w

# Test ability to retrieve HTTP request info
######################### We start with some black magic to print on failure.
use lib '..','../blib/lib','../blib/arch';

BEGIN {$| = 1; print "1..31\n"; $^W = 1; }
END {print "not ok 1\n" unless $loaded;}
use CGI3 ();
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# util
sub test ($$$;$) {
    local($^W) = 0;
    if (@_ == 3)
    {
        my ($num,$true,$msg) = @_;
        print($true ? "ok $num\n" : "not ok $num $msg\n");
        return;
    }
    
    my($num, $first,$second,$msg) = @_;
    print($first eq $second ? "ok $num\n" : "not ok $num $msg\n{$first}\nne\n{$second}\n\n\n\n");
}

# Set up a CGI3 environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';
$ENV{PATH_INFO}       = '/somewhere/else';
$ENV{PATH_TRANSLATED} = '/usr/local/somewhere/else';
$ENV{SCRIPT_NAME}     = '/cgi-bin/foo.cgi';
$ENV{SERVER_PROTOCOL} = 'HTTP/1.0';
$ENV{SERVER_PORT}     = 8080;
$ENV{SERVER_NAME}     = 'the.good.ship.lollypop.com';
$ENV{REQUEST_URI}     = "$ENV{SCRIPT_NAME}$ENV{PATH_INFO}?$ENV{QUERY_STRING}";
$ENV{HTTP_LOVE}       = 'true';

$q = new CGI3;
test(2,$q,"CGI3::new()");
test(3,$q->request_method, 'GET',"CGI3::request_method()");
test(4,$q->query_string, 'game=chess&game=checkers&weather=dull',"CGI3::query_string()");
test(5,0+($q->param()),2,"CGI3::param()");
test(6,join(' ',sort $q->param()), 'game weather',"CGI3::param()");
test(7,$q->param('game'), 'chess',"CGI3::param()");
test(8,$q->param('weather'), 'dull',"CGI3::param()");
test(9,join(' ',$q->param('game')), 'chess checkers',"CGI3::param()");
test(10,$q->param(-name=>'foo',-value=>'bar'),'CGI3::param() put');
test(11,$q->param(-name=>'foo'), 'bar','CGI3::param() get');
test(12,$q->query_string, 'game=chess&game=checkers&weather=dull&foo=bar',"CGI3::query_string() redux");
test(13,$q->http('love'), 'true',"CGI3::http()");
test(14,$q->script_name, '/cgi-bin/foo.cgi',"CGI3::script_name()");
test(15,$q->url, 'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi',"CGI3::url()");
test(16,$q->self_url, 
     'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi/somewhere/else?game=chess&game=checkers&weather=dull&foo=bar',
     "CGI3::url()");
test(17,$q->url(-absolute=>1), '/cgi-bin/foo.cgi','CGI3::url(-absolute=>1)');
test(18,$q->url(-relative=>1), 'foo.cgi','CGI3::url(-relative=>1)');
test(19,$q->url(-relative=>1,-path=>1), 'foo.cgi/somewhere/else','CGI3::url(-relative=>1,-path=>1)');
test(20,$q->url(-relative=>1,-path=>1,-query=>1), 
     'foo.cgi/somewhere/else?game=chess&game=checkers&weather=dull&foo=bar',
     'CGI3::url(-relative=>1,-path=>1,-query=>1)');
$q->delete('foo');
test(21,!$q->param('foo'),'CGI3::delete()');

$q->_reset_globals;
$ENV{QUERY_STRING}='mary+had+a+little+lamb';
test(22,$q=new CGI3,"CGI::new() redux");
test(23,join(' ',$q->keywords), 'mary had a little lamb','CGI3::keywords');
test(24,join(' ',$q->param('keywords')), 'mary had a little lamb','CGI3::keywords');
test(25,$q=new CGI3('foo=bar&foo=baz'),"CGI::new() redux");
test(26,$q->param('foo'), 'bar','CGI3::param() redux');
test(27,$q=new CGI3({'foo'=>'bar','bar'=>'froz'}),"CGI::new() redux 2");
test(28,$q->param('bar'), 'froz',"CGI3::param() redux 2");

$q->_reset_globals;
$test_string = 'game=soccer&game=baseball&weather=nice';
$ENV{REQUEST_METHOD}='POST';
$ENV{CONTENT_LENGTH}=length($test_string);
$ENV{QUERY_STRING}='big_balls=basketball&small_balls=golf';

foreach my $filename ('request2','./t/request2','../t/request2')
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

