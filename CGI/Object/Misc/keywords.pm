sub keywords {
    my $self = shift;
    # If values is provided, then we set it.
    $self->{'keywords'}=[@_] if (@_>0);
    my(@result) = defined($self->{'keywords'}) ? @{$self->{'keywords'}} : ();
    @result;
}
1;
