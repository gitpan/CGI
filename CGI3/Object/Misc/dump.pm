#### Method: dump
# Returns a string in which all the known parameter/value
# pairs are represented as nested lists, mainly for the purposes
# of debugging.
####
sub dump {
    my $self = shift;
    my($param,$value,@result);
    return '<UL></UL>' unless $self->param;
    push(@result,"<UL>");
    foreach $param (@{$self->{'.parameters'}}) {
        CGI3::Html::escapeHTML($param);
        push(@result,"<LI><STRONG>$param</STRONG>");
        push(@result,"<UL>");
        foreach $value ($self->param($value)) {
            CGI3::Html::escapeHTML($value);
            push(@result,"<LI>$value");
        }
        push(@result,"</UL>");
    }
    push(@result,"</UL>\n");
    return join("\n",@result);
}
1;
