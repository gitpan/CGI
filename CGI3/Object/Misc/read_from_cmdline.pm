sub read_from_cmdline {
    my($input,@words);
    my($query_string);
    if (@ARGV) {
    @words = @ARGV;
    } else {
    my $eof = chr(26);
    require "shellwords.pl";
    print STDERR "(offline mode: enter name=value pairs on standard input)\n";
    LOOP:
    {
        while (<STDIN>)
        {
            chomp;
            last LOOP unless $_=~/[\w=]/;
            push(@lines,$_);
        }
    }

    $input = join(" ",@lines);
    @words = &shellwords($input);
    }
    foreach (@words) {
    s/\\=/%3D/g;
    s/\\&/%26/g;
    }

    if ("@words"=~/=/) {
    $query_string = join('&',@words);
    } else {
    $query_string = join('+',@words);
    }
    return $query_string;
}

1;
