# print to standard output (for overriding in mod_perl)
sub print {
    shift;
    CORE::print(@_);
}
1;
