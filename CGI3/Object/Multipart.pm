package CGI3::Object::Multipart;

sub SERVER_PUSH { 'multipart/x-mixed-replace; boundary="' . shift() . '"'; }

#### Method: multipart_init
# Return a Content-Type: style header for server-push
# This has to be NPH, and it is advisable to set $| = 1
#
# Many thanks to Ed Jordan <ed@fidalgo.net> for this
# contribution
####
my $multipart_init_format = {
    BOUNDARY=>0,
};
my $multipart_init_default = [ '------- =_aaaaaaaaaa0' ];
sub multipart_init {
    my $self = shift;
    my($boundary,@other) = $self->rearrange($multipart_init_format,$multipart_init_default,@_);
    $self->{'separator'} = "\n--$boundary\n";
    $type = SERVER_PUSH($boundary);
    return $self->header(
    -nph => 1,
    -type => $type,
    (map { split "=", $_, 2 } @other),
    ) . $self->multipart_end;
}


#### Method: multipart_start
# Return a Content-Type: style header for server-push, start of section
#
# Many thanks to Ed Jordan <ed@fidalgo.net> for this
# contribution
####
my $multipart_start_format = {
    TYPE=>0
};
my $multipart_start_default = ['text/html'];
sub multipart_start {
    my $self = shift;
    my($type,@other) = $self->rearrange($multipart_start_format,$multipart_start_default,@_);
    return $self->header(
    -type => $type,
    (map { split "=", $_, 2 } @other),
    );
}


#### Method: multipart_end
# Return a Content-Type: style header for server-push, end of section
#
# Many thanks to Ed Jordan <ed@fidalgo.net> for this
# contribution
####
sub multipart_end {
    my $self = shift;
    return $self->{'separator'};
}

#### Method: private_tempfiles
# Set or return the private_tempfiles global flag
####
sub private_tempfiles {
    my $self = shift;
    $CGI3::PRIVATE_TEMPFILES = shift if @_;
    return $CGI3::PRIVATE_TEMPFILES;
}



#####
# subroutine: read_multipart
#
# Read multipart data and store it into our parameters.
# An interesting feature is that if any of the parts is a file, we
# create a temporary file and open up a filehandle on it so that the
# caller can read from it if necessary.
#####
sub read_multipart {
    eval <<'END_OF_FUNC';
    my($self,$boundary,$length,$filehandle) = @_;
    my($buffer) = $self->new_MultipartBuffer($boundary,$length,$filehandle);
    return unless $buffer;
    my(%header,$body);
    my $filenumber = 0;
    while (!$buffer->eof) {
    %header = $buffer->readHeader;
    die "Malformed multipart POST\n" unless %header;

    my($param)= $header{'Content-Disposition'}=~/ name="?([^\";]*)"?/;

    # Bug:  Netscape doesn't escape quotation marks in file names!!!
    my($filename) = $header{'Content-Disposition'}=~/ filename="?([^\";]*)"?/;

    # add this parameter to our list
    push(@{$self->{'.parameters'}},$param);

    # If no filename specified, then just read the data and assign it
    # to our parameter list.
    unless ($filename) {
        my($value) = $buffer->readBody;
        push(@{$self->{$param}},$value);
        next;
    }

    my ($tmpfile,$tmp,$filehandle);
      UPLOADS: {
      # If we get here, then we are dealing with a potentially large
      # uploaded form.  Save the data to a temporary file, then open
      # the file for reading.

      # skip the file if uploads disabled
      if ($CGI3::DISABLE_UPLOADS) {
          while (defined($data = $buffer->read)) { }
          last UPLOADS;
      }

      $tmpfile = new TempFile;
      $tmp = $tmpfile->as_string;

      $filehandle = Fh->new($filename,$tmp,$CGI3::PRIVATE_TEMPFILES);

      binmode($filehandle) if $CGI3::needs_binmode;
      chmod 0600,$tmp;    # only the owner can tamper with it

      my ($data);
      local($\) = '';
      while (defined($data = $buffer->read)) {
          print $filehandle $data;
      }

      # back up to beginning of file
      seek($filehandle,0,0);
      binmode($filehandle) if $CGI3::needs_binmode;

      # Save some information about the uploaded file where we can get
      # at it later.
      $self->{'.tmpfiles'}->{$filename}= {
          name => $tmpfile,
          info => {%header},
      };
      push(@{$self->{$param}},$filehandle);
      }
    }


    # The path separator is a slash, backslash or colon, depending
    # on the platform.
    $CGI3::SL = {
        UNIX=>'/', OS2=>'\\', WINDOWS=>'\\', MACINTOSH=>':', VMS=>'/'
        }->{$CGI3::OS} unless $CGI3::SL;

    package TempFile;

    $SL = $CGI3::SL;
    $MAC = $CGI3::OS eq 'MACINTOSH';
    my ($vol) = $MAC ? MacPerl::Volumes() =~ /:(.*)/ : "";
    unless ($TMPDIRECTORY) {
        @TEMP=("${SL}usr${SL}tmp","${SL}var${SL}tmp",
           "C:${SL}temp","${SL}tmp","${SL}temp","${vol}${SL}Temporary Items",
           "${SL}WWW_ROOT");
        foreach (@TEMP) {
        do {$TMPDIRECTORY = $_; last} if -d $_ && -w _;
        }
    }

    $TMPDIRECTORY  = $MAC ? "" : "." unless $TMPDIRECTORY;
    $SEQUENCE=0;
    $MAXTRIES = 5000;

    # cute feature, but overload implementation broke it
    # %OVERLOAD = ('""'=>'as_string');


    sub new {
        my($package) = @_;
        my $directory;
        my $i;
        for ($i = 0; $i < $MAXTRIES; $i++) {
        $directory = sprintf("${TMPDIRECTORY}${SL}CGI3temp%d%04d",${$},++$SEQUENCE);
        last if ! -f $directory;
        }
        return bless \$directory;
    }

    sub DESTROY {
        my($self) = @_;
        unlink $$self;              # get rid of the file
    }

    sub as_string {
        my($self) = @_;
        return $$self;
    }
END_OF_FUNC
}

