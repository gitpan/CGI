BEGIN
{
    use Carp;
    $| = 1;
    sub warn { CORE::die Carp::longmess(@_) };
    sub die { CORE::die Carp::longmess(@_) };
    $SIG{"__WARN__"} = \&warn;
    $SIG{"__DIE__"} = \&die;
}

use Benchmark;

print "Loading time:\n";
timethese(1,
{
        CGI=>q{eval "use CGI qw(:no_debug)"; $C = new CGI },
        NEW=>q{use lib '.'; eval "use CGI::Object"; $O = new CGI::Object }
} );

print "Page Generation Speed:\n";
timethese(0,{

CGI=>q{
        $C->start_html('A Simple Example'),
        $C->h1('A Simple Example'),
        $C->start_form,
        "What's your name? ",$C->textfield('name'),$C->p,
        "What's the combination?", $C->p,
        $C->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $C->p,
        "What's your favorite color? ",
        $C->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$C->p,
        $C->submit,
        $C->end_form,
        $C->hr;
 },

NEW=>q{
        $O->start_html('A Simple Example'),
        $O->h1('A Simple Example'),
        $O->start_form,
        "What's your name? ",$O->textfield('name'),$O->p,
        "What's the combination?", $O->p,
        $O->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $O->p,
        "What's your favorite color? ",
        $O->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$O->p,
        $O->submit,
        $O->end_form,
        $O->hr;
 } } );


print "Parameter speed:\n";
timethese(0,{

CGI=>q{
        $C->param("hey","ho");
 },

NEW=>q{
        $O->param("hey","ho");
 } } );


print "Cookie speed:\n";

timethese(10000,{

CGI=>q{
        "" . $C->cookie("hey","ho");
 },

NEW=>q{
        "" . $O->cookie("hey","ho");
 } } );
