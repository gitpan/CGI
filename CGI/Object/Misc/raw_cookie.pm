sub raw_cookie {
    my($self,$key) = @_;

    if (defined($key)) {
        	$self->{'.raw_cookies'} = $self->raw_fetch
    	        unless $self->{'.raw_cookies'};
    
    	return () unless $self->{'.raw_cookies'};
    	return () unless $self->{'.raw_cookies'}->{$key};
    	return $self->{'.raw_cookies'}->{$key};
    }
    return $ENV{'HTTP_COOKIE'} || $ENV{'COOKIE'} || '';
}
1;