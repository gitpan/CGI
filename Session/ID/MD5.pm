package CGI::Session::ID::MD5;

# $Id: MD5.pm,v 1.2 2002/11/06 22:05:11 sherzodr Exp $

use strict;
use Digest::MD5;
use vars qw($VERSION);

($VERSION) = '$Revision: 1.2 $' =~ m/Revision:\s*(\S+)/;

sub generate_id {
    my $self = shift;

    my $md5 = new Digest::MD5();
    $md5->add($$ , time() , rand(9999) );

    return $md5->hexdigest();
}


1;


