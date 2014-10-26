package CGI::Session;

# $Id: Session.pm,v 1.18 2002/11/22 22:57:56 sherzodr Exp $

use strict;
#use diagnostics;
use Carp ('confess', 'croak')   ;
use AutoLoader 'AUTOLOAD';

use vars qw($VERSION $errstr $IP_MATCH $NAME $API_3);

($VERSION)  = '$Revision: 1.18 $' =~ m/Revision:\s*(\S+)/;
$NAME     = 'CGISESSID';

# import() - we do not import anything into the callers namespace, however, 
# we enable the user to specify hooks at compile time
sub import {
    my $class = shift;
    @_ or return;
    for ( my $i=0; $i < @_; $i++ ) {
        $IP_MATCH   = ( $_[$i] eq '-ip_match'   ) and next;        
        $API_3      = ( $_[$i] eq '-api3'       ) and next;
    }
}


# Session _STATUS flags
sub SYNCED   () { 0 }
sub MODIFIED () { 1 }
sub DELETED  () { 2 }


# new() - constructor.
# Returns respective driver object
sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $self = {
        _OPTIONS    => [ @_ ],
        _DATA       => undef,
        _STATUS     => MODIFIED,
        _API3       => { },
    };

    if ( $API_3 ) {
        return $class->api_3(@_);
    }

    bless ($self, $class);
    $self->_validate_driver() && $self->_init() or return;
    return $self;
}










sub api_3 {
    my $class = shift;
    $class = ref($class) || $class;


    my $self = {
        _OPTIONS    => [ $_[1], $_[2] ], # for now settle for empty option
        _DATA       => undef,
        _STATUS     => MODIFIED,
        _API_3      => {
            DRIVER      => 'File',
            SERIALIZER  => 'Default',
            ID          => 'MD5',
        }
    };
    
    if ( defined $_[0] ) {
        my @arg_pairs = split (/;/, $_[0]);        
        for my $arg ( @arg_pairs ) {
            my ($key, $value) = split (/:/, $arg) or next;
            $self->{_API_3}->{ uc($key) } = $value || $self->{_API_3}->{uc($key)};            
        }
    }
    
    my $driver = "CGI::Session::$self->{_API_3}->{DRIVER}";
    eval "require $driver" or die $@;
    
    my $serializer = "CGI::Session::Serialize::$self->{_API_3}->{SERIALIZER}";
    eval "require $serializer" or die $@;

    my $id = "CGI::Session::ID::$self->{_API_3}->{ID}";
    eval "require $id" or die $@;


    # Now re-defining ISA according to what we have above
    {
        no strict 'refs';
        @{$driver . "::ISA"} = ( 'CGI::Session', $serializer, $id );
    }
    
    bless ($self, $driver);
    $self->_validate_driver() && $self->_init() or return;
    return $self;    
}



# DESTROY() - destructor.
# Flushes the memory, and calls driver's teardown()
sub DESTROY {
    my $self = shift;

    $self->flush();
    $self->can('teardown') && $self->teardown();
}



# _validate_driver() - checks driver's validity.
# Return value doesn't matter. If the driver doesn't seem
# to be valid, it croaks
sub _validate_driver {
    my $self = shift;

    my @required = qw(store retrieve remove generate_id);

    for my $method ( @required ) {
        unless ( $self->can($method) ) {
            my $class = ref($self);
            confess "$class doesn't seem to be a valid CGI::Session driver. " .
                "At least one method('$method') is missing";
        }
    }
    return 1;
}




# _init() - object initialializer.
# Decides between _init_old_session() and _init_new_session()
sub _init {
    my $self = shift;

    my $claimed_id = undef;
    my $arg = $self->{_OPTIONS}->[0];
    if ( defined ($arg) && ref($arg) ) {
        if ( $arg->isa('CGI') ) {
            $claimed_id = $arg->cookie($NAME) || $arg->param($NAME) || undef;
            $self->{_SESSION_OBJ} = $arg;
        } elsif ( ref($arg) eq 'CODE' ) {
            $claimed_id = $arg->() || undef;

        }
    } else {
        $claimed_id = $arg;
    }

    if ( defined $claimed_id ) {
        my $rv = $self->_init_old_session($claimed_id);

        unless ( $rv ) {
            return $self->_init_new_session();
        }
        return 1;
    }
    return $self->_init_new_session();
}




# _init_old_session() - tries to retieve the old session.
# If suceeds, checks if the session is expirable. If so, deletes it
# and returns undef so that _init() creates a new session.
# Otherwise, checks if there're any parameters to be expired, and
# calls clear() if any. Aftewards, updates atime of the session, and
# returns true
sub _init_old_session {
    my ($self, $claimed_id) = @_;

    my $options = $self->{_OPTIONS} || [];
    my $data = $self->retrieve($claimed_id, $options);

    # Session was initialized successfully
    if ( defined $data ) {

        $self->{_DATA} = $data;

        # Check if the IP of the initial session owner should
        # match with the current user's IP
        if ( $IP_MATCH ) {
            unless ( $self->_ip_matches() ) {
                $self->delete();
                $self->flush();
                return undef;
            }
        }

        # Check if the session's expiration ticker is up
        if ( $self->_is_expired() ) {
            $self->delete();
            $self->flush();
            return undef;
        }

        # Expring single parameters, if any
        $self->_expire_params();

        # Updating last access time for the session
        $self->{_DATA}->{_SESSION_ATIME} = time();

        # Marking the session as modified
        $self->{_STATUS} = MODIFIED;

        return 1;
    }
    return undef;
}





sub _ip_matches {
    return ( $_[0]->{_DATA}->{_SESSION_REMOTE_ADDR} eq $ENV{REMOTE_ADDR} );
}





# _is_expired() - returns true if the session is to be expired.
# Called from _init_old_session() method.
sub _is_expired {
    my $self = shift;

    unless ( $self->expire() ) {
        return undef;
    }

    return ( time() >= ($self->expire() + $self->atime() ) );
}





