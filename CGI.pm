package CGI;

require 5.001;
$CGI::revision = '$Id: CGI.pm,v 1.1.1.1 1995/12/01 05:58:39 lstein Exp $';
$CGI::VERSION=2.13;

=head1 NAME

CGI - Simple Common Gateway Interface Class

=head1 ABSTRACT

This perl library uses perl5 objects to make it easy to create
Web fill-out forms and parse their contents.  This package
defines CGI objects, entities that contain the values of the
current query string and other state variables.
Using a CGI object's methods, you can examine keywords and parameters
passed to your script, and create forms whose initial values
are taken from the current query (thereby preserving state
information).

=head1 INSTALLATION:

To install this package, just change to the directory in which this
file is found and type the following:

	perl Makefile.PL
	make
	make install

This will copy CGI.pm to your perl library directory for use by all
perl scripts.  You probably must be root to do this.   Now you can
load the CGI routines in your Perl scripts with the line:

	use CGI;

If you don't have sufficient privileges to install CGI.pm in the Perl
library directory, you can put CGI.pm into some convenient spot, such
as your home directory, or in cgi-bin itself and prefix all Perl
scripts that call it with something along the lines of the following
preamble:

	BEGIN {
		unshift(@INC,'/home/davis/lib');
	}
	use CGI;

=head1 DESCRIPTION

=head2 CREATING A NEW QUERY OBJECT:

     $query = new CGI

This will parse the input (from both POST and GET methods) and store
it into a perl5 object called $query.  

=head2 CREATING A NEW QUERY OBJECT FROM AN INPUT FILE

     $query = new CGI(INPUTFILE)

If you provide a file handle to the new() method, it
will read parameters from the file (or STDIN, or whatever).  The
file can be in any of the forms describing below under debugging
(i.e. a series of newline delimited TAG=VALUE pairs will work).
Conveniently, this type of file is created by the save() method
(see below).

=head2 FETCHING A LIST OF KEYWORDS FROM THE QUERY:

     @keywords = $query->keywords

If the script was invoked as the result of an <ISINDEX> search, the
parsed keywords can be obtained as an array using the keywords() method.

=head2 FETCHING THE NAMES OF ALL THE PARAMETERS PASSED TO YOUR SCRIPT:

     @names = $query->param

If the script was invoked with a parameter list
(e.g. "name1=value1&name2=value2&name3=value3"), the param()
method will return the parameter names as a list.  If the
script was invoked as an <ISINDEX> script, there will be a
single parameter named 'keywords'.

