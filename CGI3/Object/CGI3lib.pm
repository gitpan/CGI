package CGI3::Object::CGI3lib;

@ISA = 'CGI3::Object';

use CGI3::Object;

sub ReadParse {
    my $self = shift;
    local(*in);

    my $caller = caller();
    if (UNIVERSAL::isa($caller,"CGI3") || $caller =~ /^CGI3::/)
    {
        $caller = caller(1);
    }


    if (@_) {
        *in = "${caller}::$_[0]";
    } else {
        *in = "${caller}::in";
    }

    tie(%in,'CGI3::Object::CGI3lib');

    return scalar @{ $self->{'.parameters'} };
}

sub SplitParam {
    my ($param) = @_;
    my (@params) = split ("\0", $param);
    return (wantarray ? @params : $params[0]);
}

sub MethGet {
    my $self = shift();
    return $self->request_method() && $self->request_method() eq 'GET';
}

sub MethPost {
    my $self = shift();
    return $self->request_method() && $self->request_method() eq 'POST';
}

sub TIEHASH {
    return $CGI3::Q;
}

sub STORE {
    $_[0]->param($_[1],split("\0",$_[2]));
}

sub FETCH {
    return $_[0] if $_[1] eq 'CGI3';
    return undef unless defined $_[0]->param($_[1]);
    return join("\0",$_[0]->param($_[1]));
}

sub FIRSTKEY {
    $_[0]->{'.iterator'}=0;
    $_[0]->{'.parameters'}->[$_[0]->{'.iterator'}++];
}

sub NEXTKEY {
    $_[0]->{'.parameters'}->[$_[0]->{'.iterator'}++];
}

sub EXISTS {
    exists $_[0]->{$_[1]};
}

sub DELETE {
    $_[0]->delete($_[1]);
}

sub CLEAR {
    %{$_[0]}=();
}


1;

# Copyright Lincoln Stein & David James 1999