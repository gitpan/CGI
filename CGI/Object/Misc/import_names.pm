#### Method: import_names
# Import all parameters into the given namespace.
# Assumes namespace 'Q' if not specified
####

sub import_names {
    my ($self,$namespace,$delete) = @_;
    $namespace = 'Q' unless defined($namespace);
    die "Can't import names into \"main\"\n" if \%{"${namespace}::"} == \%::;
    if ($delete || $CGI::MOD_PERL) {
    # can anyone find an easier way to do this?
    foreach (keys %{"${namespace}::"}) {
        local *symbol = "${namespace}::${_}";
        undef $symbol;
        undef @symbol;
        undef %symbol;
    }
    }
    my($param,@value,$var);
    foreach $param (@{$self->{'.parameters'}}) {
    # protect against silly names
    ($var = $param)=~tr/a-zA-Z0-9_/_/c;
    $var =~ s/^(?=\d)/_/;
    local *symbol = "${namespace}::$var";
    @value = $self->{$param};
    @symbol = @value;
    $symbol = $value[0];
    }
}
1;