# _expire_params() - expires individual params. Called from within
# _init_old_session() method on a sucessfully retrieved session
sub _expire_params {
    my $self = shift;

    # Expiring
    my $exp_list = $self->{_DATA}->{_SESSION_EXPIRE_LIST} || {};
    my @trash_can = ();
    while ( my ($param, $etime) = each %{$exp_list} ) {
        if ( time() >= ($self->atime() + $etime) ) {
            push @trash_can, $param;
        }
    }

    if ( @trash_can ) {
        $self->clear(\@trash_can);
    }
}





# _init_new_session() - initializes a new session
sub _init_new_session {
    my $self = shift;

    $self->{_DATA} = {
        _SESSION_ID => $self->generate_id($self->{_OPTIONS}),
        _SESSION_CTIME => time(),
        _SESSION_ATIME => time(),
        _SESSION_ETIME => undef,
        _SESSION_REMOTE_ADDR => $ENV{REMOTE_ADDR} || undef,
        _SESSION_EXPIRE_LIST => { },
    };

    $self->{_STATUS} = MODIFIED;

    return 1;
}




# id() - accessor method. Returns effective id
# for the current session. CGI::Session deals with
# two kinds of ids; effective and claimed. Claimed id
# is the one passed to the constructor - new() as the first
# argument. It doesn't mean that id() method returns that
# particular id, since that ID might be either expired,
# or even invalid, or just data associated with that id
# might not be available for some reason. In this case,
# claimed id and effective id are not the same.
sub id {
    my $self = shift;

    return $self->{_DATA}->{_SESSION_ID};
}



# param() - accessor method. Reads and writes
# session parameters ( $self->{_DATA} ). Decides
# between _get_param() and _set_param() accordingly.
sub param {
    my $self = shift;


    unless ( defined $_[0] ) {
        return keys %{ $self->{_DATA} };
    }

    if ( @_ == 1 ) {
        return $self->_get_param(@_);
    }

    # If it has more than one arguments, let's try to figure out
    # what the caller is trying to do, since our tricks are endless ;-)
    my $arg = {
        -name   => undef,
        -value  => undef,
        @_,
    };

    if ( defined($arg->{'-name'}) && defined($arg->{'-value'}) ) {
        return $self->_set_param($arg->{'-name'}, $arg->{'-value'});

    }

    if ( defined $arg->{'-name'} ) {
        return $self->_get_param( $arg->{'-name'} );
    }

    if ( @_ == 2 ) {
        return $self->_set_param(@_);
    }

    unless ( @_ % 2 ) {
        my $n = 0;
        my %args = @_;
        while ( my ($key, $value) = each %args ) {
            $self->_set_param($key, $value) && ++$n;
        }
        return $n;
    }

    confess "param(): something smells fishy here. RTFM!";
}



# _set_param() - sets session parameter to the '_DATA' table
sub _set_param {
    my ($self, $key, $value) = @_;

    if ( $self->{_STATUS} == DELETED ) {
        return;
    }

    # session parameters starting with '_session_' are
    # private to the class
    if ( $key =~ m/^_session_/ ) {
        return undef;
    }

    $self->{_DATA}->{$key} = $value;
    $self->{_STATUS} = MODIFIED;

    return $value;
}




# _get_param() - gets a single parameter from the
# '_DATA' table
sub _get_param {
    my ($self, $key) = @_;

    if ( $self->{_STATUS} == DELETED ) {
        return;
    }

    return $self->{_DATA}->{$key};
}


# flush() - flushes the memory into the disk if necessary.
# Usually called from within DESTROY() or close()
sub flush {
    my $self = shift;

    my $status = $self->{_STATUS};

    if ( $status == MODIFIED ) {
        $self->store($self->id, $self->{_OPTIONS}, $self->{_DATA});
        $self->{_STATUS} = SYNCED;
    }

    if ( $status == DELETED ) {
        return $self->remove($self->id, $self->{_OPTIONS});
    }

    $self->{_STATUS} = SYNCED;

    return 1;
}






# Autoload methods go after =cut, and are processed by the autosplit program.

1;

__END__;


# $Id: Session.pm,v 1.18 2002/11/22 22:57:56 sherzodr Exp $

=pod

=head1 NAME

CGI-Session - persistent storage of complex data in CGI applications

=head1 SYNOPSIS

    # Object initialization:
    # api 2 syntax
    use CGI::Session::File;
    my $session = new CGI::Session::File(undef, {Directory=>'/tmp'});

    # or using api 3 syntax
    use CGI::Session qw/-api3/;
    my $session = new CGI::Session("driver:File", undef, {Directory=>'/tmp'});

    # getting the effective session id:
    my $CGISESSID = $session->id();
        
    # storing data in the session
    $session->param('f_name', 'Sherzod');
    # or
    $session->param(-name=>'l_name', -value=>'Ruzmetov');

    # retrieving data
    my $f_name = $session->param('f_name');
    # or
    my $l_name = $session->param(-name=>'l_name');

    # clearing a certain session parameter
    $session->clear(["_IS_LOGGED_IN"]);

    # expire '_IS_LOGGED_IN' flag after 10 idle minutes:
    $session->expire(_IS_LOGGED_IN => '+10m')

    # expire the session itself after 1 idle hour
    $session->expire('+1h');

    # delete the session for good
    $session->delete();

=head1 WARNING

This is the alpha - test release

=head1 DESCRIPTION

CGI-Session is a Perl5 library that provides an easy, reliable and modular 
session management system across HTTP requests. Persistency is a key feature for 
such applications as shopping carts, login/authentication routines, and 
application that need to carry data accross HTTP requests. CGI::Session 
does that and many more

=head1 TO LEARN MORE

If you want to learn more about the usage of the library and its 
application in the production environment, we can suggest you several 
resources you can take advantage of:

=over 4

=item B<cgi-session mailing list>

