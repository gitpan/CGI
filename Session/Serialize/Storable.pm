package CGI::Session::Serialize::Storable;

# $Id: Storable.pm,v 1.3 2002/11/11 00:44:29 sherzodr Exp $ 
use strict;
use Storable;
use vars qw($VERSION);

($VERSION) = '$Revision: 1.3 $' =~ m/Revision:\s*(\S+)/;


sub freeze {
    my ($self, $data) = @_;

    return Storable::freeze($data);
}


sub thaw {
    my ($self, $string) = @_;

    return Storable::thaw($string);
}

# $Id: Storable.pm,v 1.3 2002/11/11 00:44:29 sherzodr Exp $

1;

=pod

=head1 NAME

CGI::Session::Serialize::Storable - serializer for CGI::Session

=head1 DESCRIPTION

This library is used by CGI::Session driver to serialize session data before storing
it in disk. Uses Storable

=head1 METHODS

=over 4

=item freeze()

receives two arguments. First is the CGI::Session driver object, the second is the data to be
stored passed as a reference to a hash. Should return true to indicate success, undef otherwise, 
passing the error message with as much details as possible to $self->error()

=item thaw()

receives two arguments. First being CGI::Session driver object, the second is the string
to be deserialized. Should return deserialized data structure to indicate successs. undef otherwise,
passing the error message with as much details as possible to $self->error().

=back

=head1 COPYRIGHT

Copyright (C) 2002 Sherzod Ruzmetov. All rights reserved.

This library is free software. It can be distributed under the same terms as Perl itself. 

=head1 AUTHOR

Sherzod Ruzmetov <sherzodr@cpan.org>

All bug reports should be directed to Sherzod Ruzmetov <sherzodr@cpan.org>. 

=head1 SEE ALSO

L<CGI::Session>
L<CGI::Session::Serialize::Default>
L<CGI::Session::Serialize::FreezeThaw>

=cut

# $Id: Storable.pm,v 1.3 2002/11/11 00:44:29 sherzodr Exp $