sub new_MultipartBuffer {
    my($self,$boundary,$length,$filehandle) = @_;
    eval <<'END_OF_FUNC';
    return MultipartBuffer->new($self,$boundary,$length,$filehandle);
        ######################## MultipartBuffer ####################
    package MultipartBuffer;

    # how many bytes to read at a time.  We use
    # a 4K buffer by default.
    $INITIAL_FILLUNIT = 1024 * 4;
    $TIMEOUT = 240*60;       # 4 hour timeout for big files
    $SPIN_LOOP_MAX = 2000;  # bug fix for some Netscape servers
    $CRLF=$CGI3::CRLF;


    sub new {
        my($package,$interface,$boundary,$length,$filehandle) = @_;
        $FILLUNIT = $INITIAL_FILLUNIT;
        my $IN;
        if ($filehandle) {
            $IN = $self->to_filehandle($filehandle);
        }
        $IN = "main::STDIN" unless $IN;

        $CGI3::DefaultClass->binmode($IN) if $CGI3::needs_binmode;

        # If the user types garbage into the file upload field,
        # then Netscape passes NOTHING to the server (not good).
        # We may hang on this read in that case. So we implement
        # a read timeout.  If nothing is ready to read
        # by then, we return.

        # Netscape seems to be a little bit unreliable
        # about providing boundary strings.
        if ($boundary) {

        # Under the MIME spec, the boundary consists of the
        # characters "--" PLUS the Boundary string

        # BUG: IE 3.01 on the Macintosh uses just the boundary -- not
        # the two extra hyphens.  We do a special case here on the user-agent!!!!
        $boundary = "--$boundary" unless CGI3::user_agent('MSIE 3\.0[12];  ?Mac');

        } else { # otherwise we find it ourselves
        my($old);
        ($old,$/) = ($/,$CRLF); # read a CRLF-delimited line
        $boundary = <$IN>;      # BUG: This won't work correctly under mod_perl
        $length -= length($boundary);
        chomp($boundary);               # remove the CRLF
        $/ = $old;                      # restore old line separator
        }

        my $self = {LENGTH=>$length,
            BOUNDARY=>$boundary,
            IN=>$IN,
            INTERFACE=>$interface,
            BUFFER=>'',
            };

        $FILLUNIT = length($boundary)
        if length($boundary) > $FILLUNIT;

        my $retval = bless $self,ref $package || $package;

        # Read the preamble and the topmost (boundary) line plus the CRLF.
        while ($self->read(0)) { }
        die "Malformed multipart POST\n" if $self->eof;

        return $retval;
    }

    sub readHeader {
        my($self) = @_;
        my($end);
        my($ok) = 0;
        my($bad) = 0;

        if ($CGI3::OS eq 'VMS') {  # tssk, tssk: inconsistency alert!
        local($CRLF) = "\015\012";
        }

        do {
        $self->fillBuffer($FILLUNIT);
        $ok++ if ($end = index($self->{BUFFER},"${CRLF}${CRLF}")) >= 0;
        $ok++ if $self->{BUFFER} eq '';
        $bad++ if !$ok && $self->{LENGTH} <= 0;
        # this was a bad idea
        # $FILLUNIT *= 2 if length($self->{BUFFER}) >= $FILLUNIT;
        } until $ok || $bad;
        return () if $bad;

        my($header) = substr($self->{BUFFER},0,$end+2);
        substr($self->{BUFFER},0,$end+4) = '';
        my %return;


        # See RFC 2045 Appendix A and RFC 822 sections 3.4.8
        #   (Folding Long Header Fields), 3.4.3 (Comments)
        #   and 3.4.5 (Quoted-Strings).

        my $token = '[-\w!\#$%&\'*+.^_\`|{}~]';
        $header=~s/$CRLF\s+/ /og;       # merge continuation lines
        while ($header=~/($token+):\s+([^$CRLF]*)/mgox) {
        my ($field_name,$field_value) = ($1,$2); # avoid taintedness
        $field_name =~ s/\b(\w)/uc($1)/eg; #canonicalize
        $return{$field_name}=$field_value;
        }
        return %return;
    }

    # This reads and returns the body as a single scalar value.
    sub readBody {
        my($self) = @_;
        my($data);
        my($returnval)='';
        while (defined($data = $self->read)) {
        $returnval .= $data;
        }
        return $returnval;
    }

    # This will read $bytes or until the boundary is hit, whichever happens
    # first.  After the boundary is hit, we return undef.  The next read will
    # skip over the boundary and begin reading again;
    sub read {
        my($self,$bytes) = @_;

        # default number of bytes to read
        $bytes = $bytes || $FILLUNIT;

        # Fill up our internal buffer in such a way that the boundary
        # is never split between reads.
        $self->fillBuffer($bytes);

        # Find the boundary in the buffer (it may not be there).
        my $start = index($self->{BUFFER},$self->{BOUNDARY});
        # protect against malformed multipart POST operations
        die "Malformed multipart POST\n" unless ($start >= 0) || ($self->{LENGTH} > 0);

        # If the boundary begins the data, then skip past it
        # and return undef.  The +2 here is a fiendish plot to
        # remove the CR/LF pair at the end of the boundary.
        if ($start == 0) {

        # clear us out completely if we've hit the last boundary.
        if (index($self->{BUFFER},"$self->{BOUNDARY}--")==0) {
            $self->{BUFFER}='';
            $self->{LENGTH}=0;
            return undef;
        }

        # just remove the boundary.
        substr($self->{BUFFER},0,length($self->{BOUNDARY})+2)='';
        return undef;
        }

        my $bytesToReturn;
        if ($start > 0) {           # read up to the boundary
        $bytesToReturn = $start > $bytes ? $bytes : $start;
        } else {    # read the requested number of bytes
        # leave enough bytes in the buffer to allow us to read
        # the boundary.  Thanks to Kevin Hendrick for finding
        # this one.
        $bytesToReturn = $bytes - (length($self->{BOUNDARY})+1);
        }

        my $returnval=substr($self->{BUFFER},0,$bytesToReturn);
        substr($self->{BUFFER},0,$bytesToReturn)='';

        # If we hit the boundary, remove the CRLF from the end.
        return ($start > 0) ? substr($returnval,0,-2) : $returnval;
    }

    # This fills up our internal buffer in such a way that the
    # boundary is never split between reads
    sub fillBuffer {
        my($self,$bytes) = @_;
        return unless $self->{LENGTH};

        my($boundaryLength) = length($self->{BOUNDARY});
        my($bufferLength) = length($self->{BUFFER});
        my($bytesToRead) = $bytes - $bufferLength + $boundaryLength + 2;
        $bytesToRead = $self->{LENGTH} if $self->{LENGTH} < $bytesToRead;

        # Try to read some data.  We may hang here if the browser is screwed up.
        my $bytesRead = $self->{INTERFACE}->read_from_client($self->{IN},
                                 \$self->{BUFFER},
                                 $bytesToRead,
                                 $bufferLength);
        $self->{BUFFER} = '' unless defined $self->{BUFFER};

        # An apparent bug in the Apache server causes the read()
        # to return zero bytes repeatedly without blocking if the
        # remote user aborts during a file transfer.  I don't know how
        # they manage this, but the workaround is to abort if we get
        # more than SPIN_LOOP_MAX consecutive zero reads.
        if ($bytesRead == 0) {
        die  "CGI3.pm: Server closed socket during multipart read (client aborted?).\n"
            if ($self->{ZERO_LOOP_COUNTER}++ >= $SPIN_LOOP_MAX);
        } else {
        $self->{ZERO_LOOP_COUNTER}=0;
        }

        $self->{LENGTH} -= $bytesRead;
    }


    # Return true when we've finished reading
    sub eof {
        my($self) = @_;
        return 1 if (length($self->{BUFFER}) == 0)
             && ($self->{LENGTH} <= 0);
        undef;
    }
END_OF_FUNC
}




sub tmpFileName {
    my ($self,$filename) = @_;
    return '' unless defined $self->{'.tmpfiles'};
    return $self->{'.tmpfiles'}->{$filename}->{name} ?
    $self->{'.tmpfiles'}->{$filename}->{name}->as_string
        : '';
}

sub uploadInfo {
    my $self = shift;
    return unless defined $self->{'.tmpfiles'};
    return $self->{'.tmpfiles'}->{shift(@_)}->{info};
}