To subscribe to the list send an email to 
Cgi-session-request@ultracgis.com with the word "subscribe" in the body 
of the email.

To browse mailing list archives visit 
http://ultracgis.com/mailman/listinfo/cgi-session_ultracgis.com

=item B<SessionCook>

In other words, CGI::Session cook book to get solutions for most of your 
daily problems and challenges. Being developed constantly.

=item B<http://cgi-session.sourceforge.net>

Home of CGI::Session hosted by SourceForge.net. The web site was under 
construction as of Fri, Nov 22, 2002.

=back

=head1 STATE MAINTANANCE OVERVIEW

Since HTTP is a stateless protocol, each subsequent click to a web site 
is treated as brand new by the web server, and the server does not 
relate them with previous visits, and all the state information from the 
previous requests are lost. This will make creating such applications as 
shopping carts, login/authentication routines, secure restricted 
services in the web impossible. So people had to do something against 
this despair situation HTTP was putting us in.

For our rescue come such technologies as HTTP Cookies and QUERY_STRINGs 
that help us save the users' session for a certain period. Since cookies 
and query_strings alone cannot take us too deep into our fantasies [RFC 
2965, Section 5, "Implementation Limitations"], several other 
libraries/technologies have been developed to extend their capabilities 
and promise a more reliable and a more persistent system. CGI::Session 
is one of them.

=head2 COOOKIE

Cookie is a piece of text-information that a web server is entitled to 
place in the user's hard disk, assuming a user agent (i.e.. Web Browser) 
is compatible with the specification. After the cookie being placed, 
user agents are required to send these cookies back to the server as 
part of the HTTP request. This way the server application ( CGI ) will 
have a way of relating previous requests by the same user agent, thus 
overcoming statelessness of HTTP.

Although cookies seem to be promising solutions for the statelessness of 
HTTP, they do carry certain limitations, such as limited number of 
cookies per domain and per user agent and limited size on each cookie. 
User Agents are required to store at least 300 cookies at a time, 20 
cookies per domain and allow 4096 bytes of storage for each cookie. They 
also arise several Privacy and Security concerns, the lists of which can 
be found on the sections 6-"Privacy"  and 7-"Security Considerations" of 
RFC 2965 respectively.

=head2 QUERY_STRING

QUERY_STRING is a string appended to URL following a question mark (?) 
such as:

    http://my.dot.com/login.cgi?user=sherzodr;password=topSecret

As you probably guessed already, it can also help you to pass state 
information from a click to another, but how secure is it do you think? 
Considering these URLs tend to get cached by most of the user agents and 
also logged in the servers access log, to which everyone can have access 
to, it is not secure.

=head2 HIDDEN FIELDS

Hidden field is another alternative to using QUERY_STRINGs and they come 
in two flavors: hidden fields used in POST methods and the ones in GET 
methods. The ones used in GET methods will turn into a true QUERY_STRING 
once submitted, so all the disadvantages of QUERY_STRINGs do apply. 
Although POST requests do not have limitations of its sister-GET, they 
become unwieldily when one has oodles of state information to keep track 
of ( for instance, a shopping cart ). Hidden fields also get lost once 
the user agent closes the session or when the user chooses to click on 
the "Back" button of the browser. Considering the information being sent 
back and forth between the server and the user, the probability of bad 
guys intercepting the request hence a private data is higher.

=head2 SERVER SIDE SESSION MANAGEMENT

This technique is built upon the aforementioned technologies plus a 
server-side storage, which saves the state data for a particular 
session. Each session has a unique id associated with the data in the 
server. This id is also associated with the user agent in either the 
form of a cookie, a query_string parameter, a hidden field or all at the 
same time. 

Advantages:

=over 4

=item *

We no longer need to depend on the User Agent constraints in cookie 
amounts and sizes

=item *

Sensitive data like user's username, email address, preferences and such 
no longer need to be traveling across the network at each request ( 
which is the case with QUERY_STRINGs, cookies and hidden_fields ). Only 
thing that travels across the network is the unique id generated for the 
session ("ID-1234"), which should make no sense to bad guys whatsoever.

=item *

User will not have sensitive data stored in his computer in an unsecured 
plain text format ( which is a cookie file ).

=back

That's what CGI::Session is all about.

=head1 PROGRAMMING STYLE

Server side session management system might be seeming awfully 
convoluted if you have never dealt with it.  Fortunately, with 
CGI::Session this cumbersome task can be achieved in much elegent way 
and handled by the library transparently. This section of the manual can 
be treated as an introductory tutorial to  both logic behind session 
management, and to CGI::Session programming style as well.

=head1 WHAT YOU NEED TO KNOW FIRST

The syntax of the CGI::Session 3.x has changed from previous releases.
But we at the same time keep supporting the old syntax for backward 
compatibility. To help us do this, you will always need to "use" CGI::Session
with "-api3" switch:

    use CGI::Session qw/-api3/;

It tells the library that you will be using the new syntax.
Please don't ask us anything about the old syntax if you have never used it.
We won't tell you anyway :-).

But before you start using the library, you will need to decide where
and how you want the session data to be stored in disk. In other words,
you will need to tell what driver to use. You can choose either of "File",
"DB_File" and "MySQL" drivers, which are shipped with the distribution by 
default. Examples in this document will be using "File" driver exclusively
to make sure the examples are accessible in all machines with the least
requirements. To do this, we create the session object like so:

    use CGI::Session qw/-api3/;

    $session = new CGI::Session("driver:File", undef, {Directory=>'/tmp'});

The first argument is called Data Source Name (DSN in short). If it's undef,
the library will use the default driver, which is "File". So instead of 
being explicit about the driver as in the above example, we could simply say:

    $session = new CGI::Session(undef, undef, {Directory=>'/tmp'});

and we're guaranteed it will fall back to default driver.

The second argument is session id to be initialized. If it's undef, it will
force CGI::Session to create new session. 

