sub restore
{
    my $self = shift;
    my $initializer = shift;
    if (defined $initializer && UNIVERSAL::isa($initializer,'CGI3::Object')) {
        return $initializer->query_string;
    }
    if (ref($initializer) && ref($initializer) eq 'HASH') {
        my ($key,$value);
        $self->{'.parameters'} = [keys %$initializer];
        while (($key,$value) = each %$initializer) {
            $self->{$key} = $value;
        }
        return;
    }

    my $fh = to_filehandle($initializer);
    if (defined($fh) && ($fh ne '')) {
        while (<$fh>) {
            chomp;
            last if /^=/;
            push(@lines,$_);
        }
        # massage back into standard format
        if ("@lines" =~ /=/) {
            return join("&",@lines);
        } else {
            return join("+",@lines);
        }
    }

    # last chance -- treat it as a string
    $initializer = $$initializer if ref($initializer) eq 'SCALAR';
    return $initializer;
}
1;
