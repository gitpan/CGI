package CGI3::Object::State;
use 5.004;
use CGI3::Object;

@ISA = 'CGI3::Object';

# The POD documentation is at the end of this script.
# Search for the string '__END__'.

$CGI3::State::VERSION = "0.1";

use integer;                        # Faster math
require Carp;

my $param_map = {
    NAME => 0,
    VALUE => 1,
    VALUES => 1
};
my $param_default = [undef,undef];

sub param {
    my $self = shift;

    if (@_==0)
    {
        return @{$self->{'.parameters'}};
    }
    elsif (@_ == 1 and not ref $_[0])
    {
        my $key = shift;

        return unless defined $key;

        # If we're returning an array
        if (ref $self->{$key} eq "ARRAY")
        {
            # Return the array
            return wantarray ? @{$self->{$key}} : $self->{$key}->[0];
        }
        elsif (exists($self->{$key}))
        {
            # Return the field regularly
            return $self->{$key};
        }
        else
        {
            return;
        }
    }


    # Declare variable
    my ($key,$value) = $self->rearrange($param_map,$param_default, @_);

    # If there's a value, then set it
    if (defined $value)
    {
        push (@{$self->{'.parameters'}},$key) unless (exists ($self->{$key}));
        return $self->{$key}=$value;
    }

    # If there isn't a value, then just get the key
    else
    {
        # If we're returning an array
        if (ref $self->{$key} eq "ARRAY")
        {
            # Return the array
            return wantarray ? @{$self->{$key}} : $self->{$key}->[0];
        }
        elsif (exists($self->{$key}))
        {
            # Return the field regularly
            return $self->{$key};
        }
        else
        {
            return;
        }
    }
}

sub init {
    my ($self, $initializer) = @_;
    my($query_string,$meth,$content_length,$fh,@lines) = ('','','','');
    local($/) = "\n";

    $self->charset('ISO-8859-1');
    # if we get called more than once, we want to initialize
    # ourselves from the original query (which may be gone
    # if it was read from STDIN originally.)
    if (defined(%CGI3::QUERY_PARAM) && !defined($initializer)) {
        my ($key,$value);
        while (($key,$value) = each %CGI3::QUERY_PARAM)
        {
            $self->{$key} = $value;
        }
        $self->{'.parameters'} = [keys %CGI3::QUERY_PARAM];
        return;
    }

    $meth=$ENV{'REQUEST_METHOD'} if defined($ENV{'REQUEST_METHOD'});
    $content_length = defined($ENV{'CONTENT_LENGTH'}) ? $ENV{'CONTENT_LENGTH'} : 0;
    die "Client attempted to POST $content_length bytes, but POSTs are limited to $CGI3::POST_MAX"
    if ($CGI3::POST_MAX > 0) && ($content_length > $CGI3::POST_MAX);

    # If initializer is defined, then read parameters
    # from it.
    if (defined($initializer)) {
        $query_string = $self->restore($initializer);
    }

    # Process multipart postings, but only if the initializer is
    # not defined.
    elsif ($meth eq 'POST'
    && defined($ENV{'CONTENT_TYPE'})
    && $ENV{'CONTENT_TYPE'}=~m|^multipart/form-data|
    ) {
        my($boundary) = $ENV{'CONTENT_TYPE'} =~ /boundary=\"?([^\";,]+)\"?/;
        $self->read_multipart($boundary,$content_length);
    }

    # If method is GET or HEAD, fetch the query from
    # the environment.
    elsif ($meth=~/^(GET|HEAD)$/) {
        $query_string = $ENV{'QUERY_STRING'} if defined $ENV{'QUERY_STRING'};
    }

    elsif ($meth eq 'POST') {
        $self->read_from_client(\*main::STDIN,\$query_string,$content_length,0)
            if $content_length > 0;
        # Some people want to have their cake and eat it too!
        # Uncomment this line to have the contents of the query string
        # APPENDED to the POST data.
        # $query_string .= (length($query_string) ? '&' : '') . $ENV{'QUERY_STRING'} if defined $ENV{'QUERY_STRING'};
    }
    else
    {
        # If $meth is not of GET, POST or HEAD, assume we're being debugged offline.
        # Check the command line and then the standard input for data.
        # We use the shellwords package in order to behave the way that
        # UN*X programmers expect.
        $query_string = $self->read_from_cmdline() unless $CGI3::NO_DEBUG;
    }

    # We now have the query string in hand.  We do slightly
    # different things for keyword lists and parameter lists.
    if (defined $query_string && $query_string ne '') {
        if ($query_string =~ /=/) {
            $self->parse_params($query_string);
        } else {
            push (@{$self->{'.parameters'}},'keywords');
            $self->{'keywords'} = [$self->parse_keywordlist($query_string)];
        }
    }

    # Special case.  Erase everything if there is a field named
    # .defaults.
    if (exists $self->{'.defaults'}) {
        undef %{$self};
        $self->{'.parameters'} = [];
    }

    # Associative array containing our defined fieldnames
    $self->{'.fieldnames'} = {};
    foreach ($self->param('.cgifields')) {
        $self->{'.fieldnames'}->{$_}++;
    }

    # Clear out our default submission button flag if present
    delete $self->{'.submit'};
    delete $self->{'.cgifields'};
    @{$self->{'.parameters'}} = grep { $_ ne ".submit" and $_ ne ".cgifields" } @{$self->{'.parameters'}};

    $self->save_request unless $initializer;
    return;
}






sub save_request {
    my $self = shift;
    # We're going to play with the package globals now so that if we get called
    # again, we initialize ourselves in exactly the same way.  This allows
    # us to have several of these objects.
    %CGI3::QUERY_PARAM = map { $_, $self->{$_} } @{$self->{'.parameters'}};
}



sub parse_params {
    my($self,$tosplit) = @_;
    return unless $tosplit;
    my(@pairs) = split(/[&;]/,$tosplit);
    my($param,$value);
    foreach (@pairs) {
        tr/+/ /;
        ($param,$value) = split('=',$_,2);
        $param =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("c",hex($1))/ge;
        $value =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("c",hex($1))/ge;

        push(@{$self->{'.parameters'}},$param)  unless (exists ($self->{$param}));
        if (exists($self->{$param}))
        {
            if (ref $self->{$param})
            {
                push(@{$self->{$param}},$value);
            }
            else
            {
                $self->{$param} = [ $self->{$param}, $value ]
            }
        }
        else
        {
            $self->{$param}=$value;
        }
    }
}


sub read_from_client {
    my($self, $fh, $buff, $len, $offset) = @_;
    local $^W=0;                # prevent a warning
    return undef unless defined($fh);
    return read($fh, $$buff, $len, $offset);
}

sub charset {
  my ($self,$charset) = @_;
  $self->{'.charset'} = $charset if defined $charset;
  $self->{'.charset'};
}


1;

# Copyright Lincoln Stein & David James 1999