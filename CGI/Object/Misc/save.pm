#### Method: save
# Write values out to a filehandle in such a way that they can
# be reinitialized by the filehandle form of the new() method
####

sub save {
    my ($self,$filehandle) = @_;
    return unless $filehandle;
    $filehandle = $self->to_filehandle($filehandle);
    my($param,$escaped_param,$value);
    local($,) = '';  # set print field separator back to a sane value
    local($\) = '';  # set output line separator to a sane value
    foreach $param (@{$self->{'.parameters'}}) {
        next unless defined $param;
        ($escaped_param = $param) =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/ego;
        foreach $value ($self->param($param)) {
            $value  =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/ego;
            print $filehandle "$escaped_param=$value\n";
        }
    }
    print $filehandle "=\n";    # end of record
}
1;
