

#### Method: delete_all
# Delete all parameters
####
sub delete_all {
    my $self = shift;
    undef %{$self};
    $self->{'.parameters'} = [];
}
1;

