
#### Method: delete
# Deletes the named parameter entirely.
####
sub delete {
    my ($self, $name) = @_;
    return unless defined $name;
    delete $self->{$name};
    delete $self->{'.fieldnames'}->{$name};
    @{$self->{'.parameters'}}=grep($_ ne $name,@{$self->{'.parameters'}});
    return;
}
1;
