
#### Method: use_named_parameters
# Force CGI.pm to use named parameter-style method calls
# rather than positional parameters.  The same effect
# will happen automatically if the first parameter
# begins with a -.
sub use_named_parameters {
    my ($self,$use_named) = @_;
    return $self->{'.named'} unless defined ($use_named);
    return $self->{'.named'}=$use_named;
}
1;
