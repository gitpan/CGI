sub parse_keywordlist {
    my($self,$tosplit) = @_;
    return unless $tosplit;
    $tosplit =~ s/$CGI::Object::unescape/pack("c",hex($1))/ego;
    $tosplit =~ tr/+/ /;          # pluses to spaces
    my(@keywords) = split(/\s+/,$tosplit);
    return @keywords;
}
1;
