#### Method: url_param
# Return a parameter in the QUERY_STRING, regardless of
# whether this was a POST or a GET
####
sub url_param {
    my ($self,$name) = @_;
    return undef unless exists($ENV{QUERY_STRING});
    unless (exists($self->{'.url_param'})) {
        $self->{'.url_param'}={}; # empty hash
        if ($ENV{QUERY_STRING} =~ /=/) {
            my(@pairs) = split(/[&;]/,$ENV{QUERY_STRING});
            my($param,$value);
            foreach (@pairs) {
                s/$CGI::Object::unescape/pack("c",hex($1))/ego;
                tr/+/ /;
                ($param,$value) = split('=',$_,2);
                push(@{$self->{'.url_param'}->{$param}},$value);
            }
        }
        else {
            $self->{'.url_param'}->{'keywords'} = [$self->parse_keywordlist($ENV{QUERY_STRING})];
        }
    }
    return keys %{$self->{'.url_param'}} unless defined($name);
    return unless $self->{'.url_param'}->{$name};
    return wantarray ? @{$self->{'.url_param'}->{$name}}
                     : $self->{'.url_param'}->{$name}->[0];
}
1;