The third argument should be in the form of hashref. This will be used by 
specific CGI::Session driver only. For the list of all the available attributes,
consult respective CGI::Session driver. Following drivers come with the 
distribution by default:

=over 4

=item *

B<File> - used for storing session data in plain files. Full name: 
L<CGI::Session::File>

=item *

B<DB_File> - used for storing session data in berkely db files. Full name:
L<CGI::Session::DB_File>

=item *

B<MySQL> - to store session data in MySQL table. Full name: 
L<CGI::Session::MySQL>

=back

Note: You can also write your own driver for the library. Consult respective 
section of this manual for details.

=head1 CREATING NEW SESSION

To generate a brand new session for a user, just pass an undefined value 
as the second argument to the constructor - new():

    $session = new CGI::Session("driver:File", undef, {Directory=>"/tmp"});

Directory refers to a place where the session files and their locks will 
be stored in the form of separate files. When you generate the session 
object, as we did above, you will have:

=over 4

=item 1

Session ID generated for you and

=item 2

Storage file associated with that file in the directory you specified.

=back

From now on, in case you want to access the newly generated session id 
just do:

    $sid = $session->id();

It returns a string something similar to B<bcd22cb2111125fdffaad97d809647e5> 
which you can now send as a cookie. Using standard L<CGI> class we can send the session id as a cookie to the user's browser like so:

    $cookie = $cgi->cookie(CGISESSID => $session->id);
    print $cgi->header( -cookie=>$cookie );

If anything in the above example doesn't make sense, please consult L<CGI> 
for the details. 

=head2 INITIALIZING EXISTING SESSIONS

When a user clicks another link or re-visits the site after a short 
while should we be creating a new session again? Absolutely not. This 
would defeat the whole purpose of state maintenance. Since we already 
send the id as a cookie, all we need is to pass that id as the first 
argument while creating a session object:

    $sid = $cgi->cookie("CGISESSID") || undef;
    $session    = new CGI::Session(undef, $sid, {Directory=>'/tmp'});

