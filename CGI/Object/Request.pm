package CGI::Object::Request;

use CGI::Object;
use integer;
@ISA = 'CGI::Object';

$CGI::IIS++ if defined($ENV{'SERVER_SOFTWARE'}) && $ENV{'SERVER_SOFTWARE'}=~/IIS/;

#### Method: self_url
# Returns a URL containing the current script and all its
# param/value pairs arranged as a query.  You can use this
# to create a link that, when selected, will reinvoke the
# script with all its state information preserved.
####
sub self_url {
    my $self = shift;
    return $self->url('-path_info'=>1,'-query'=>1,'-full'=>1,@_);
}


#### Method: url
# Like self_url, but doesn't return the query string part of
# the URL.
####
my $format = {
    'RELATIVE'=>0,
    'ABSOLUTE'=>1,
    'FULL'=>2,
    'PATH'=>3,
    'PATH_INFO'=>3,
    'QUERY'=>4,
    'QUERY_STRING'=>4,
};
my $default = ['','','','','',''];
sub url {
    my $self = shift;
    my ($relative,$absolute,$full,$path_info,$query) =
    $self->rearrange($format,$default,@_);
    my $url;
    $full++ unless ($relative || $absolute);

    if ($full) {
        my $protocol = $self->protocol();
        $url = "$protocol://";
        my $vh = $self->http('host');
        if ($vh) {
            $url .= $vh;
        } else {
            my $port = $self->server_port;
            $url .= server_name() . ":$port"
            unless ($port == 80 && lc($protocol) eq 'http')
                || ($port == 443 && lc($protocol) eq 'https');
        }
        $url .= $self->script_name;
    }
    elsif ($relative) {
        ($url) = $self->script_name =~ m!([^/]+)$!;
    } elsif ($absolute) {
        $url = $self->script_name;
    }
    $url .= $self->path_info if $path_info and $self->path_info;
    $url .= "?" . $self->query_string if $query and $self->query_string;
    return $url;
}



###############################################
# OTHER INFORMATION PROVIDED BY THE ENVIRONMENT
###############################################

#### Method: path_info
# Return the extra virtual path information provided
# after the URL (if any)
####
sub path_info {
    my $self = shift;
    my $info;
    if (defined($info=shift)) {
    $info = "/$info" if $info ne '' &&  substr($info,0,1) ne '/';
    $self->{'.path_info'} = $info;
    } elsif (! defined($self->{'.path_info'}) ) {
    $self->{'.path_info'} = defined($ENV{'PATH_INFO'}) ?
        $ENV{'PATH_INFO'} : '';

    # hack to fix broken path info in IIS
    $self->{'.path_info'} =~ s/^\Q$ENV{'SCRIPT_NAME'}\E// if $CGI::IIS;

    }
    return $self->{'.path_info'};
}


#### Method: request_method
# Returns 'POST', 'GET', 'PUT' or 'HEAD'
####
sub request_method {
    return $ENV{'REQUEST_METHOD'};
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
    my($param,$eparam,$value,@pairs);
    foreach $param (@{$self->{'.parameters'}}) {
        $eparam = $param;
        $eparam =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/ego;
        foreach $value ($self->param($param)) {
            $value =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/ego;
            push(@pairs,"$eparam=$value");
        }
    }
    return join($CGI::USE_PARAM_SEMICOLONS ? ";" : "&",@pairs);
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
sub Accept {
    my ($self,$search) = @_;
    my(%prefs,$type,$pref,$pat);

    my(@accept) = split(',',$self->http('accept') || '');

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
    next unless /\*/;       # not a pattern match
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
    my ($self,$match) = @_;
    return $self->http('user_agent') unless $match;
    return $self->http('user_agent') =~ /$match/i;
}

#### Method: virtual_host
# Return the name of the virtual_host, which
# is not always the same as the server
######
sub virtual_host {
    my $vh = http('host') || server_name();
    $vh =~ s/:\d+$//;       # get rid of port number
    return $vh;
}

#### Method: remote_host
# Return the name of the remote host, or its IP
# address if unavailable.  If this variable isn't
# defined, it returns "localhost" for debugging
# purposes.
####
sub remote_host {
    return $ENV{'REMOTE_HOST'} || $ENV{'REMOTE_ADDR'}
    || 'localhost';
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
    return $ENV{'SCRIPT_NAME'} if defined($ENV{'SCRIPT_NAME'});
    # These are for debugging
    return "/$0" unless $0=~/^\//;
    return $0;
}


#### Method: referer
# Return the HTTP_REFERER: useful for generating
# a GO BACK button.
####
sub referer {
    my $self = shift;
    return $self->http('referer');
}


#### Method: server_name
# Return the name of the server
####
sub server_name {
    $ENV{'SERVER_NAME'} or 'localhost';
}

#### Method: server_software
# Return the name of the server software
####
sub server_software {
    return $ENV{'SERVER_SOFTWARE'} || 'cmdline';
}

#### Method: server_port
# Return the tcp/ip port the server is running on
####
sub server_port {
    return $ENV{'SERVER_PORT'} || 80; # for debugging
}

#### Method: server_protocol
# Return the protocol (usually HTTP/1.0)
####
sub server_protocol {
    return $ENV{'SERVER_PROTOCOL'} || 'HTTP/1.0'; # for debugging
}

#### Method: http
# Return the value of an HTTP variable, or
# the list of variables if none provided
####
sub http {
    my ($self,$parameter) = @_;
    if (defined $parameter)
    {
        return $ENV{$parameter} if $parameter=~/^HTTP/;
        return $ENV{"HTTP_\U$parameter\E"};
    }
    my(@p);
    foreach (keys %ENV) {
    push(@p,$_) if /^HTTP/;
    }
    return @p;
}


#### Method: https
# Return the value of HTTPS
####
sub https {
    local($^W)=0;
    my ($self,$parameter) = @_;
    return $ENV{HTTPS} unless $parameter;
    return $ENV{$parameter} if $parameter=~/^HTTPS/;
    return $ENV{"HTTPS_\U$parameter\E"} if $parameter;
    my(@p);
    foreach (keys %ENV) {
    push(@p,$_) if /^HTTPS/;
    }
    return @p;
}

#### Method: protocol
# Return the protocol (http or https currently)
####
sub protocol {
    local($^W)=0;
    my $self = shift;
    return 'https' if uc($self->https()) eq 'ON';
    return 'https' if $self->server_port == 443;
    my $prot = $self->server_protocol;
    my($protocol,$version) = split('/',$prot);
    return "\L$protocol\E";
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


#### Method: user_name
# Try to return the remote user's name by hook or by
# crook
####
sub user_name {
    my $self = shift;
    return $self->http('from') || $ENV{'REMOTE_IDENT'} || $ENV{'REMOTE_USER'};
}

1;
# CGI3 alpha (not for public distribution)
# Copyright Lincoln Stein & David James 1999