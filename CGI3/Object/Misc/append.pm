####
# Append a new value to an existing query
####
my $format = {
    NAME=>0,
    VALUE=>1,VALUES=>1,
};
my $default = ['',''];
sub append {
    my $self = shift;
    my($name,$value) = $self->rearrange($format,$default,@_);
    my(@values) = defined($value) ? (ref($value) ? @{$value} : $value) : ();
    if (@values) {
    push(@{$self->{'.parameters'}},$name);
    push(@{$self->{$name}},@values);
    }
    return $self->{$name};
}
1;
