my $format = {
    NAME=>0
};
my $default = [undef];
sub param_fetch {
    my $self = shift;
    if (!@_) {
        my %params;
        foreach (@{ $self->{'.parameters'} })
        {
            $params{$_} = $self->{$_};
        }
        return wantarray ? %params : \%params;
    }
    my($name) = $self->rearrange($format,$default,@_);
    if (!exists($self->{$name})) {
        push(@{$self->{'.parameters'}},$name);
        $self->{$name} = [];
    }
    elsif (!ref($self->{$name}))
    {
        $self->{$name} = [$self->{$name}];
    }
    return $self->{$name};
}

1;
