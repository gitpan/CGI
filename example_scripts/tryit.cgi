#!/usr/local/bin/perl

use CGI;
$query = new CGI;
print $query->header;
print <<END;
<TITLE>A Simple Example</TITLE>
<A NAME="top">
<H1>A Simple Example</H1>
</A>
END

print $query->startform;
print "What's your name? ",$query->textfield('name');
print "<P>What's the combination?<P>",
        $query->checkbox_group(-name=>'words',
			       -values=>['eenie','meenie','minie','moe']);

print "<P>What's your favorite color? ",
        $query->popup_menu(-name=>'color',
			   -values=>['red','green','blue','chartreuse']),
	"<P>";
print $query->submit;
print $query->endform;

print "<HR>\n";
if ($query->param) {
    print "Your name is <EM>",$query->param(name),"</EM>\n";
    print "<P>The keywords are: <EM>",join(", ",$query->param(words)),"</EM>\n";
    print "<P>Your favorite color is <EM>",$query->param(color),"</EM>\n";
}
print qq{<P><A HREF="cgi_docs.html">Go to the documentation</A>};