The above syntax will first try to initialize an existing session data, 
if it fails ( if the session doesn't exist ) creates a new session: 
just what we want.

You can also achieve the functionality of the above two lines with the 
following syntax. This is new to CGI::Session 3.x:

    $session = new CGI::Session(undef, $cgi, {Directory=>"/tmp"});

This will try to get the session id either from the cookie or from the 
query_string parameter. If it succeeds, initializes the old session from 
the disk or creates a new session. Name of the cookie and query_string 
parameter the library looks for is B<CGISESSID>. If you'd rather assign 
a different name update the value of $CGI::Session::COOKIENAME variable 
before creating the object:

    $CGI::Session::COOKIENAME = "SID";
    $session = new CGI::Session(undef, $cgi, {Directory=>"/tmp"});

=head2 STORING DATA IN THE SESSION

To store a single variable in the object use C<param()> method:

    $session->param("my_name", $name);

You can use C<param()> method to store complex data such as arrays, 
hashes, objects and so forth. While storing arrays and hashes, make 
sure to pass them as a reference:

    @my_array = ("apple", "grapes", "melon", "casaba");
    $session->param("fruits", \@my_array);

You can store objects as well, and retrieve them later

    $session->param("cgi", $cgi);   # stores CGI.pm object

Note: default serializer does not support storing objects. You will need to
configure the serializer to either "FreezeThaw" or "Storable":

    $session = new CGI::Session("serializer:Storable", undef,             
                                            { Directory=>'/tmp' } );

    $session->param("cgi", $cgi);

Sometimes you wish there was a way of storing all the CGI parameters in 
the session object. You would start dreaming of this feature after 
having to save dozens of query parameters from each form element to your session 
object. Consider the following syntax:

    $session->save_param($cgi, ["keyword", "category", "author", "orderby"]);

The above syntax make sure that all the above CGI parameters get saved 
in the session object. It's the same as saying

    $session->param("keyword",  $cgi->param("keyword"));
    $session->param("category", $cgi->param("category"));
    # etc...

In case you want to save all the CGI parameters. Just omit the second 
argument to C<save_param()>:

    $session->save_param($cgi);

The above syntax saves all the available/accessible CGI parameters

=head2 ACCESSING STORED DATA

There's no point of storing data if you cannot access it. You can access 
stored session data by using the same C<param()> method you once used to 
store them:

    $name = $session->param("my_name");

The above syntax retrieves session parameter previously stored as 
"my_name". To retrieve previously stored @my_array:

    $my_array = $session->param("fruits");

It will return a reference to the array, and can be dereferenced as 
@{$my_array}.

Frequently, especially when you find yourself creating drop down menus, 
scrolling lists and checkboxes, you tend to use CGI.pm for its sticky 
behavior that pre-selects default values. To have it preselect the 
values those selections must be present in the CGI object. 
C<load_param()> method does just that:

    $session->load_param($cgi, ["checkboxes"]);

The above code loads mentioned parameters to the CGI object so that they 
also become available via

    @selected = $cgi->param("checkboxes");

syntax. This allows automatic selection behavior of CGI.pm if checkbox 
and scrolling lists are being generated using CGI.pm. If you'd rather 
load all the session parameters to CGI.pm just omit the second parameter 
to C<load_param()>:

    $session->load_param($cgi);

This makes sure that all the available and accessible session parameters 
will also be available via CGI object.

If you're making use of HTML::Template to separate the code from the 
skins, you can as well associate CGI::Session object with HTML::Template 
and access all the parameters from within HTML files. We love this 
trick!

    $template = new HTML::Template(filename=>"some.tmpl", associate=>$session);
    print $template->output();

Assuming the session object stored "first_name" and "email" parameters 
while being associated with HTML::Template, you can access those values 
from within your "some.tmpl" file:

    Hello <a href="mailto:<TMPL_VAR email>"> <TMPL_VAR first_name> </a>!

For more tricks with HTML::Template, please refer to the library's 
manual (L<HTML::Template>) and CGI Session CookBook that comes with the 
library distribution.

=head2 CLOSING THE SESSION

Normally you don't have to close the session explicitly. It gets closed 
when your program terminates or session object goes out of scope. 
However in some few instances you might want to close the session 
explicitly by calling CGI::Session's C<close()> method. What is closing 
all about - you'd ask. While session is active, updates to session 
object doesn't get stored in the disk right away. It stores them in the 
memory until you either choose to flush the buffer by calling C<flush()> 
method or destroy the session object by either terminating the program 
or calling close() method explicitly.

In some circumstances you might want to close the session but at the 
same time don't want to terminate the process for a while. Might be the 
case in GUI and in daemon applications. In this case close() is what you 
want.

If you want to keep the session object but for any reason want to 
synchronize the data in the buffer with the one in the disk, C<flush()> 
method is what you need.

Note: close() calls flush() as well. So there's no need to call flush() 
before calling close()

=head2 CLEARING SESSION DATA

You store data in the session, you access the data in the session and at 
some point you will want to clear certain data from the session, if not 
all. For this reason CGI::Session provides C<clear()> method which 
optionally takes one argument as an arrayref indicating which session 
parameters should be deleted from the session object:

    $session->clear(["~logged-in", "email"]);

Above line deletes "~logged-in" and "email" session parameters from the 
session. And next time you say:

    $email = $session->param("email");

it returns undef. If you omit the argument to C<clear()>, be warned that 
all the session parameters you ever stored in the session object will 
get deleted. Note that it does not delete the session itself, for 
session stays open and accessible. It's just the parameters you stored 
in it gets deleted

=head2 DELETING A SESSION

If there's a start there's an end. If session could be created, it 
should be possible to delete it from the disk for good:

    $session->delete();

The above call to C<delete()> deletes the session from the disk for 
good. Do not confuse it with C<clear()>, which only clears certain 
session parameters but keeps the session open.

=head2 DELETE OR CLEAR?

This is a question of beliefs and style. After playing around with 
sessions for a while you'll figure out what you want. If you insist on 
our standing on this rather a controversial issue, don't hesitate to 
drop us an email.

=head1 VARIABLES

CGI::Session makes use of the following configurable variables which you 
can optionally set values to before creating a session object:

=over 4

=item B<$CGI::Session::NAME>

Denotes a name of the cookie that holds the session ID of the user. This 
variable is used only if you pass CGI object to new() instead of passing a 
session id. Default is "CGISESSID".

=item B<$CGI::Session::IP_MATCH>

Should the library try to match IP address of the user while 
retrieving an old session? Defaults to "0", which denotes "no". You can optionaly enable this with the "-ip_match" switch while "use"ing the library:

    use CGI::Session qw/-api3 -ip_match/;otes "no".

=item B<$CGI::Session::errstr>

This read-only variable holds the last error message.

=back

=head1 METHODS

Following is the overview of all the available methods accessible via 
CGI::Session object.

=over 4

=item C<new( DSN, SID, HASHREF )>

Requires three arguments. First is the Data Source Name, second should be
the session id to be initialized or an object which provides either of 'param()'
or 'cookie()' mehods. If Data Source Name is undef, it will fall back
to default values, which are "driver:File;serializer:Default;id:MD5".

If session id is missing, it will force the library to generate a new session
id, which will be accessible through C<id()> method.

Examples:

    $session = new CGI::Session(undef, undef, {Directory=>'/tmp'});
    $session = new CGI::Session("driver:File;serializer:Storable", undef,  {Directory=>'/tmp'})
    $session = new CGI::Session("driver:MySQL;id:Incr", undef, {Handle=>$dbh});

Following data source variables are supported:

=over 4

=item *

C<driver> - CGI::Session driver. Available drivers are "File", "DB_File" and 
"MySQL". Default is "File".

=item *

C<serializer> - serializer to be used to encode the data structure before saving 
in the disk. Available serializers are "Storable", "FreezeThaw" and "Default". 
Default is "Default", which uses standard L<Data::Dumper>

=item *

C<id> - ID generator to use when new session is to be created. Available ID generators are "MD5" and "Incr". Default is "MD5".

=back


=item C<id()>

Returns effective ID for a session. Since effective ID and claimed ID 
can differ, valid session id should always be retrieved using this 
method. Return value: string denoting the session id.

=item C<param($name)>

=item C<param(-name=E<gt>$name)>

this method used in either of the above syntax returns a session 
parameter set to C<$name> or undef on failure.

=item C<param( $name, $value)>

=item C<param(-name=E<gt>$name, -value=E<gt>$value)>

method used in either of the above syntax assigns a new value to $name 
parameter, which can later be retrieved with previously introduced 
param() syntax.

=item C<param_hashref()>

returns all the session parameters as a reference to a hash


=item C<save_param($cgi)>

=item C<save_param($cgi, $arrayref)>

Saves CGI parameters to session object. In otherwords, it's calling 
C<param($name, $value)> for every single CGI parameter. The first 
argument should be either CGI object or any object which can provide
param() method. If second argument is present and is a reference to an array, only those CGI parameters found in the array will 
be stored in the session

=item C<load_param($cgi)>

=item C<load_param($cgi, $arrayref)>

loads session parameters to CGI object. The first argument is required 
to be either CGI.pm object, or any other object which can provide 
param() method. If second argument is present and is a reference to an 
array, only the parameters found in that array will be loaded to CGI 
object.

=item C<clear()>

=item C<clear([@list])>

clears parameters from the session object. If passed an argument as an 
arrayref, clears only those parameters found in the list.

=item C<flush()>

synchronizes data in the buffer with its copy in disk. Normally it will 
be called for you just before the program terminates, session object 
goes out of scope or close() is called.

=item C<close()>

closes the session temporarily until new() is called on the same session 
next time. In other words, it's a call to flush() and DESTROY()

=item C<atime()>

returns the last access time of the session in the form of seconds from 
epoch. Is used while expiring sessions.

=item C<ctime()>

returns the time of the session data in the form of seconds from epoch, 
denoting the date when session was created for the first time.

=item C<expires()>

=item C<expires($time)>

=item C<expires($param, $time)>

Sets expiration date relative to atime(). If used with no arguments, 
returns the expiration date if it was ever set for a whole object. If no 
expiration was ever set, returns undef.

Second form sets an expiration date for a whole session. This value is 
checked when previously stored session is asked to be retrieved, and if 
its expiration date has passed will be expunged from the disk 
immediately and new session is created accordingly. Passing 0 would 
cancel expiration date

By using the third syntax you can also set an expiration date for a 
particular session parameter, say "~logged-in". This would cause the 
library call clear() on the parameter when its time is up.

All the time values should be given in the form of seconds. Following 
time aliases are also supported for your convenience:

    +===========+===============+
    |   alias   |   meaning     |
    +===========+===============+
    |     s     |   Second      |
    |     m     |   Minute      |
    |     h     |   Hour        |
    |     w     |   Week        |
    |     M     |   Month       |
    |     y     |   Year        |
    +-----------+---------------+

Examples:

    $session->expires("+1y");   # expires in one year
    $session->expires(0);       # cancel expiration
    $session->expires("~logged-in", "+10m");# expires ~logged-in flag in 10 mins

Note: all the expiration times are relative to session's last access 
time, not to its creation time. To expire a session immediately, call 
C<delete()>. To expire a specific session parameter immediately, call C<clear()>

=item C<remote_addr()>

Returns the remote address of the user who created the session for the 
first time. Returns undef if variable REMOTE_ADDR wasn't present in the 
environment when the session was created

=item C<delete()>

deletes the session from the disk. In other words, it calls for 
immediate expiration after which the session will not be accessible

=item C<error()>

returns the last error message from the library. It's the same as the 
value of $CGI::Session::errstr. Example:

    $session->flush() or die $session->error();

=item C<dump()>

=item C<dump("logs/dump.txt")>

creates a dump of the session object. Argument, if passed, will be 
interpreted as the name of the file object should be dumped in. Used 
mostly for debugging.

=back

=head1 SECURITY

"How secure is using CGI::Session?", "Can others hack down people's sessions 
using another browser if they can get the session id of the user?", "Are 
the session ids guessable?" are the questions I find myself answering 
over and over again.

=head2 STORAGE

Security of the library does in many aspects depend on the implementation. After 
making use of this library, you no longer have to send all the information to 
the user's cookie except for the session id. But, you still have to store the 
data in the server side. So another set of questions arise, can an evil person 
have access to session data in your server, even if they do, can they make sense 
out of the data in the session file, and even if they can, can they reuse the 
information against a person who created that session. As you see, the answer 
depends on yourself who is implementing it.

First rule of thumb, do not save the users' passwords or other sensitive data in 
the session. If you can persuade yourself that this is necessary, make sure that evil 
eyes don't have access to session files in your server. If you're using RDBMS driver 
such as MySQL, the database will be protected with a username/password pair. But if 
it will be storing in the file system in the form of plain files, make sure no one 
except you can have access to those files.

Default configuration of the driver makes use of Data::Dumper class to serialize 
data to make it possible to save it in the disk. Data::Dumper's result is a 
human readable data structure, which if opened, can be interpreted against you. 
If you configure your session object to use either Storable or FreezeThaw as a 
serializer, this would make more difficult for bad guys to make sense out of the 
data. But don't use this as the only precaution for security. Since evil fingers 
can type a quick program using Storable or FreezeThaw which deciphers that 
session file very easily.

Also, do not allow sick minds to update the contents of session files. Of course 
CGI::Session makes sure it doesn't happen, but your cautiousness does no harm 
either.

=head2 SESSION IDs

Session ids are not easily guessable. Default configuration of 
CGI::Session uses Digest::MD5 which takes process id, time in seconds 
since epoch and a random number and generates a 32 character long 
string. Although this string cannot be guessable by others, if they find 
it out somehow, can they use this identifier against the other person?

Consider the case, where you just give someone either via email or an 
instant messaging a link to your online-account profile, where you're 
currently logged in. The URL you give to that person contains a session 
id as part of a query_string. If your application was initializing the 
id solely using query_string parameter, after clicking on that link that 
person now appears to that site as you, and might have access to all of 
your private data instantly. How scary and how unwise implementation and 
what a poor kid who didn't know that pasting URLs with session ids was
an accident waiting to happen

Even if you're solely using cookies as the session id transporters, it's 
not that difficult to plant a cookie in the cookie file with the same id 
and trick the application this way. So key for security is to check if 
the person who's asking us to retrieve a session data is indeed the 
person who initially created the session data. CGI::Session helps you to 
watch out for such cases by enabling "-ip_match" switch while "use"ing the 
library:

    use CGI::Session qw/-ip-match -api3/;

or alternatively, setting $CGI::Session::IP_MATCH to a true value, say to 1.
This makes sure that before initializing a previously stored session, it checks 
if the ip address stored in the session matches the ip address of the user 
sking for that session. In which case the library returns the session, 
otherwise it dies with a proper error message. You can also set 

=head1 DRIVER SPECIFICATIONS

This section is for driver authors who want to implement their own 
storing mechanism for the library. Those who enjoy sub-classing stuff 
should find this section useful as well. Here we discuss the 
architecture of CGI::Session and its drivers.

=head2 LIBRARY OVERVIEW

Library provides all the base methods listed in the L<METHODS> section. 
The only methods CGI::Session doesn't bother providing are the ones that 
need to deal with writing the session data in the disk, retrieving the 
data from the disk, and deleting the data. These are the methods 
specific to the driver, so that's where they should be provided.

In other words, driver is just another Perl library which uses 
CGI::Session as a base class, and provides several additional methods 
that deal with disk-access and storage

=head2 SERIALIZATION

Before getting to driver specs, let's talk about how the data should be 
stored. When flush() is called, or the program terminates, CGI::Session 
asks a driver to store the data somewhere in the disk, and passes the 
data in the form of a hash reference. Then it's the driver's obligation 
to serialize the data so that it can be stored in the disk.

CGI::Session distribution comes with several libraries you can inherit 
from and call freeze() method on the object to serialize the data and 
store it. Those libraries are:

=over 4

=item B<CGI::Session::Serialize::Default>

=item B<CGI::Session::Serialize::Storable>

=item B<CGI::Session::Serialize::FreezeThaw>

=back

Refer to their respective manuals for more details

Example:

    # $data is a hashref that needs to be stored
    my $storable_data = $self->freeze($data)

$storable_data can now be saved in the disk.

When the driver is asked to retrieve the data from the disk, that 
serialized data should be accordingly de-serialized. The aforementioned 
serializer also provides thaw() method, which takes serialized data as 
the first argument, and returns Perl data structure, as it was before 
saved. Example:

    return $self->thaw($stored_data);

=head2 DRIVER METHODS

Driver is just another Perl library, which uses CGI::Session as a base 
class and is required to provide the following methods:

=over 4

=item C<retrieve($self, $sid, $options)>

this methods is called by CGI::Session with the above 3 arguments when 
it's asked to retrieve the session data from the disk. $self is the 
session object, $sid is the session id, and $options is the list of the 
arguments passed to new() in the form of a hashref. Method should return 
un-serialized session data, or undef indicating the failure. If an error 
occurs, instead of calling die() or croak(), we suggest setting the 
error message to error() and returning undef:

    unless ( sysopen(FH, $options->{FileName}, O_RDONLY) ) {
        $self->error("Couldn't read from $options->{FileName}: $!");
        return undef;
    }

=item C<store($self, $sid, $options, $data)>

this method is called by CGI::Session when session data needs to be 
stored. Data to be stored is passed as the third argument to the method, 
and is a reference to a hash. Should return any true value indicating 
success, undef otherwise. Error message should be passed to error().

=item C<remove($self, $sid, $options)>

called when CGI::Session is asked to remove the session data from the 
disk via delete() method. Should return true indicating success, undef 
otherwise, setting the error message to error()

=item C<teardown($self, $sid, $options)>

called when session object is about to get destroyed, either via close() 
or implicitly when the program terminates

=back

=head2 GENERATING ID

CGI::Session also requires the driver to provide a generate_id() method, which returns an
id for a new session. So CGI::Session distribution comes with libraries that provide you 
with generate_id() and you can simply inherit from them. Following libraries are available:

=over 4

=item B<CGI::Session::ID::MD5>

=item B<CGI::Session::ID::Incr>

=back

Refer to their respective manuals for more details.

In case you want to have your own style of ids, you can define a 
generate_id() method explicitly without inheriting from the above 
libraries. Or write your own B<CGI::Session::ID::YourID> library,
that simply defines "generate_id()" method, which returns a session id, 
then give the name to the constructor:

    $session = new CGI::Session("id:YourID", undef, {Neccessary=>Attrs});

=head2 BLUEPRINT

Your CGI::Session distribution comes with a Session/Blueprint.pm file 
which can be used as a starting point for your drive. Or consider the 
following blueprint:

    package CGI::Session::MyDriver;

    # inherit missing methods from the following classes
    use base qw(
        CGI::Session
        CGI::Session::Serialize::Default
        CGI::Session::ID::Default
    );

    use vars qw($VERSION);

    $VERSION = '1.1';

    sub retrieve {
        my ($self, $sid, $options) = @_;


    }

    sub store {
        my ($self, $sid, $data, $options) = @_;
        my $storable_data = $self->freeze($data);

    }

    sub remove {
        my ($self, $sid, $options) = @_;

    }

    sub teardown {
        my ($self, $sid, $options) = @_;

    }


    1;

    __END__;


After filling in the above blanks, you can do:

    $session = new CGI::Session::MyDriver($sid, {Option=>"Value"});

and use the library according to this manual.


=head1 COPYRIGHT

This library is free software. You can modify and or distribute it under 
the same terms as Perl itself.

=head1 AUTHOR

Sherzod Ruzmetov <sherzodr@cpan.org>.

Using this library? Find it useful in any way? Just drop me an email and 
make my day :-)

