sub to_filehandle {
    shift;
    my $thingy = shift;
    return unless $thingy;
    return $thingy if defined fileno($thingy);
    if (!ref($thingy)) {
        my $caller = 1;
        while (my $package = caller($caller++)) {
            return "${package}::$thingy" if defined(fileno("${package}::$thingy"));
        }
    }
    return;
}
1;
