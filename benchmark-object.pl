$| = 1;
use lib '.';

use CGI::Object;
$CGI::NO_DEBUG = 1;

use Benchmark;

$q = new CGI::Object;

timethis(1,q{
        $q->start_html('A Simple Example'),
        $q->h1('A Simple Example'),
        $q->start_form,
        "What's your name? ",$q->textfield('name'),$q->p,
        "What's the combination?", $q->p,
        $q->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $q->p,
        "What's your favorite color? ",
        $q->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$q->p,
        $q->submit,
        $q->end_form,
        $q->hr;
 });


timethis(200,q{
        $q->start_html('A Simple Example'),
        $q->h1('A Simple Example'),
        $q->start_form,
        "What's your name? ",$q->textfield('name'),$q->p,
        "What's the combination?", $q->p,
        $q->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $q->p,
        "What's your favorite color? ",
        $q->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$q->p,
        $q->submit,
        $q->end_form,
        $q->hr;
 });


timethis(200,q{
        $q->start_html('A Simple Example'),
        $q->h1('A Simple Example'),
        $q->start_form,
        "What's your name? ",$q->textfield('name'),$q->p,
        "What's the combination?", $q->p,
        $q->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $q->p,
        "What's your favorite color? ",
        $q->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$q->p,
        $q->submit,
        $q->end_form,
        $q->hr;
 });

timethis(200,q{
        $q->start_html('A Simple Example'),
        $q->h1('A Simple Example'),
        $q->start_form,
        "What's your name? ",$q->textfield('name'),$q->p,
        "What's the combination?", $q->p,
        $q->checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), $q->p,
        "What's your favorite color? ",
        $q->popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),$q->p,
        $q->submit,
        $q->end_form,
        $q->hr;
 });