=head1 SEE ALSO

=over 4

=item CGI::Session Drivers

L<CGI::Session::File>, L<CGI::Session::DB_File>, L<CGI::Session::MySQL>, 
L<CGI::Session::BerkelyDB>

=item CGI Session Cook Book

L<cgisesscook> - Cook Book which is a part of the library distribution

=item CGI.pm

Perl's Simple Common Gateway Interface class by Lincoln Stein

=item Apache::Session

Another fine session library by Jeffrey Baker <jwbaker@acm.org>

=item RFC 2965

"HTTP State Management Mechanism" found at 
ftp://ftp.isi.edu/in-notes/rfc2965.txt

=back

=cut

# dump() - dumps the session object using Data::Dumper
sub dump {
    my ($self, $file, $data_only) = @_;

    require Data::Dumper;
    local $Data::Dumper::Indent = 1;

    my $ds = $data_only ? $self->{_DATA} : $self;

    my $d = new Data::Dumper([$ds], ["cgisession"]);

    if ( defined $file ) {
        unless ( open(FH, '<' . $file) ) {
            unless(open(FH, '>' . $file)) {
                $self->error("Couldn't open $file: $!");
                return undef;
            }
            print FH $d->Dump();
            unless ( close(FH) ) {
                $self->error("Couldn't dump into $file: $!");
                return undef;
            }            
        }
    }
    return $d->Dump();
}



