package CGI::Object::Response;

@ISA = 'CGI::Object';

use CGI::Object;
use integer;

sub fix
{
    shift;
    my @return;
    while (@_)
    {
        push(@return,join(": ",shift,shift));
    }
    return @return;
}

#### Method: header
# Return a Content-Type: style header
#
####
sub header {
    my $self = shift;
    my(@header);

    return undef if $self->{'.header_printed'}++ and $CGI::HEADERS_ONCE;

    my($type,$status,$cookie,$target,$expires,$nph,$charset,@other) =
    $self->rearrange({TYPE=>0,CONTENT_TYPE=>0,'CONTENT-TYPE'=>0,
              STATUS=>1,COOKIE=>2,COOKIES=>2,TARGET=>3,EXPIRES=>4,NPH=>5,CHARSET=>6},
              [ 'text/html','','','','','','ISO-8859-1'],\&fix,@_);

    $nph ||= $CGI::NPH;

    if (defined $charset) {
      $self->charset($charset);
    } else {
      $charset = $self->charset;
    }


    $type .= "; charset=$charset" unless $type=~/\bcharset\b/;

    # Maybe future compatibility.  Maybe not.
    my $protocol = $ENV{SERVER_PROTOCOL} || 'HTTP/1.0';
    push(@header,"$protocol " . ($status || '200 OK') ) if $nph;

    push(@header,"Status: $status") if $status;
    push(@header,"Window-Target: $target") if $target;
    # push all the cookies -- there may be several
    if ($cookie) {
        my(@cookie) = ref($cookie) && ref($cookie) eq 'ARRAY' ? @{$cookie} : $cookie;
        foreach (@cookie) {
            my $cs = UNIVERSAL::isa($_,'CGI::Cookie') ? $_->as_string : $_;
            push(@header,"Set-Cookie: $cs") if $cs ne '';
        }
    }
    # if the user indicates an expiration time, then we need
    # both an Expires and a Date header (so that the browser
    # uses OUR clock)
    push(@header,"Expires: " . $self->expires($expires,'http')) if $expires;
    push(@header,"Date: " . $self->expires(0,'http')) if $expires || $cookie;
    push(@header,"Pragma: no-cache") if $self->cache();
    push(@header,@other);
    push(@header,"Content-Type: $type") if $type ne '';

    my $header = join($CGI::CRLF,@header)."${CGI::CRLF}${CGI::CRLF}";

    if ($CGI::MOD_PERL and not $nph) {
        my $r = Apache->request;
        $r->send_cgi_header($header);
        return '';
    }
    return $header;
}

#### Method: cache
# Control whether header() will produce the no-cache
# Pragma directive.
####
sub cache {
    my $self = shift;
    $new_value = shift || '';
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
    my $self = shift;
    my($url,$target,$cookie,$nph,@other) =
        $self->rearrange({LOCATION=>0,URI=>0,URL=>0,TARGET=>1,COOKIE=>2,NPH=>3},
        ['','','',''],@_);
    $url = $url || $self->self_url;
    my(@o);
    foreach (@other) { tr/\"//d; push(@o,split("=",$_,2)); }
    unshift(@o,
     '-Status'=>'302 Moved',
     '-Location'=>$url,
     '-nph'=>$nph);
    unshift(@o,'-Target'=>$target) if $target;
    unshift(@o,'-Cookie'=>$cookie) if $cookie;
    unshift(@o,'-Type'=>'');
    return $self->header(@o);
}


#### Method: nph
# Set or return the NPH global flag
####
sub nph {
    my $self = shift;
    $CGI::NPH = shift if @_;
    return $CGI::NPH;
}

#### Method: default_dtd
# Set or return the default_dtd global
####
sub default_dtd {
    my $self = shift;
    $CGI::DEFAULT_DTD = shift if @_;
    return $CGI::DEFAULT_DTD;
}

1;

# CGI3 alpha (not for public distribution)
# Copyright Lincoln Stein & David James 1999