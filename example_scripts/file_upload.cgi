#!/usr/local/bin/perl

use CGI;
$query = new CGI;
print $query->header;
print $query->start_html("File Upload Example");

print <<EOF;
<H1>File Upload Example</H1>
This example demonstrates how to prompt the remote user to
select a remote file for uploading.  <STRONG>This feature
only works with Netscape 2.0 browsers.</STRONG>
<P>
Select the <VAR>browse</VAR> button to choose a text file
to upload.  When you press the submit button, this script
will count the number of lines, words, and characters in
the file.
EOF
    ;

# Start a multipart form.
print $query->start_multipart_form;
print "Enter the file to process:",
    $query->filefield('filename','',45),"<BR>\n";
@types = ('count lines','count words','count characters');
print $query->checkbox_group('count',\@types,\@types),"\n<P>";
print $query->reset,$query->submit('submit','Process File');
print $query->endform;

# Process the form if there is a file name entered
if ($file = $query->param('filename')) {
    print "<HR>\n";
    print "<H2>$file</H2>\n";
    while (<$file>) {
	$lines++;
	$words += @words=split(/\s+/);
	$characters += length($_);
    }
    grep($stats{$_}++,$query->param('count'));
    if (%stats) {
	print "<STRONG>Lines: </STRONG>$lines<BR>\n" if $stats{'count lines'};
	print "<STRONG>Words: </STRONG>$words<BR>\n" if $stats{'count words'};
	print "<STRONG>Characters: </STRONG>$characters<BR>\n"
	    if $stats{'count characters'};
    } else {
	print "<STRONG>No statistics selected.</STRONG>\n";
    }
}

print <<EOF;
<HR>
<A HREF="../cgi_docs.html">CGI documentation</A>
<HR>
<ADDRESS>
<A HREF="/~lstein">Lincoln D. Stein</A>
</ADDRESS><BR>
Last modified 22 Oct 1995.
EOF
    ;
print $query->end_html;