NOTE: As of version 1.5, the array of parameter names returned will
be in the same order as they were submitted by the browser.
Usually this order is the same as the order in which the 
parameters are defined in the form (however, this isn't part
of the spec, and so isn't guaranteed).

=head2 FETCHING THE VALUE OR VALUES OF A SINGLE NAMED PARAMETER:

    @values = $query->param('foo');

              -or-

    $value = $query->param('foo');

Pass the param() method a single argument to fetch the value of the
named parameter. If the parameter is multivalued (e.g. from multiple
selections in a scrolling list), you can ask to receive an array.  Otherwise
the method will return a single value.

=head2 SETTING THE VALUE(S) OF A NAMED PARAMETER:

    $query->param('foo','an','array','of','values');

This sets the value for the named parameter 'foo' to an array of
values.  Do this if you want to change the value of a field AFTER
the script has been invoked before.

=head2 IMPORTING ALL PARAMETERS INTO A NAMESPACE:

   $query->import_names('R');

This creates a series of variables in the 'R' namespace.  For example,
$R::foo, @R:foo.  For keyword lists, a variable @R::keywords will appear.
If no namespace is given, this method will assume 'Q'.
WARNING:  don't import anything into 'main'; this is a major security
risk!!!!

In older versions, this method was called import().  While the old name
is maintained for compatability, use import_names() for consistency with
the CGI:: modules.

=head2 DELETING A PARAMETER COMPLETELY:

    $query->delete('foo');

This completely clears a parameter.  It sometimes useful for
resetting parameters that you don't want passed down between
script invocations.

=head2 SAVING THE STATE OF THE FORM TO A FILE:

    $query->save(FILEHANDLE)

This will write the current state of the form to the provided
filehandle.  You can read it back in by providing a filehandle
to the new() method.  Note that the filehandle can be a file, a pipe,
or whatever!

=head2 CREATING A SELF-REFERENCING URL THAT PRESERVES STATE INFORMATION:

    $myself = $query->self_url
    print "<A HREF=$myself>I'm talking to myself.</A>

self_url() will return a URL, that, when selected, will reinvoke
this script with all its state information intact.  This is most
useful when you want to jump around within the document using
internal anchors but you don't want to disrupt the current contents
of the form(s).  Something like this will do the trick.

     $myself = $query->self_url
     print "<A HREF=$myself#table1>See table 1</A>
     print "<A HREF=$myself#table2>See table 2</A>
     print "<A HREF=$myself#yourself>See for yourself</A>

=head2 CALLING CGI FUNCTIONS THAT TAKE MULTIPLE ARGUMENTS

In versions of CGI.pm prior to 2.0, it could get difficult to remember
the proper order of arguments in CGI function calls that accepted five
or six different arguments.  As of 2.0, there's a better way to pass
arguments to the various CGI functions.  In this style, you pass a
series of name=>argument pairs, like this:

   $field = $query->radio_group(-name=>'OS',
                                -values=>[Unix,Windows,Macintosh],
                                -default=>'Unix');

The advantages of this style are that you don't have to remember the
exact order of the arguments, and if you leave out a parameter, in
most cases it will default to some reasonable value.  If you provide
a parameter that the method doesn't recognize, it will usually do
something useful with it, such as incorporating it into the HTML form
tag.  For example if Netscape decides next week to add a new
JUSTIFICATION parameter to the text field tags, you can start using
the feature without waiting for a new version of CGI.pm:

   $field = $query->textfield(-name=>'State',
                              -default=>'gaseous',
                              -justification=>'RIGHT');

This will result in an HTML tag that looks like this:

	<INPUT TYPE="textfield" NAME="State" VALUE="gaseous"
               JUSTIFICATION="RIGHT">

Parameter names are case insensitive: you can use -name, or -Name or
-NAME.  You don't have to use the hyphen if you don't want to.  After
creating a CGI object, call the B<use_named_parameters()> method with
a nonzero value.  This will tell CGI.pm that you intend to use named
parameters exclusively:

   $query = new CGI;
   $query->use_named_parameters(1);
   $field = $query->radio_group('name'=>'OS',
                                'values'=>['Unix','Windows','Macintosh'],
                                'default'=>'Unix');

Actually, CGI.pm only looks for a hyphen in the first parameter.  So
you can leave it off subsequent parameters if you like.  Something to
be wary of is the potential that a string constant like "values" will
collide with a keyword (and in fact it does!) While Perl usually
figures out when you're referring to a function and when you're
referring to a string, you probably should put quotation marks around
all string constants just to play it safe.

=head2 CREATING THE HTTP HEADER:

	print $query->header;

             -or-

        print $query->header('image/gif');

             -or-

        print $query->header('text/html','204 No response');

             -or-

        print $query->header(-type=>'image/gif',
			     -status=>'402 Payment required',
			     -Cost=>'$2.00');

header() returns the Content-type: header.  You can provide your own
MIME type if you choose, otherwise it defaults to text/html.  An
optional second paramer specifies the status code and a human-readable
message.  For example, you can specify 204, "No response" to create a
script that tells the browser to do nothing at all.  If you want to
add additional fields to the header, just tack them on to the end:

    print $query->header('text/html','200 OK','Content-Length: 3002');

The last example shows the named argument style for passing arguments
to the CGI methods using named parameters.  Recognized parameters are
B<-type> and B<-status>.  Any other parameters will be stripped of
their initial hyphens and turned into header fields.

As of version 1.56, all HTTP headers produced by CGI.pm contain the
Pragma: no-cache instruction.  However, as of version 1.57, this is
turned OFF by default because it causes Netscape 2.0 beta to produce
an annoying warning message every time the "back" button is hit.  Turn
it on again with the method cache().

=head2 GENERATING A REDIRECTION INSTRUCTION

   print $query->redirect('http://somewhere.else/in/movie/land');

redirects the browser elsewhere.  If you use redirection like this,
you should B<not> print out a header as well.  As of version 2.0, we
produce both the unofficial Location: header and the official URI:
header.  This should satisfy most servers and browsers.

One hint I can offer is that relative links may not work correctly
when when you generate a redirection to another document on your site.
This is due to a well-intentioned optimization that some servers use.
The solution to this is to use the full URL (including the http: part)
of the document you are redirecting to.

=head2 CREATING THE HTML HEADER:

   print $query->start_html(-title=>'Secrets of the Pyramids',
                            -author=>'fred@capricorn.org',
                            -base=>'true',
                            -BGCOLOR=>"#00A0A0"');

   -or-

   print $query->start_html('Secrets of the Pyramids',
                            'fred@capricorn.org','true',
                            'BGCOLOR="#00A0A0"');

This will return a canned HTML header and the opening <BODY> tag.  
All parameters are optional.   In the named parameter form, recognized
parameters are -title, -author and -base (see below for the
explanation).  Any additional parameters you provide, such as the
Netscape unofficial BGCOLOR attribute, are added to the <BODY> tag.

Positional parameters are as follows:

=over 4

=item B<Parameters:>

=item 1.

The title

=item 2.

The author's e-mail address (will create a <LINK REV="MADE"> tag if present

=item 3.

A 'true' flag if you want to include a <BASE> tag in the header.  This
helps resolve relative addresses to absolute ones when the document is moved, 
but makes the document hierarchy non-portable.  Use with care!

=item 4, 5, 6...

Any other parameters you want to include in the <BODY> tag.  This is a good
place to put Netscape extensions, such as colors and wallpaper patterns.

=back

=head2 ENDING THE HTML DOCUMENT:

	print $query->end_html

This ends an HTML document by printing the </BODY></HTML> tags.

=head1 CREATING FORMS:

I<General note>  The various form-creating methods all return strings
to the caller, containing the tag or tags that will create the requested
form element.  You are responsible for actually printing out these strings.
It's set up this way so that you can place formatting tags
around the form elements.

I<Another note> The default values that you specify for the forms are only
used the B<first> time the script is invoked.  If there are already values
present in the query string, they are used, even if blank.  If you want
to change the value of a field from its previous value, call the param()
method to set it.

I<Yet another note> By default, the text and labels of form elements are
escaped according to HTML rules.  This means that you can safely use
"<CLICK ME>" as the label for a button.  However, it also interferes with
your ability to incorporate special HTML character sequences, such as &Aacute;,
into your fields.  If you wish to turn off automatic escaping, call the
autoEscape() method with a false value immediately after creating the CGI object:

   $query = new CGI;
   $query->autoEscape(undef);
			     

=head2 CREATING AN ISINDEX TAG

   print $query->isindex(-action=>$action);

	 -or-

   print $query->isindex($action);

Prints out an <ISINDEX> tag.  Not very exciting.  The parameter
-action specifies the URL of the script to process the query.  The
default is to process the query with the current script.

=head2 STARTING AND ENDING A FORM

    print $query->startform(-method=>$method,
	                    -action=>$action,
	                    -encoding=>$encoding);
      <... various form stuff ...>
    print $query->endform;

	-or-

    print $query->startform($method,$action,$encoding);
      <... various form stuff ...>
    print $query->endform;

startform() will return a <FORM> tag with the optional method,
action and form encoding that you specify.  The defaults are:
	
    method: POST
    action: this script
    encoding: application/x-www-form-urlencoded

The encoding method tells the browser how to package the various
fields of the form before sending the form to the server.  Two
values are possible:

=over 4

=item B<application/x-www-form-urlencoded>

This is the older type of encoding used by all browsers prior to
Netscape 2.0.  It is compatible with many CGI scripts and is
suitable for short fields containing text data.  For your
convenience, CGI.pm stores the name of this encoding
type in B<$CGI::URL_ENCODED>.

=item B<multipart/form-data>

This is the newer type of encoding introduced by Netscape 2.0.
It is suitable for forms that contain very large fields or that
are intended for transferring binary data.  Most importantly,
it enables the "file upload" feature of Netscape 2.0 forms.  For
your convenience, CGI.pm stores the name of this encoding type
in B<$CGI::MULTIPART>

Forms that use this type of encoding are not easily interpreted
by CGI scripts unless they use CGI.pm or another library designed
to handle them.

=back

For compatability, the startform() method uses the older form of
encoding by default.  If you want to use the newer form of encoding
by default, you can call B<start_multipart_form()> instead of
B<startform()>.
	
endform() returns a </FORM> tag.  

=head2 CREATING A TEXT FIELD

    print $query->textfield(-name=>'field_name',
	                    -default=>'starting value',
	                    -size=>50,
	                    -maxlength=>80);
	-or-

    print $query->textfield('field_name','starting value',50,80);

textfield() will return a text input field.  

=over 4

=item B<Parameters>

=item 1.

The first parameter is the required name for the field (-name).  

=item 2.

The optional second parameter is the default starting value for the field
contents (-default).  

=item 3.

The optional third parameter is the size of the field in
      characters (-size).

=item 4.

The optional fourth parameter is the maximum number of characters the
      field will accept (-maxlength).

=back

As with all these methods, the field will be initialized with its 
previous contents from earlier invocations of the script.
When the form is processed, the value of the text field can be
retrieved with:

       $value = $query->param('foo');

If you want to reset it from its initial value after the script has been
called once, you can do so like this:

       $query->param('foo',"I'm taking over this value!");

=head2 CREATING A BIG TEXT FIELD

   print $query->textarea(-name=>'foo',
	 		  -default=>'starting value',
	                  -rows=>10,
	                  -columns=>50);

	-or

   print $query->textarea('foo','starting value',10,50);

textarea() is just like textfield, but it allows you to specify
rows and columns for a multiline text entry box.  You can provide
a starting value for the field, which can be long and contain
multiple lines.

=head2 CREATING A PASSWORD FIELD

   print $query->password_field(-name=>'secret',
				-value=>'starting value',
				-size=>50,
				-maxlength=>80);
	-or-

   print $query->password_field('secret','starting value',50,80);

password_field() is identical to textfield(), except that its contents 
will be starred out on the web page.

=head2 CREATING A FILE UPLOAD FIELD

    print $query->filefield(-name=>'uploaded_file',
	                    -default=>'starting value',
	                    -size=>50,
	 		    -maxlength=>80);
	-or-

    print $query->filefield('uploaded_file','starting value',50,80);

filefield() will return a file upload field for Netscape 2.0 browsers.
In order to take full advantage of this I<you must use the new 
multipart encoding scheme> for the form.  You can do this either
by calling B<startform()> with an encoding type of B<$CGI::MULTIPART>,
or by calling the new method B<start_multipart_form()> instead of
vanilla B<startform()>.

=over 4

=item B<Parameters>

=item 1.

The first parameter is the required name for the field (-name).  

=item 2.

The optional second parameter is the starting value for the field contents
to be used as the default file name (-default).

The beta2 version of Netscape 2.0 currently doesn't pay any attention
to this field, and so the starting value will always be blank.  Worse,
the field loses its "sticky" behavior and forgets its previous
contents.  The starting value field is called for in the HTML
specification, however, and possibly later versions of Netscape will
honor it.

=item 3.

The optional third parameter is the size of the field in
characters (-size).

=item 4.

The optional fourth parameter is the maximum number of characters the
field will accept (-maxlength).

=back

When the form is processed, you can retrieve the entered filename
by calling param().

       $filename = $query->param('uploaded_file');

In Netscape Beta 1, the filename that gets returned is the full local filename
on the B<remote user's> machine.  If the remote user is on a Unix
machine, the filename will follow Unix conventions:

	/path/to/the/file

On an MS-DOS/Windows machine, the filename will follow DOS conventions:

	C:\PATH\TO\THE\FILE.MSW

On a Macintosh machine, the filename will follow Mac conventions:

	HD 40:Desktop Folder:Sort Through:Reminders

In Netscape Beta 2, only the last part of the file path (the filename
itself) is returned.  I don't know what the release behavior will be.

The filename returned is also a file handle.  You can read the contents
of the file using standard Perl file reading calls:

	# Read a text file and print it out
	while (<$filename>) {
	   print;
        }

        # Copy a binary file to somewhere safe
        open (OUTFILE,">>/usr/local/web/users/feedback");
	while ($bytesread=read($filename,$buffer,1024)) {
	   print OUTFILE $buffer;
        }

=head2 CREATING A POPUP MENU

   print $query->popup_menu('menu_name',
                            ['eenie','meenie','minie'],
                            'meenie');

      -or-

   %labels = ('eenie'=>'your first choice',
              'meenie'=>'your second choice',
              'minie'=>'your third choice');
   print $query->popup_menu('menu_name',
                            ['eenie','meenie','minie'],
                            'meenie',\%labels);

	-or (named parameter style)-

   print $query->popup_menu(-name=>'menu_name',
			    -values=>['eenie','meenie','minie'],
	                    -default=>'meenie',
	                    -labels=>\%labels);

popup_menu() creates a menu.

=over 4

=item 1.

The required first argument is the menu's name (-name).

=item 2.

The required second argument (-values) is an array B<reference>
containing the list of menu items in the menu.  You can pass the
method an anonymous array, as shown in the example, or a reference to
a named array, such as "\@foo".

=item 3.

The optional third parameter (-default) is the name of the default
menu choice.  If not specified, the first item will be the default.
The values of the previous choice will be maintained across queries.

=item 4.

The optional fourth parameter (-labels) is provided for people who
want to use different values for the user-visible label inside the
popup menu nd the value returned to your script.  It's a pointer to an
associative array relating menu values to user-visible labels.  If you
leave this parameter blank, the menu values will be displayed by
default.  (You can also leave a label undefined if you want to).

=back

When the form is processed, the selected value of the popup menu can
be retrieved using:

      $popup_menu_value = $query->param('menu_name');

=head2 CREATING A SCROLLING LIST

   print $query->scrolling_list('list_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],5,'true');
      -or-

   print $query->scrolling_list('list_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],5,'true',
                                \%labels);

	-or-

   print $query->scrolling_list(-name=>'list_name',
                                -values=>['eenie','meenie','minie','moe'],
                                -default=>['eenie','moe'],
	                        -size=>5,
	                        -multiple=>'true',
                                -labels=>\%labels);

scrolling_list() creates a scrolling list.  

=over 4

=item B<Parameters:>

=item 1.

The first and second arguments are the list name (-name) and values
(-values).  As in the popup menu, the second argument should be an
array reference.

=item 2.

The optional third argument (-default) can be either a reference to a
list containing the values to be selected by default, or can be a
single value to select.  If this argument is missing or undefined,
then nothing is selected when the list first appears.  In the named
parameter version, you can use the synonym "-defaults" for this
parameter.

=item 3.

The optional fourth argument is the size of the list (-size).

=item 4.

The optional fifth argument can be set to true to allow multiple
simultaneous selections (-multiple).  Otherwise only one selection
will be allowed at a time.

=item 5.

The optional sixth argument is a pointer to an associative array
containing long user-visible labels for the list items (-labels).
If not provided, the values will be displayed.

When this form is procesed, all selected list items will be returned as
a list under the parameter name 'list_name'.  The values of the
selected items can be retrieved with:

      @selected = $query->param('list_name');

=back

=head2 CREATING A GROUP OF RELATED CHECKBOXES

   print $query->checkbox_group(-name=>'group_name',
                                -values=>['eenie','meenie','minie','moe'],
                                -default=>['eenie','moe'],
	                        -linebreak=>'true',
	                        -labels=>\%labels);

   print $query->checkbox_group('group_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],'true',\%labels);

   HTML3-COMPATIBLE BROWSERS ONLY:

   print $query->checkbox_group(-name=>'group_name',
                                -values=>['eenie','meenie','minie','moe'],
	                        -rows=2,-columns=>2);
    

checkbox_group() creates a list of checkboxes that are related
by the same name.

=over 4

=item B<Parameters:>

=item 1.

The first and second arguments are the checkbox name and values,
respectively (-name and -values).  As in the popup menu, the second
argument should be an array reference.  These values are used for the
user-readable labels printed next to the checkboxes as well as for the
values passed to your script in the query string.

=item 2.

The optional third argument (-default) can be either a reference to a
list containing the values to be checked by default, or can be a
single value to checked.  If this argument is missing or undefined,
then nothing is selected when the list first appears.

=item 3.

The optional fourth argument (-linebreak) can be set to true to place
line breaks between the checkboxes so that they appear as a vertical
list.  Otherwise, they will be strung together on a horizontal line.

=item 4.

The optional fifth argument is a pointer to an associative array
relating the checkbox values to the user-visible labels that will will
be printed next to them (-labels).  If not provided, the values will
be used as the default.

=item 5.

B<HTML3-compatible browsers> (such as Netscape) can take advantage 
of the optional 
parameters B<-rows>, and B<-columns>.  These parameters cause
checkbox_group() to return an HTML3 compatible table containing
the checkbox group formatted with the specified number of rows
and columns.  You can provide just the -columns parameter if you
wish; checkbox_group will calculate the correct number of rows
for you.

To include row and column headings in the returned table, you
can use the B<-rowheader> and B<-colheader> parameters.  Both
of these accept a pointer to an array of headings to use.
The headings are just decorative.  They don't reorganize the
interpetation of the checkboxes -- they're still a single named
unit.

=back

When the form is processed, all checked boxes will be returned as
a list under the parameter name 'group_name'.  The values of the
"on" checkboxes can be retrieved with:

      @turned_on = $query->param('group_name');

=head2 CREATING A STANDALONE CHECKBOX

    print $query->checkbox(-name=>'checkbox_name',
			   -checked=>'checked',
		           -value=>'ON',
		           -label=>'CLICK ME');

	-or-

    print $query->checkbox('checkbox_name','checked','ON','CLICK ME');

checkbox() is used to create an isolated checkbox that isn't logically
related to any others.

=over 4

=item B<Parameters:>

=item 1.

The first parameter is the required name for the checkbox (-name).  It
will also be used for the user-readable label printed next to the
checkbox.

=item 2.

The optional second parameter (-checked) specifies that the checkbox
is turned on by default.  Synonyms are -selected and -on.

=item 3.

The optional third parameter (-value) specifies the value of the
checkbox when it is checked.  If not provided, the word "on" is
assumed.

=item 4.

The optional fourth parameter (-label) is the user-readable label to
be attached to the checkbox.  If not provided, the checkbox name is
used.

=back

The value of the checkbox can be retrieved using:

    $turned_on = $query->param('checkbox_name');

=head2 CREATING A RADIO BUTTON GROUP

   print $query->radio_group(-name=>'group_name',
			     -values=>['eenie','meenie','minie'],
                             -default=>'meenie',
			     -linebreak=>'true',
			     -labels=>\%labels);

	-or-

   print $query->radio_group('group_name',['eenie','meenie','minie'],
                                          'meenie','true',\%labels);


   HTML3-COMPATIBLE BROWSERS ONLY:

   print $query->checkbox_group(-name=>'group_name',
                                -values=>['eenie','meenie','minie','moe'],
	                        -rows=2,-columns=>2);

radio_group() creates a set of logically-related radio buttons
(turning one member of the group on turns the others off)

=over 4

=item B<Parameters:>

=item 1.

The first argument is the name of the group and is required (-name).

=item 2.

The second argument (-values) is the list of values for the radio
buttons.  The values and the labels that appear on the page are
identical.  Pass an array I<reference> in the second argument, either
using an anonymous array, as shown, or by referencing a named array as
in "\@foo".

=item 3.

The optional third parameter (-default) is the name of the default
button to turn on. If not specified, the first item will be the
default.  You can provide a nonexistent button name, such as "-" to
start up with no buttons selected.

=item 4.

The optional fourth parameter (-linebreak) can be set to 'true' to put
line breaks between the buttons, creating a vertical list.

=item 5.

The optional fifth parameter (-labels) is a pointer to an associative
array relating the radio button values to user-visible labels to be
used in the display.  If not provided, the values themselves are
displayed.

=item 6.

B<HTML3-compatible browsers> (such as Netscape) can take advantage 
of the optional 
parameters B<-rows>, and B<-columns>.  These parameters cause
radio_group() to return an HTML3 compatible table containing
the radio group formatted with the specified number of rows
and columns.  You can provide just the -columns parameter if you
wish; radio_group will calculate the correct number of rows
for you.

To include row and column headings in the returned table, you
can use the B<-rowheader> and B<-colheader> parameters.  Both
of these accept a pointer to an array of headings to use.
The headings are just decorative.  They don't reorganize the
interpetation of the radio buttons -- they're still a single named
unit.

=back

When the form is processed, the selected radio button can
be retrieved using:

      $which_radio_button = $query->param('group_name');

=head2 CREATING A SUBMIT BUTTON 

   print $query->submit(-name=>'button_name',
		        -value=>'value');

	-or-

   print $query->submit('button_name','value');

submit() will create the query submission button.  Every form
should have one of these.

=over 4

=item B<Parameters:>

=item 1.

The first argument (-name) is optional.  You can give the button a
name if you have several submission buttons in your form and you want
to distinguish between them.  The name will also be used as the
user-visible label.  Be aware that a few older browsers don't deal with this correctly and
B<never> send back a value from a button.

=item 2.

The second argument (-value) is also optional.  This gives the button
a value that will be passed to your script in the query string.

=back

You can figure out which button was pressed by using different
values for each one:

     $which_one = $query->param('button_name');


=head2 CREATING A RESET BUTTON

   print $query->reset

reset() creates the "reset" button.  Note that it restores the
form to its value from the last time the script was called, 
NOT necessarily to the defaults.

=head2 CREATING A DEFAULT BUTTON

   print $query->defaults('button_label')

defaults() creates a button that, when invoked, will cause the
form to be completely reset to its defaults, wiping out all the
changes the user ever made.

=head2 CREATING A HIDDEN FIELD

	print $query->hidden(-name=>'hidden_name',
	                     -default=>['value1','value2'...]);

		-or-

	print $query->hidden('hidden_name','value1','value2'...);

hidden() produces a text field that can't be seen by the user.  It
is useful for passing state variable information from one invocation
of the script to the next.

=over 4

=item B<Parameters:>

=item 1.

The first argument is required and specifies the name of this
field (-name).

=item 2.  

The second argument is also required and specifies its value
(-default).  In the named parameter style of calling, you can provide
a single value here or a reference to a whole list

=back

Fetch the value of a hidden field this way:

     $hidden_value = $query->param('hidden_name');

Note, that just like all the other form elements, the value of a
hidden field is "sticky".  If you want to replace a hidden field with
some other values after the script has been called once you'll have to
do it manually:

     $query->param('hidden_name','new','values','here');

=head2 CREATING A CLICKABLE IMAGE BUTTON

     print $query->image_button(-name=>'button_name',
			        -src=>'/source/URL',
			        -align=>'MIDDLE');	

	-or-

     print $query->image_button('button_name','/source/URL','MIDDLE');

image_button() produces a clickable image.  When it's clicked on the
position of the click is returned to your script as "button_name.x"
and "button_name.y", where "button_name" is the name you've assigned
to it.

=over 4

=item B<Parameters:>

=item 1.

The first argument (-name) is required and specifies the name of this
field.

=item 2.

The second argument (-src) is also required and specifies the URL

=item 3.
The third option (-align, optional) is an alignment type, and may be
TOP, BOTTOM or MIDDLE

=back

Fetch the value of the button this way:
     $x = $query->param('button_name.x');
     $y = $query->param('button_name.y');

=head1 DEBUGGING:

If you are running the script
from the command line or in the perl debugger, you can pass the script
a list of keywords or parameter=value pairs on the command line or 
from standard input (you don't have to worry about tricking your
script into reading from environment variables).
You can pass keywords like this:

    your_script.pl keyword1 keyword2 keyword3

or this:

   your_script.pl keyword1+keyword2+keyword3

or this:

    your_script.pl name1=value1 name2=value2

or this:

    your_script.pl name1=value1&name2=value2

or even as newline-delimited parameters on standard input.

When debugging, you can use quotes and backslashes to escape 
characters in the familiar shell manner, letting you place
spaces and other funny characters in your parameter=value
pairs:

   your_script.pl name1='I am a long value' name2=two\ words

=head2 DUMPING OUT ALL THE NAME/VALUE PAIRS

The dump() method produces a string consisting of all the query's
name/value pairs formatted nicely as a nested list.  This is useful
for debugging purposes:

    print $query->dump
    

Produces something that looks like:

    <UL>
    <LI>name1
        <UL>
        <LI>value1
        <LI>value2
        </UL>
    <LI>name2
        <UL>
        <LI>value1
        </UL>
    </UL>

You can pass a value of 'true' to dump() in order to get it to
print the results out as plain text, suitable for incorporating
into a <PRE> section.

As a shortcut, as of version 1.56 you can interpolate the entire 
CGI object into a string and it will be replaced with the
the a nice HTML dump shown above:

    $query=new CGI;
    print "<H2>Current Values</H2> $query\n";

=head1 FETCHING ENVIRONMENT VARIABLES

Some of the more useful environment variables can be fetched
through this interface.  The methods are as follows:

=item B<accept()>

Return a list of MIME types that the remote browser
accepts. If you give this method a single argument
corresponding to a MIME type, as in
$query->accept('text/html'), it will return a
floating point value corresponding to the browser's
preference for this type from 0.0 (don't want) to 1.0.
Glob types (e.g. text/*) in the browser's accept list
are handled correctly.

=item B<user_agent()>

Returns the HTTP_USER_AGENT variable.  If you give
this method a single argument, it will attempt to
pattern match on it, allowing you to do something
like $query->user_agent(netscape);

=item B<path_info()>

Returns additional path information from the script URL.
E.G. fetching /cgi-bin/your_script/additional/stuff will
result in $query->path_info() returning
"additional/stuff".

=item B<path_translated()>

As per path_info() but returns the additional
path information translated into a physical path, e.g.
"/usr/local/etc/httpd/htdocs/additional/stuff".

=item B<remote_host()>

Returns either the remote host name or IP address.
if the former is unavailable.

=item B<script_name()>
Return the script name as a partial URL, for self-refering
scripts.

=item B<referer()>

Return the URL of the page the browser was viewing
prior to fetching your script.  Not available for all
browsers.

=head1 AUTHOR INFORMATION

This code is copyright 1995 by Lincoln Stein and the Whitehead 
Institute for Biomedical Research.  It may be used and modified 
freely.  I request, but do not require, that this credit appear
in the code.

Address bug reports and comments to:
lstein@genome.wi.mit.edu

=head1 CREDITS

Thanks very much to:

=over 4

=item Matt Heffron (heffron@falstaff.css.beckman.com)

=item James Taylor (james.taylor@srs.gov)

=item Scott Anguish <sanguish@digifix.com>

=item Mike Jewell (mlj3u@virginia.edu)

=item Timothy Shimmin (tes@kbs.citri.edu.au)

=item Joergen Haegg (jh@axis.se)

=item Laurent Delfosse (delfosse@csgrad1.cs.wvu.edu)

=item Richard Resnick (applepi1@aol.com)

=item Craig Bishop (csb@barwonwater.vic.gov.au)

=item Tony Curtis (tony@Relay1.Austria.EU.net)

=item Tim Bunce (Tim.Bunce@ig.co.uk)

=item Tom Christiansen (tchrist@convex.com)

=item Andreas Koenig (k@franz.ww.TU-Berlin.DE)

=item ...and many many more...


for suggestions and bug fixes.

=back

=head1 A COMPLETE EXAMPLE OF A SIMPLE FORM-BASED SCRIPT


	#!/usr/local/bin/perl
     
    	use CGI;
 
	$query = new CGI;

 	print $query->header;
 	print $query->start_html("Example CGI.pm Form");
 	print "<H1> Example CGI.pm Form</H1>\n";
 	&print_prompt($query);
 	&do_work($query);
	&print_tail;
 	print $query->end_html;
 
 	sub print_prompt {
     	   my($query) = @_;
 
     	   print $query->startform;
     	   print "<EM>What's your name?</EM><BR>";
     	   print $query->textfield('name');
     	   print $query->checkbox('Not my real name');
 
     	   print "<P><EM>Where can you find English Sparrows?</EM><BR>";
     	   print $query->checkbox_group(
                                 -name=>'Sparrow locations',
 				 -values=>[England,France,Spain,Asia,Hoboken],
			         -linebreak=>'yes',
 				 -defaults=>[England,Asia]);
 
     	   print "<P><EM>How far can they fly?</EM><BR>",
            	$query->radio_group(
			-name=>'how far',
 		        -values=>['10 ft','1 mile','10 miles','real far'],
 		        -default=>'1 mile');
 
     	   print "<P><EM>What's your favorite color?</EM>  ";
     	   print $query->popup_menu(-name=>'Color',
				    -values=>['black','brown','red','yellow'],
				    -default=>'red');
 
     	   print $query->hidden('Reference','Monty Python and the Holy Grail');
 
     	   print "<P><EM>What have you got there?</EM><BR>";
     	   print $query->scrolling_list(
			 -name=>'possessions',
 			 -values=>['A Coconut','A Grail','An Icon',
 			           'A Sword','A Ticket'],
 			 -size=>5,
 			 -multiple=>'true');
 
     	   print "<P><EM>Any parting comments?</EM><BR>";
     	   print $query->textarea(-name=>'Comments',
		                  -rows=>10,
				  -columns=>50);
 
     	   print "<P>",$query->reset;
     	   print $query->submit('Action','Shout');
     	   print $query->submit('Action','Scream');
     	   print $query->endform;
     	   print "<HR>\n";
 	}
 
 	sub do_work {
     	   my($query) = @_;
     	   my(@values,$key);

     	   print "<H2>Here are the current settings in this form</H2>";

     	   foreach $key ($query->param) {
 	      print "<STRONG>$key</STRONG> -> ";
 	      @values = $query->param($key);
 	      print join(", ",@values),"<BR>\n";
          }
 	}
 
 	sub print_tail {
     	   print <<END;
 	<HR>
 	<ADDRESS>Lincoln D. Stein</ADDRESS><BR>
 	<A HREF="/">Home Page</A>
 	END
 	}

=head1 BUGS

This module has grown large and monolithic.  Furthermore it's doing many
things, such as handling URLs, parsing CGI input, writing HTML, etc., that
should be done in separate modules.  It should be discarded in favor of
the CGI::* modules, but somehow I continue to work on it.

Note that the code is truly contorted in order to avoid spurious
warnings when programs are run with the -w switch.

=head1 SEE ALSO

L<URI::URL>, L<CGI::Request>, L<CGI::MiniSvr>, L<CGI::Base>, L<CGI::Form>

=cut

# ------------------ START OF THE LIBRARY ------------
%OVERLOAD = ('""'=>'as_string');
sub URL_ENCODED {'application/x-www-form-urlencoded'; }
sub MULTIPART { 'multipart/form-data'; }

$CRLF = "\r\n";

# This is a hack to remove yet another spurious WARNING
$CGI::CGI = '';

#### Method: new
# The new routine.  This will check the current environment
# for an existing query string, and initialize itself, if so.
####
sub new {
    my($class,$filehandle) = @_;
    my($IN);
    if ($filehandle) {
	my($package) = caller;
	# force into caller's package if necessary
	$IN = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle"; 
    }
    my $self = {};
    bless $self,$class;
    $self->initialize($IN);
    return $self;
}

#### Method: autoescape
# If you won't to turn off the autoescaping features,
# call this method with undef as the argument
####
sub autoEscape {
    my($self,$escape) = @_;
    $self->{'dontescape'}=!$escape;
}

#### Method: param
# Returns the value(s)of a named parameter.
# If invoked in a list context, returns the
# entire list.  Otherwise returns the first
# member of the list.
# If name is not provided, return a list of all
# the known parameters names available.
# If more than one argument is provided, the
# second and subsequent arguments are used to
# set the value of the parameter.
####
sub param {
    my($self,$name,@values) = @_;
    return $self->all_parameters unless defined($name);

    # If values is provided, then we set it.
    if (@values) {
	$self->add_parameter($name);
	$self->{$name}=[@values];
    }

    return () unless $self->{$name};
    return wantarray ? @{$self->{$name}} : $self->{$name}->[0];
}

#### Method: import
# Import all parameters into the given namespace.
# Assumes namespace 'Q' if not specified
####
sub import_names {
    my($self,$namespace) = @_;
    $namespace = 'Q' unless defined($namespace);
    die "Can't import names into 'main'\n"
	if $namespace eq 'main';
    my($param,@value,$var);
    foreach $param ($self->param) {
	# protect against silly names
	$param=~tr/a-zA-Z0-9_/_/c;
	$var = "${namespace}::$param";
	@value = $self->param($param);
	@{$var} = @value;
	${$var} = $value[$#value];
    }
}
sub import {
    import_names(@_);
}

#### Method: delete
# Deletes the named parameter entirely.
####
sub delete {
    my($self,$name) = @_;
    delete $self->{$name};
    @{$self->{'.parameters'}}=grep($_ ne $name,$self->param());
    return wantarray ? () : undef;
}

#### Method: keywords
# Keywords acts a bit differently.  Calling it in a list context
# returns the list of keywords.  
# Calling it in a scalar context gives you the size of the list.
####
sub keywords {
    my($self,@values) = @_;
    # If values is provided, then we set it.
    $self->{'keywords'}=[@values] if @values;
    my(@result) = @{$self->{'keywords'}};
    @result;
}

#### Method: version
# Return the current version
####
sub version {
    return $VERSION;
}

#### Method: dump
# Returns a string in which all the known parameter/value 
# pairs are represented as nested lists, mainly for the purposes 
# of debugging.
####
sub dump {
    my($self) = @_;
    my($param,$value,@result);
    return '<UL></UL>' unless $self->param;
    push(@result,"<UL>");
    foreach $param ($self->param) {
	my($name)=$self->escapeHTML($param);
	push(@result,"<LI><STRONG>$param</STRONG>");
	push(@result,"<UL>");
	foreach $value ($self->param($param)) {
	    $value = $self->escapeHTML($value);
	    push(@result,"<LI>$value");
	}
	push(@result,"</UL>");
    }
    push(@result,"</UL>\n");
    return join("\n",@result);
}

#### Method as_string
#
# synonym for "dump"
####
sub as_string {
    &dump(@_);
}

#### Method: save
# Write values out to a filehandle in such a way that they can
# be reinitialized by the filehandle form of the new() method
####
sub save {
    my($self,$filehandle) = @_;
    my($param);
    my($package) = caller;
    $filehandle = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle";
    foreach $param ($self->param) {
	my($escaped_param) = &escape($param);
	my($value);
	foreach $value ($self->param($param)) {
	    print $filehandle "$escaped_param=",escape($value),"\n";
	}
    }
}

#### Method: header
# Return a Content-Type: style header
#
####
sub header {
    my $self = shift;

    my($type,$status,@other,%param,$key);
    if (defined($_[0]) && ($self->use_named_parameters || $_[0]=~/^-/)) {
	%param = @_;
	foreach (keys %param) {
	    do {$type = $param{$_}; next; } if /^-?(type|content-type)/i;
	    do {$status = $param{$_}; next; } if /^-?status/i;
	    ($key = $_) =~ s/^-//;
	    push(@other,"$key: $param{$_}");
	}
    } else {
	($type,$status,@other) = @_;
    }

    $type = $type || 'text/html';
    push(@other,"Pragma: no-cache") if $self->cache();
    my(@header);
    push(@header,"Status: $status") if $status;
    push(@header,@other) if @other;
    push(@header,"Content-type: $type");

    my $header = join($CRLF,@header);
    return $header . "${CRLF}${CRLF}";
}

#### Method: cache
# Control whether header() will produce the no-cache
# Pragma directive.
####
sub cache {
    my($self,$new_value) = @_;
    $new_value = '' unless $new_value;
    if ($new_value ne '') {
	$self->{'cache'} = $new_value;
    }
    return $self->{'cache'};
}

#### Method: redirect
# Return a Location: style header
#
####
sub redirect {
    my($self,$url) = @_;
    $url = $url || $self->self_url;
    return join($CRLF,"Status: 302 Found",
		"Location: ${url}",
		"URI: <$url>",
		"Content-type: text/html"). # patches a bug in some servers
		    "${CRLF}${CRLF}";
}

#### Method: start_html
# Canned HTML header
#
# Parameters:
# $title -> (optional) The title for this HTML document
# $author -> (optional) e-mail address of the author
# $base -> (option) if set to true, will enter the BASE address of this document
#          for resolving relative references.
# @other -> (option) any other named parameters you'd like to incorporate into
#           the <BODY> tag.
####
sub start_html {
    my($self,@p) = @_;
    my($title,$author,$base,@other) = 
	$self->rearrange([TITLE,AUTHOR,BASE],@p);

    # strangely enough, the title needs to be escaped as HTML
    # while the author needs to be escaped as a URL
    $title = $self->escapeHTML($title || 'Untitled Document');
    $author = $self->escapeHTML($author);
    my(@result);
    push(@result,"<HTML><HEAD><TITLE>$title</TITLE>");
    push(@result,"<LINK REV=MADE HREF=\"mailto:$author\">") if $author;
    push(@result,"<BASE HREF=\"http://".$self->server_name.":".$self->server_port.$self->script_name."\">") if $base;

    push(@result,"</HEAD><BODY @other>");
    return join("\n",@result);
}

#### Method: end_html
# End an HTML document.
# Trivial method for completeness.  Just returns "</BODY>"
####
sub end_html {
    return "</BODY></HTML>";
}

################################
# METHODS USED IN BUILDING FORMS
################################

#### Method: isindex
# Just prints out the isindex tag.
# Parameters:
#  $action -> optional URL of script to run
# Returns:
#   A string containing a <ISINDEX> tag
sub isindex {
    my($self,@p) = @_;
    my($action,@other) = $self->rearrange([ACTION],@p);
    $action = qq/ACTION="$action"/ if $action;
    return "<ISINDEX $action @other>";
}

#### Method: startform
# Start a form
# Parameters:
#   $method -> optional submission method to use (GET or POST)
#   $action -> optional URL of script to run
#   $enctype ->encoding to use (URL_ENCODED or MULTIPART)
sub startform {
    my($self,@p) = @_;

    my($method,$action,$enctype,@other) = 
	$self->rearrange([METHOD,ACTION,ENCTYPE],@p);

    $method = $method || 'POST';
    $enctype = $enctype || URL_ENCODED;
    $action = $action ? qq/ACTION="$action"/ : '';
    return qq/<FORM METHOD="$method" $action ENCTYPE=$enctype @other>\n/;
}

#### Method: start_form
# synonym for startform
sub start_form {
    &startform(@_);
}

#### Method: start_multipart_form
# synonym for startform
sub start_multipart_form {
    my($self,@p) = @_;
    my($method,$action,$enctype,@other) = 
	$self->rearrange([METHOD,ACTION,ENCTYPE],@p);
    $self->startform($method,$action,$enctype || MULTIPART,@other);
}

#### Method: endform
# End a form
sub endform {
    return "</FORM>\n";
}

#### Method: end_form
# synonym for endform
sub end_form {
    &endform(@_);
}

#### Method: use_named_parameters
# Force CGI.pm to use named parameter-style method calls
# rather than positional parameters.  The same effect
# will happen automatically if the first parameter
# begins with a -.
sub use_named_parameters {
    my($self,$use_named) = @_;
    return $self->{'.named'} unless defined ($use_named);

    # stupidity to avoid annoying warnings
    return $self->{'.named'}=$use_named;
}

#### Method: textfield
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
sub textfield {
    my($self,@p) = @_;
    my($name,$default,$size,$maxlength,@other) = 
	$self->rearrange([NAME,DEFAULT,SIZE,MAXLENGTH],@p);

    my($current) = defined($self->param($name)) ? $self->param($name) : $default;

    $current = $self->escapeHTML($current);
    $name = $self->escapeHTML($name);
    my($s) = defined($size) ? qq/SIZE=$size/ : '';
    my($m) = defined($maxlength) ? qq/MAXLENGTH=$maxlength/ : '';
    return qq/<INPUT TYPE="text" NAME="$name" VALUE="$current" $s $m @other>/;
}

#### Method: filefield
# Parameters:
#   $name -> Name of the file upload field
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
sub filefield {
    my($self,@p) = @_;

    my($name,$default,$size,$maxlength,@other) = 
	$self->rearrange([NAME,DEFAULT,SIZE,MAXLENGTH],@p);

    my($current,$default) = ('','');
    $current = defined($self->param($name)) ? $self->param($name) : $default;
    $name = $self->escapeHTML($name);
    my($s) = defined($size) ? qq/SIZE=$size/ : '';
    my($m) = defined($maxlength) ? qq/MAXLENGTH=$maxlength/ : '';
    return qq/<INPUT TYPE="file" NAME="$name" VALUE="$current" $s $m @other>/;
}

#### Method: password
# Create a "secret password" entry field
# Parameters:
#   $name -> Name of the field
#   $default -> Optional default value of the field if not
#                already defined.
#   $size ->  Optional width of field in characters.
#   $maxlength -> Optional maximum characters that can be entered.
# Returns:
#   A string containing a <INPUT TYPE="password"> field
#
sub password_field {
    my ($self,@p) = @_;

    my($name,$default,$size,$maxlength,@other) = 
	$self->rearrange([NAME,DEFAULT,SIZE,MAXLENGTH],@p);

    my($current) =  defined($self->param($name)) ? $self->param($name) : $default;
    $name=$self->escapeHTML($name);
    $current=$self->escapeHTML($current);
    my($s) = defined($size) ? qq/SIZE=$size/ : '';
    my($m) = defined($maxlength) ? qq/MAXLENGTH=$maxlength/ : '';
    return qq/<INPUT TYPE="password" NAME="$name" VALUE="$current" $s $m @other>/;
}

#### Method: textarea
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $rows ->  Optional number of rows in text area
#   $columns -> Optional number of columns in text area
# Returns:
#   A string containing a <TEXTAREA></TEXTAREA> tag
#
sub textarea {
    my($self,@p) = @_;
    
    my($name,$default,$rows,$cols,@other) =
	$self->rearrange([NAME,DEFAULT,ROWS,[COLS,COLUMNS]],@p);

    my($current)= defined($self->param($name)) ? $self->param($name) : $default;
    $name=$self->escapeHTML($name);
    $current=$self->escapeHTML($current);
    my($r) = "ROWS=$rows" if $rows;
    my($c) = "COLS=$cols" if $cols;
    return qq{<TEXTAREA NAME="$name" $r $c @other>$current</TEXTAREA>};
}

#### Method: submit
# Create a "submit query" button.
# Parameters:
#   $name ->  (optional) Name for the button.
#   $value -> (optional) Value of the button when selected.
# Returns:
#   A string containing a <INPUT TYPE="submit"> tag
####
sub submit {
    my($self,@p) = @_;

    my($label,$value,@other) = $self->rearrange([NAME,VALUE],@p);

    $label=$self->escapeHTML($label);
    $value=$self->escapeHTML($value);

    my($name) = 'NAME=".submit"';
    $name = qq/NAME="$label"/ if $label;
    $value = $value || $label;
    my($val) = '';
    $val = qq/VALUE="$value"/ if $value;
    return qq/<INPUT TYPE="submit" $name $val @other>/;
}

#### Method: reset
# Create a "reset" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="reset"> tag
####
sub reset {
    my($self,@p) = @_;
    my($label,@other) = $self->rearrange([NAME],@p);
    $label=$self->escapeHTML($label);
    my($value) = $label ? qq/VALUE="$label"/ : '';

    return qq/<INPUT TYPE="reset" $value @other>/;
}

#### Method: defaults
# Create a "defaults" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="submit" NAME=".defaults"> tag
#
# Note: this button has a special meaning to the initialization script,
# and tells it to ERASE the current query string so that your defaults
# are used again!
####
sub defaults {
    my($self,@p) = @_;

    my($label,@other) = $self->rearrange([NAME],@p);

    $label=$self->escapeHTML($label);
    $label = $label || "Defaults";
    my($value) = qq/VALUE="$label"/;
    return qq/<INPUT TYPE="submit" NAME=".defaults" $value @other>/;
}

#### Method: checkbox
# Create a checkbox that is not logically linked to any others.
# The field value is "on" when the button is checked.
# Parameters:
#   $name -> Name of the checkbox
#   $checked -> (optional) turned on by default if true
#   $value -> (optional) value of the checkbox, 'on' by default
#   $label -> (optional) a user-readable label printed next to the box.
#             Otherwise the checkbox name is used.
# Returns:
#   A string containing a <INPUT TYPE="checkbox"> field
####
sub checkbox {
    my($self,@p) = @_;

    my($name,$checked,$value,$label,@other) = 
	$self->rearrange([NAME,[CHECKED,SELECTED,ON],VALUE,LABEL],@p);

    if ($self->inited) {
	$checked = $self->param($name) ? 'CHECKED' : '';
	$value = $self->param($name) || $value || 'on';
    } else {
	$checked = defined($checked) ? 'CHECKED' : '';
	$value = $value || 'on';
    }
    my($the_label) = $label || $name;
    $name = $self->escapeHTML($name);
    $value = $self->escapeHTML($value);
    $the_label = $self->escapeHTML($the_label);
    return <<END;
<INPUT TYPE="checkbox" NAME="$name" VALUE="$value" $checked @other>$the_label
END
}

#### Method: checkbox_group
# Create a list of logically-linked checkboxes.
# Parameters:
#   $name -> Common name for all the check boxes
#   $values -> A pointer to a regular array containing the
#             values for each checkbox in the group.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of checkbox values,
#             then this will be used to decide which
#             checkboxes to turn on by default.
#             2. If a scalar, will be assumed to hold the
#             value of a single checkbox in the group to turn on. 
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing a series of <INPUT TYPE="checkbox"> fields
####
sub checkbox_group {

    my($self,@p) = @_;
    my($name,$values,$defaults,$linebreak,$labels,$rows,$columns,$rowheaders,$colheaders,@other) =
	$self->rearrange([NAME,[VALUES,VALUE],[DEFAULTS,DEFAULT],
			  LINEBREAK,LABELS,ROWS,[COLUMNS,COLS],
			  ROWHEADERS,COLHEADERS],@p);

    my($checked,$break,$result,$label);

    my(%checked) = $self->previous_or_default($name,$defaults);

    $break = $linebreak ? "<BR>" : '';
    $name=$self->escapeHTML($name);

    # Create the elements
    my(@elements);
    foreach (@$values) {
	$checked = $checked{$_} ? 'CHECKED' : '';
	$label = $_;
	$label = $labels->{$_} if defined($labels) && $labels->{$_};
	$label = $self->escapeHTML($label);
	$_ = $self->escapeHTML($_);
	push(@elements,qq/<INPUT TYPE="checkbox" NAME="$name" VALUE="$_" $checked @other>$label $break/);
    }
    return "@elements" unless $columns;
    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}

# Internal procedure - don't use
sub _tableize {
    my($rows,$columns,$rowheaders,$colheaders,@elements) = @_;
    my($result);

    $rows = int(0.99 + @elements/$columns) unless $rows;
    # rearrange into a pretty table
    $result = "<TABLE>";
    my($row,$column);
    unshift(@$colheaders,'') if @$colheaders && @$rowheaders;
    $result .= "<TR><TH>" . join ("<TH>",@{$colheaders}) if @{$colheaders};
    for ($row=0;$row<$rows;$row++) {
	$result .= "<TR>";
	$result .= "<TH>$rowheaders->[$row]" if @$rowheaders;
	for ($column=0;$column<$columns;$column++) {
	    $result .= "<TD>" . $elements[$column*$rows + $row];
	}
    }
    $result .= "</TABLE>";
    return $result;
}

#### Method: radio_group
# Create a list of logically-linked radio buttons.
# Parameters:
#   $name -> Common name for all the buttons.
#   $values -> A pointer to a regular array containing the
#             values for each button in the group.
#   $default -> (optional) Value of the button to turn on by default.  Pass '-'
#               to turn _nothing_ on.
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing a series of <INPUT TYPE="radio"> fields
####
sub radio_group {
    my($self,@p) = @_;

    my($self,@p) = @_;

    my($name,$values,$default,$linebreak,$labels,$rows,$columns,$rowheaders,$colheaders,@other) =
	$self->rearrange([NAME,[VALUES,VALUE],DEFAULT,LINEBREAK,LABELS,
			  ROWS,[COLUMNS,COLS],
			  ROWHEADERS,COLHEADERS],@p);
    my($result,$checked);

    if (defined($self->param($name))) {
	$checked = $self->param($name);
    } else {
	$checked = $default;
    }
    # If no check array is specified, check the first by default
    $checked = $values->[0] unless $checked;
    $name=$self->escapeHTML($name);

    my(@elements);
    foreach (@{$values}) {
	my($checkit) = $checked eq $_ ? 'CHECKED' : '';
	my($break) = $linebreak ? '<BR>' : '';
	my($label) = $_;
	$label = $labels->{$_} if defined($labels) && $labels->{$_};
	$label = $self->escapeHTML($label);
	$_=$self->escapeHTML($_);
	push(@elements,qq/<INPUT TYPE="radio" NAME="$name" VALUE="$_" $checkit @other>$label $break/);
    }
    return "@elements" unless $columns;
    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}

#### Method: popup_menu
# Create a popup menu.
# Parameters:
#   $name -> Name for all the menu
#   $values -> A pointer to a regular array containing the
#             text of each menu item.
#   $default -> (optional) Default item to display
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a popup menu.
####
sub popup_menu {
    my($self,@p) = @_;

    my($name,$values,$default,$labels,@other) =
	$self->rearrange([NAME,[VALUES,VALUE],[DEFAULT,DEFAULTS],LABELS],@p);
    my($result,$selected);

    if (defined($self->param($name))) {
	$selected = $self->param($name);
    } else {
	$selected = $default;
    }

    $name=$self->escapeHTML($name);
    $result = qq/<SELECT NAME="$name" @other>\n/;
    foreach (@{$values}) {
	my($selectit) = defined($selected) ? ($selected eq $_ ? 'SELECTED' : '' ) : '';
	my($label) = $_;
	$label = $labels->{$_} if defined($labels) && $labels->{$_};
	my($value) = $self->escapeHTML($_);
	$label=$self->escapeHTML($label);
	$result .= "<OPTION $selectit VALUE=\"$value\">$label\n";
    }

    $result .= "</SELECT>\n";
    return $result;
}

#### Method: scrolling_list
# Create a scrolling list.
# Parameters:
#   $name -> name for the list
#   $values -> A pointer to a regular array containing the
#             values for each option line in the list.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of options,
#             then this will be used to decide which
#             lines to turn on by default.
#             2. Otherwise holds the value of the single line to turn on.
#   $size -> (optional) Size of the list.
#   $multiple -> (optional) If set, allow multiple selections.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a scrolling list.
####
sub scrolling_list {
    my($self,@p) = @_;
    my($name,$values,$defaults,$size,$multiple,$labels,@other)
	= $self->rearrange([NAME,[VALUES,VALUE],[DEFAULTS,DEFAULT],SIZE,MULTIPLE,LABELS],
			   @p);

    my($result);
    $size = $size || scalar(@{$values});

    my(%selected) = $self->previous_or_default($name,$defaults);

    my($is_multiple) = $multiple ? 'MULTIPLE' : '';
    my($has_size) = $size ? "SIZE=$size" : '';
    $name=$self->escapeHTML($name);
    $result = qq/<SELECT NAME="$name" $has_size $is_multiple @other>\n/;
    foreach (@{$values}) {
	my($selectit) = $selected{$_} ? 'SELECTED' : '';
	my($label) = $_;
	$label = $labels->{$_} if defined($labels) && $labels->{$_};
	$label=$self->escapeHTML($label);
	my($value)=$self->escapeHTML($_);
	$result .= "<OPTION $selectit VALUE=\"$value\">$label\n";
    }
    $result .= "</SELECT>\n";
    return $result;
}

#### Method: hidden
# Parameters:
#   $name -> Name of the hidden field
#   @default -> (optional) Initial values of field (may be an array)
#      or
#   $default->[initial values of field]
# Returns:
#   A string containing a <INPUT TYPE="hidden" NAME="name" VALUE="value">
####
sub hidden {
    my($self,@p) = @_;

    # this is the one place where we departed from our standard
    # calling scheme, so we have to special-case (darn)
    my(@result,@value);
    my($name,$default,@other) = $self->rearrange([NAME,[DEFAULT,VALUE,VALUES]],@p);
    if (!$self->param($name)) {
	if (defined($default) && ref($default) && (ref($default) eq 'ARRAY')) {
	    @value = @{$default};
	} else {
	    @value = ($default,@other);
	}
    } else {
	@value = $self->param($name);
    }

    $name=$self->escapeHTML($name);
    foreach (@value) {
	$_=$self->escapeHTML($_);
	push(@result,qq/<INPUT TYPE="hidden" NAME="$name" VALUE="$_">/);
    }
    return join("\n",@result);
}

#### Method: image_button
# Parameters:
#   $name -> Name of the button
#   $src ->  URL of the image source
#   $align -> Alignment style (TOP, BOTTOM or MIDDLE)
# Returns:
#   A string containing a <INPUT TYPE="image" NAME="name" SRC="url" ALIGN="alignment">
####
sub image_button {
    my($self,@p) = @_;

    my($name,$src,$alignment,@other) =
	$self->rearrange([NAME,SRC,ALIGN],@p);

    my($align) = $alignment ? "ALIGN=\U$alignment" : '';
    $name=$self->escapeHTML($name);
    return qq/<INPUT TYPE="image" NAME="$name" SRC="$src" $align @other>/;
}

#### Method: self_url
# Returns a URL containing the current script and all its
# param/value pairs arranged as a query.  You can use this
# to create a link that, when selected, will reinvoke the
# script with all its state information preserved.
####
sub self_url {
    my($self) = @_;
    my($query_string) = $self->query_string;
    my $name = "http://" . $self->server_name;
    $name .= ":" . $self->server_port
	unless $self->server_port == 80;
    $name .= $self->script_name;
    $name .= $self->path_info if $self->path_info;
    return $name unless $query_string;
    return "$name?$query_string";
}

# This is provided as a synonym to self_url() for people unfortunate
# enough to have incorporated it into their programs already!
sub state {
    &self_url;
}

###############################################
# OTHER INFORMATION PROVIDED BY THE ENVIRONMENT
###############################################

#### Method: path_info
# Return the extra virtual path information provided
# after the URL (if any)
####
sub path_info {
    return $ENV{'PATH_INFO'};
}

#### Method: path_translated
# Return the physical path information provided
# by the URL (if any)
####
sub path_translated {
    return $ENV{'PATH_TRANSLATED'};
}

#### Method: query_string
# Synthesize a query string from our current
# parameters
####
sub query_string {
    my $self = shift;
    my($param,$value,@pairs);
    foreach $param ($self->param) {
	$param = &escape($param);
	foreach $value ($self->param($param)) {
	    $value = &escape($value);
	    push(@pairs,"$param=$value");
	}
    }
    return join("&",@pairs);
}

#### Method: accept
# Without parameters, returns an array of the
# MIME types the browser accepts.
# With a single parameter equal to a MIME
# type, will return undef if the browser won't
# accept it, 1 if the browser accepts it but
# doesn't give a preference, or a floating point
# value between 0.0 and 1.0 if the browser
# declares a quantitative score for it.
# This handles MIME type globs correctly.
####
sub accept {
    my($self,$search) = @_;
    my(%prefs,$type,$pref,$pat);
    
    my(@accept) = split(',',$ENV{'HTTP_ACCEPT'});
    
    foreach (@accept) {
	($pref) = /q=(\d\.\d+|\d+)/;
	($type) = m#(\S+/[^;]+)#;
	next unless $type;
	$prefs{$type}=$pref || 1;
    }

    return keys %prefs unless $search;
    
    # if a search type is provided, we may need to
    # perform a pattern matching operation.
    # The MIME types use a glob mechanism, which
    # is easily translated into a perl pattern match

    # First return the preference for directly supported
    # types:
    return $prefs{$search} if $prefs{$search};

    # Didn't get it, so try pattern matching.
    foreach (keys %prefs) {
	next unless /\*/;	# not a pattern match
	($pat = $_) =~ s/([^\w*])/\\$1/g; # escape meta characters
	$pat =~ s/\*/.*/g; # turn it into a pattern
	return $prefs{$_} if $search=~/$pat/;
    }
}

#### Method: user_agent
# If called with no parameters, returns the user agent.
# If called with one parameter, does a pattern match (case
# insensitive) on the user agent.
####
sub user_agent {
    my($self,$match)=@_;
    return $ENV{'HTTP_USER_AGENT'} unless $match;
    return ($ENV{'HTTP_USER_AGENT'} =~ /$match/i);
}

#### Method: remote_host
# Return the name of the remote host, or its IP
# address if unavailable
####
sub remote_host {
    return $ENV{'REMOTE_HOST'} || $ENV{'REMOTE_ADDR'} 
    || 'dummy.remote.host';
}

#### Method: remote_addr
# Return the IP addr of the remote host.
####
sub remote_addr {
    return $ENV{'REMOTE_ADDR'} || '127.0.0.1';
}

#### Method: script_name
# Return the partial URL to this script for
# self-referencing scripts.  Also see
# self_url(), which returns a URL with all state information
# preserved.
####
sub script_name {
    return $ENV{'SCRIPT_NAME'} if $ENV{'SCRIPT_NAME'};
    # These are for debugging
    return "/$0" unless $0=~/^\//;
    return $0;
}

#### Method: referer
# Return the HTTP_REFERER: useful for generating
# a GO BACK button.
####
sub referer {
    return $ENV{'HTTP_REFERER'};
}

#### Method: server_name
# Return the name of the server
####
sub server_name {
    return $ENV{'SERVER_NAME'} || 'dummy.host.name';
}

#### Method: server_port
# Return the tcp/ip port the server is running on
####
sub server_port {
    return $ENV{'SERVER_PORT'} || 80; # for debugging
}

#### Method: remote_ident
# Return the identity of the remote user
# (but only if his host is running identd)
####
sub remote_ident {
    return $ENV{'REMOTE_IDENT'};
}

#### Method: auth_type
# Return the type of use verification/authorization in use, if any.
####
sub auth_type {
    return $ENV{'AUTH_TYPE'};
}

#### Method: remote_user
# Return the authorization name used for user
# verification.
####
sub remote_user {
    return $ENV{'REMOTE_USER'};
}

########################################
# THESE METHODS ARE MORE OR LESS PRIVATE
########################################

# Initialize the query object from the environment.
# If a parameter list is found, this object will be set
# to an associative array in which parameter names are keys
# and the values are stored as lists
# If a keyword list is found, this method creates a bogus
# parameter list with the single parameter 'keywords'.
sub initialize {
    my($self,$filehandle) = @_;
    my($query_string,@lines);
    my($meth) = '';

    # if we get called more than once, we want to initialize
    # ourselves from the original query (which may be gone
    # if it was read from STDIN originally.)
    if (defined(@QUERY_PARAM) && !$filehandle) {

	$self->{'.init'}++;	# flag we've been inited
	foreach (@QUERY_PARAM) {
	    $self->add_parameter($_);
	    $self->{$_}=$QUERY_PARAM{$_};
	}
	return;

    } else {

	$meth=$ENV{'REQUEST_METHOD'} if defined($ENV{'REQUEST_METHOD'});

	# If filehandle is defined, then read parameters
	# from it.
	if ($filehandle) {
	    chomp(@lines = <$filehandle>);
	    # massage back into standard format
	    if ("@lines" =~ /=/) {
		$query_string=join("&",@lines);
	    } else {
		$query_string=join("+",@lines);
	    }	
    
	    # If method is GET or HEAD, fetch the query from
	    # the environment.

	} elsif ($meth=~/^(GET|HEAD)$/) {

	    $query_string = $ENV{'QUERY_STRING'};

	    # If the method is POST, fetch the query from standard
	    # input.

	} elsif ($meth eq 'POST') {

	    if ($ENV{'CONTENT_TYPE'}=~m|^multipart/form-data|) {
		my($boundary) = $ENV{'CONTENT_TYPE'}=~/boundary=(\S+)/;
		$self->read_multipart($boundary,$ENV{'CONTENT_LENGTH'});
	    } else {
		$query_string ='';	# hack to avoid 'uninitialized variable' warnings
		read(STDIN,$query_string,$ENV{'CONTENT_LENGTH'}) 
		    if $ENV{'CONTENT_LENGTH'} > 0;
	    }

	    # If neither is set, assume we're being debugged offline.
	    # Check the command line and then the standard input for data.
	    # We use the shellwords package in order to behave the way that
	    # UN*X programmers expect.
	} else {
	    require "shellwords.pl";
	    my($input,@words);

	    if (@ARGV) {
		$input = join(" ",@ARGV);
	    } else {
		warn "(waiting for standard input)\n";
		chomp(@lines = <>); # remove newlines
		$input = join(" ",@lines);
	    }

	    # minimal handling of escape characters
	    $input=~s/\\=/%3D/g;
	    $input=~s/\\&/%26/g;

	    @words = &shellwords($input);
	    if ("@words"=~/=/) {
		$query_string = join('&',@words);
	    } else {
		$query_string = join('+',@words);
	    }
	}
    }
    

    # We now have the query string in hand.  We do slightly
    # different things for keyword lists and parameter lists.
    if ($query_string) {
	if ($query_string =~ /=/) {
	    $self->parse_params($query_string);
	} else {
	    $self->add_parameter('keywords');
	    $self->{'keywords'} = [$self->parse_keywordlist($query_string)];
	}
    }

    # Special case.  Erase everything if there is a field named
    # .defaults.
    if ($self->param('.defaults')) {
	undef %{$self};
    }
    
    # flag that we've been inited
    $self->{'.init'}++ if $self->param;

    # Clear out our default submission button flag if present
    $self->delete('.submit');

    $self->save_request;
}


sub save_request {
    my($self) = @_;
    # We're going to play with the package globals now so that if we get called
    # again, we initialize ourselves in exactly the same way.  This allows
    # us to have several of these objects.
    @QUERY_PARAM = $self->param; # save list of parameters
    foreach (@QUERY_PARAM) {
	$QUERY_PARAM{$_}=$self->{$_};
    }
    
}

# Return true if we've been initialized with a query
# string.
sub inited {
    my($self) = shift;
    return $self->{'.init'};
}

sub unescape {
    my($todecode) = @_;
    $todecode =~ tr/+/ /;	# pluses become spaces
    $todecode =~ s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
    return $todecode;
}

# Escape binary data.
sub escape {
    my($toencode) = @_;
    $toencode=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
    return $toencode;
}

# Escape HTML -- used internally
sub escapeHTML {
    my($self,$toencode) = @_;
    return undef unless defined($toencode);
    return $toencode if $self->{'dontescape'};
    $toencode=~s/&/&amp;/g;
    $toencode=~s/\"/&quot;/g;
    $toencode=~s/>/&gt;/g;
    $toencode=~s/</&lt;/g;
    return $toencode;
}

# -------------- really private subroutines -----------------
sub parse_keywordlist {
    my($self,$tosplit) = @_;
    $tosplit = &unescape($tosplit); # unescape the keywords
    $tosplit=~tr/+/ /;		# pluses to spaces
    my(@keywords) = split(/\s+/,$tosplit);
    return @keywords;
}

sub parse_params {
    my($self,$tosplit) = @_;
    my(@pairs) = split('&',$tosplit);
    my($param,$value);
    foreach (@pairs) {
	($param,$value) = split('=');
	$param = &unescape($param);
	$value = &unescape($value);
	$self->add_parameter($param);
	push (@{$self->{$param}},$value);
    }
}

sub add_parameter {
    my($self,$param)=@_;
    push (@{$self->{'.parameters'}},$param) 
	unless defined($self->{$param});
}

sub all_parameters {
    my $self = shift;
    return () unless defined($self) && $self->{'.parameters'};
    return () unless @{$self->{'.parameters'}};
    return @{$self->{'.parameters'}};
}

sub previous_or_default {
    my($self,$name,$defaults) = @_;
    my(%selected);

    if ($self->inited) {
	grep($selected{$_}++,$self->param($name));
    } elsif (defined($defaults) && ref($defaults) && 
	     (ref($defaults) eq 'ARRAY')) {
	grep($selected{$_}++,@{$defaults});
    } else {
	$selected{$defaults}++ if defined($defaults);
    }

    return %selected;
}

# Smart rearrangement of parameters to allow named parameter
# calling.  We do the rearangement if:
# 1. The first parameter begins with a -
# 2. The use_named_parameters() method returns true
sub rearrange {
    my($self,$order,@param) = @_;
    return ('') x $#$order unless @param;
    return @param unless $param[0]=~/^-/ 
	|| $self->use_named_parameters;

    my $i;
    for ($i=0;$i<@param;$i+=2) {
	$param[$i]=~s/^\-//;     # get rid of initial - if present
	$param[$i]=~tr/a-z/A-Z/; # parameters are upper case
    }
    
    my(%param) = @param;		# convert into associative array
    my(@return_array);
    
    my($key);
    foreach $key (@$order) {
	my($value);
	# this is an awful hack to fix spurious warnings when the
	# -w switch is set.
	if (ref($key) && ref($key) eq 'ARRAY') {
	    foreach (@$key) {
		$value = $param{$_} unless $value;
		delete $param{$_};
	    }
	} else {
	    $value = $param{$key};
	}
	delete $param{$key};
	push(@return_array,$value);
    }

    return (@return_array,$self->make_attributes(%param));
}

sub make_attributes {
    my($self,%att) = @_;
    return () unless %att;
    my(@att);
    foreach (keys %att) {
	push(@att,qq/$_="$att{$_}"/);
    }
    return @att;
}

############ SUPPORT ROUTINES FOR THE NEW MULTIPART ENCODING ##########
package MultipartBuffer;

# how many bytes to read at a time.  We use
# a 5K buffer by default.
$FILLUNIT = 1024 * 5;		
$CRLF=$CGI::CRLF;

sub new {
    my($package,$boundary,$length,$filehandle) = @_;
    my $IN;
    if ($filehandle) {
	my($package) = caller;
	# force into caller's package if necessary
	$IN = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle"; 
    }
    $IN = "main::STDIN" unless $IN;
    my $self = {LENGTH=>$length,
		BOUNDARY=>$boundary,
		IN=>$IN,
		BUFFER=>'',
	    };

    $FILLUNIT 
	= length($boundary) if length($boundary) > $FILLUNIT;
    my($null)='';

    # remove the topmost boundary line so that our
    # first read begins with data.
    read($IN,$null,length($boundary)+2);
    $self->{LENGTH}-=(length($boundary)+2);

    return bless $self,$package;
}

# This reads and returns the header as an associative array.
# It looks for the pattern CRLF/CRLF to terminate the header.
sub readHeader {
    my($self) = @_;
    my($end);
    do {
	$self->fillBuffer($FILLUNIT);
    } until
	(($end = index($self->{BUFFER},
		       "${CRLF}${CRLF}")) >= 0)
	    || ($self->{BUFFER} eq '');
    my($header) = substr($self->{BUFFER},0,$end+2);
    substr($self->{BUFFER},0,$end+4) = '';
    my %return;
    while ($header=~/^([\w-]+): (.*)$CRLF/mog) {
	$return{$1}=$2;
    }
    return %return;
}

# This reads and returns the body as a single scalar value.
sub readBody {
    my($self) = @_;
    my($data,$returnval);
    while ($data = $self->read) {
	$returnval .= $data;
    }
    return $returnval;
}

# This will read $bytes or until the boundary is hit, whichever happens
# first.  After the boundary is hit, we return undef.  The next read will
# skip over the boundary and begin reading again;
sub read {
    my($self,$bytes) = @_;
    # default number of bytes to read
    $bytes = $bytes || $FILLUNIT;	

    # Fill up our internal buffer in such a way that the boundary
    # is never split between reads.
    $self->fillBuffer($bytes);

    # Find the boundary in the buffer (it may not be there).
    my $start = index($self->{BUFFER},$self->{BOUNDARY});

    # If the boundary begins the data, then skip past it
    # and return undef.  The +2 here is a fiendish plot to
    # remove the CR/LF pair at the end of the boundary.
    # the boundary.
    if ($start == 0) {

	# clear us out completely if we've hit the last boundary.
	if (index($self->{BUFFER},"$self->{BOUNDARY}--")==0) {
	    $self->{BUFFER}='';
	    $self->{LENGTH}=0;
	    return undef;
	}

	# just remove the boundary.
	substr($self->{BUFFER},0,length($self->{BOUNDARY})+2)='';
	return undef;
    }

    my $bytesToReturn;    
    if ($start > 0) {		# read up to the boundary
	$bytesToReturn = $start > $bytes ? $bytes : $start;
    } else {			# read the requested number of bytes
	$bytesToReturn = $bytes;
    }

    my $returnval=substr($self->{BUFFER},0,$bytesToReturn);
    substr($self->{BUFFER},0,$bytesToReturn)='';
    
    # If we hit the boundary, then remove the extra CRLF/CRLF from
    # the end (I think this is a Netscape bug, but who knows?)
    return ($start > 0) ? substr($returnval,0,-4) : $returnval;
}

# This fills up our internal buffer in such a way that the
# boundary is never split between reads
sub fillBuffer {
    my($self,$bytes) = @_;
    my($boundaryLength) = length($self->{BOUNDARY});
    my($bufferLength) = length($self->{BUFFER});
    my($bytesToRead) = $bytes - $bufferLength + $boundaryLength + 2;
    $bytesToRead = $self->{LENGTH} if $self->{LENGTH} < $bytesToRead;
    my $bytesRead = read($self->{IN},$self->{BUFFER},$bytesToRead,$bufferLength);
    $self->{LENGTH} -= $bytesRead;
}

# Return true when we've finished reading
sub eof {
    my($self) = @_;
    return 1 if (length($self->{BUFFER}) == 0)
		 && ($self->{LENGTH} <= 0);
}

package TempFile;

@TEMP=('/usr/tmp','/var/tmp','/tmp',);
foreach (@TEMP) {
    do {$TMPDIRECTORY = $_; last} if -w $_;
}
$TMPDIRECTORY  = "." unless $TMPDIRECTORY;
$SEQUENCE="CGItemp$$0000";

%OVERLOAD = ('""'=>'as_string');

# Create a temporary file that will be automatically
# unlinked when finished.
sub new {
    my($package) = @_;
    $SEQUENCE++;
    my $directory = "$TMPDIRECTORY/$SEQUENCE";
    return bless \$directory;
}

sub DESTROY {
    my($self) = @_;
    unlink $$self;		# get rid of the file
}

sub as_string {
    my($self) = @_;
    return $$self;
}

package CGI;

#####
# subroutine: read_multipart
#
# Read multipart data and store it into our parameters.
# An interesting feature is that if any of the parts is a file, we
# create a temporary file and open up a filehandle on it so that the
# caller can read from it if necessary.
#####
sub read_multipart {
    my($self,$boundary,$length) = @_;
    my($buffer) = new MultipartBuffer($boundary,$length);
    my(%header,$body);
    while (!$buffer->eof) {
	%header = $buffer->readHeader;
	# In beta1 it was "Content-disposition".  In beta2 it's "Content-Disposition"
	# Sheesh.
	my($key) = $header{'Content-disposition'} ? 'Content-disposition' : 'Content-Disposition';
	my($param) = $header{$key}=~/ name="(.*?)"/;
	my($filename) = $header{$key}=~/ filename="(.*?)"/;

	# add this parameter to our list
	$self->add_parameter($param);

	# If no filename specified, then just read the data and assign it
	# to our parameter list.
	unless ($filename) {
	    my($value) = $buffer->readBody;
	    push(@{$self->{$param}},$value);
	    next;
	}

	# If we get here, then we are dealing with a potentially large
	# uploaded form.  Save the data to a temporary file, then open
	# the file for reading.
	my($tmpfile) = new TempFile;
	open (OUT,">$tmpfile") || die "CGI open of $tmpfile: $!\n";
	chmod 0666,$tmpfile;	# make sure anyone can delete it.
	my $data;
	while ($data = $buffer->read) {
	    print OUT $data;
	}
	close OUT;

	# Now create a new filehandle in the caller's namespace.
	# The name of this filehandle just happens to be identical
	# to the original filename (NOT the name of the temporary
	# file, which is hidden!)
	my($frame)=1;
	my($cp);
	do {
	    $cp = caller($frame++);
	} until $cp!~/^CGI/;
	my($filehandle) = "$cp\:\:$filename";
	open($filehandle,$tmpfile) || die "CGI open of $tmpfile: $!\n";
	push(@{$self->{$param}},$filename);

	# Under Unix, it would be safe to let the temporary file
	# be deleted immediately.  However, I fear that other operating
	# systems are not so forgiving.  Therefore we save a reference
	# to the temporary file in the CGI object so that the file
	# isn't unlinked until the CGI object itself goes out of
	# scope.  This is a bit hacky.
	$self->{"$tmpfile"}=$tmpfile;

    }

}

1; # so that require() returns true