sub version {   return $VERSION()   }


# delete() - sets the '_STATUS' session flag to DELETED,
# which flush() uses to decide to call remove() method on driver.
sub delete {
    my $self = shift;

    # If it was already deleted, make a confession!
    if ( $self->{_STATUS} == DELETED ) {
        confess "delete attempt on deleted session";
    }

    $self->{_STATUS} = DELETED;
}





# clear() - clears a list of parameters off the session's '_DATA' table
sub clear {
    my $self = shift;
    $class   = ref($class);

    my @params = ();
    if ( defined $_[0] ) {
        unless ( ref($_[0]) eq 'ARRAY' ) {
            confess "Usage: $class->clear([\@array])";
        }
        @params = @{ $_[0] };

    } else {
        @params = $self->param();

    }

    my $n = 0;
    for ( @params ) {
        /^_session_/ and next;
        # If this particular parameter has an expiration ticker,
        # remove it.
        if ( $self->{_DATA}->{_SESSION_EXPIRE_LIST}->{$_} ) {
            delete ( $self->{_DATA}->{_SESSION_EXPIRE_LIST}->{$_} );
        }
        delete ($self->{_DATA}->{$_}) && ++$n;
    }

    # Set the session '_STATUS' flag to MODIFIED
    $self->{_STATUS} = MODIFIED;

    return $n;
}


