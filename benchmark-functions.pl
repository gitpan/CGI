$| = 1;
use lib '.';

use CGI qw(-no_debug :standard);

use Benchmark;

timethis(1,q{
        start_html('A Simple Example'),
        h1('A Simple Example'),
        start_form,
        "What's your name? ",textfield('name'),p,
        "What's the combination?", p,
        checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), p,
        "What's your favorite color? ",
        popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),p,
        submit,
        end_form,
        hr;
 });

timethis(200,q{
        start_html('A Simple Example'),
        h1('A Simple Example'),
        start_form,
        "What's your name? ",textfield('name'),p,
        "What's the combination?", p,
        checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), p,
        "What's your favorite color? ",
        popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),p,
        submit,
        end_form,
        hr;
 });

timethis(200,q{
        start_html('A Simple Example'),
        h1('A Simple Example'),
        start_form,
        "What's your name? ",textfield('name'),p,
        "What's the combination?", p,
        checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), p,
        "What's your favorite color? ",
        popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),p,
        submit,
        end_form,
        hr;
 });


timethis(200,q{
        start_html('A Simple Example'),
        h1('A Simple Example'),
        start_form,
        "What's your name? ",textfield('name'),p,
        "What's the combination?", p,
        checkbox_group(-name=>'words',
               -values=>['eenie','meenie','minie','moe'],
               -defaults=>['eenie','minie']), p,
        "What's your favorite color? ",
        popup_menu(-name=>'color',
               -values=>['red','green','blue','chartreuse']),p,
        submit,
        end_form,
        hr;
 });