# save_param() - copies a list of third party object parameters
# into CGI::Session object's '_DATA' table
sub save_param {
    my ($self, $cgi, $list) = @_;

    unless ( ref($cgi) ) {
        confess "save_param(): first argument should be an object";

    }
    unless ( $cgi->can('param') ) {
        confess "save_param(): Cannot call method param() on the object";
    }

    my @params = ();
    if ( defined $list ) {
        unless ( ref($list) eq 'ARRAY' ) {
            confess "save_param(): second argument must be an arrayref";
        }

        @params = @{ $list };

    } else {
        @params = $cgi->param();

    }

    my $n = 0;
    for ( @params ) {
        # It's imporatnt to note that CGI.pm's param() returns array
        # if a parameter has more values associated with it (checkboxes
        # and crolling lists). So we should access its parameters in
        # array context not to miss anything
        my @values = $cgi->param($_);

        if ( defined $values[1] ) {
            $self->_set_param($_ => \@values);

        } else {
            $self->_set_param($_ => $values[0] );

        }

        ++$n;
    }

    return $n;
}


# load_param() - loads a list of third party object parameters
# such as CGI, into CGI::Session's '_DATA' table
sub load_param {
    my ($self, $cgi, $list) = @_;

    unless ( ref($cgi) ) {
        confess "save_param(): first argument must be an object";

    }
    unless ( $cgi->can('param') ) {
        my $class = ref($cgi);
        confess "save_param(): Cannot call method param() on the object $class";
    }

    my @params = ();
    if ( defined $list ) {
        unless ( ref($list) eq 'ARRAY' ) {
            confess "save_param(): second argument must be an arrayref";
        }
        @params = @{ $list };

    } else {
        @params = $self->param();

    }

    my $n = 0;
    for ( @params ) {
        $cgi->param(-name=>$_, -value=>$self->_get_param($_));
    }
    return $n;
}




# another, but a less efficient alternative to undefining
# the object
sub close {
    my $self = shift;
    
    $self->DESTROY();
}



# error() returns/sets error message
sub error {
    my ($self, $msg) = @_;

    if ( defined $msg ) {
        $errstr = $msg;
    }

    return $errstr;
}


# errstr() - alias to error()
sub errstr {
    my $self = shift;

    return $self->error(@_);
}



# atime() - rerturns session last access time
sub atime {
    my $self = shift;

    if ( @_ ) {
        confess "_SESSION_ATIME - read-only value";
    }

    return $self->{_DATA}->{_SESSION_ATIME};
}


# ctime() - returns session creation time
sub ctime {
    my $self = shift;

    if ( defined @_ ) {
        confess "_SESSION_ATIME - read-only value";
    }

    return $self->{_DATA}->{_SESSION_CTIME};
}


# expire() - sets/returns session/parameter expiration ticker
sub expire {
    my $self = shift;

    unless ( @_ ) {
        return $self->{_DATA}->{_SESSION_ETIME};
    }

    if ( @_ == 1 ) {
        return $self->{_DATA}->{_SESSION_ETIME} = _time_alias( $_[0] );
    }

    # If we came this far, we'll simply assume user is trying
    # to set an expiration date for a single session parameter.
    my ($param, $etime) = @_;

    # Let's check if that particular session parameter exists
    # in the '_DATA' table. Otherwise, return now!
    defined ($self->{_DATA}->{$param} ) || return;

    if ( $etime == -1 ) {
        delete $self->{_DATA}->{_SESSION_EXPIRE_LIST}->{$param};
        return;
    }

    $self->{_DATA}->{_SESSION_EXPIRE_LIST}->{$param} = _time_alias( $etime );
}



# parses such strings as '+1M', '+3w', accepted by expire()
sub _time_alias {
    my ($str) = @_;

    # If $str consists of just digits, return them as they are
    if ( $str =~ m/^\d+$/ ) {
        return $str;
    }

    my %time_map = (
        s           => 1,
        m           => 60,
        h           => 3600,
        d           => 3600 * 24,
        w           => 3600 * 24 * 7,
        M           => 3600 * 24 * 30,
        y           => 3600 * 24 * 365,
    );

    my ($koef, $d) = $str =~ m/([+-]?\d+)(\w)/;

    if ( defined($koef) && defined($d) ) {
        return $koef * $time_map{$d};
    }
}


# remote_addr() - returns ip address of the session
sub remote_addr {
    my $self = shift;

    return $self->{_DATA}->{_SESSION_REMOTE_ADDR};
}


# param_hashref() - returns parameters as a reference to a hash
sub param_hashref {
    my $self = shift;

    return $self->{_DATA};
}


# name() - returns the cookie name associated with the session id
sub name {
    return $CGI::Session::NAME;
}


# cookie() - returns CGI::Cookie object 
sub cookie {
    my $self = shift;
    confess "cookie(): don't use me! I'm broken";
}




# $Id: Session.pm,v 1.18 2002/11/22 22:57:56 sherzodr Exp $
