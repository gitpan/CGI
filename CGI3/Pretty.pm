package CGI3::Pretty;

# See the bottom of this file for the POD documentation.  Search for the
# string '=head'.

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

use strict 'vars','subs';
use CGI3::Object;

$CGI3::Pretty::VERSION = '1.04'; # modified by David James
@CGI3::Pretty::ISA = qw( CGI3::Object );

initialize_globals();

sub _prettyPrint {
    foreach my $i ( @CGI3::Pretty::AS_IS ) {
    if ( $_[0] =~ m{</$i}si ) {
        my ( $a, $b, $c) = $_[0] =~ m{(.*)(<$i[^>]*>.*?</$i>)(.*)}si;
        _prettyPrint( $a );
        _prettyPrint( $c );

        $_[0] = "$a$b$c";
        return;
    }
    }
    $_[0] =~ s/$CGI3::Pretty::LINEBREAK/$CGI3::Pretty::LINEBREAK$CGI3::Pretty::INDENT/g;
}

sub comment {
    my($self,@p) = @_;

    my $s = "@p";
    $s =~ s/$CGI3::Pretty::LINEBREAK/$CGI3::Pretty::LINEBREAK$CGI3::Pretty::INDENT/g;

    return $self->SUPER::comment( "$CGI3::Pretty::LINEBREAK$CGI3::Pretty::INDENT$s$CGI3::Pretty::LINEBREAK" ) . $CGI3::Pretty::LINEBREAK;
}

sub _make_tag_func {
    my ($self,$tagname) = @_;
    return $self->SUPER::_make_tag_func($tagname) if $tagname=~/^(start|end)_/;

    # As Lincoln as noted, the last else clause is VERY hairy, and it
    # took me a while to figure out what I was trying to do.
    # What it does is look for tags that shouldn't be indented (e.g. PRE)
    # and makes sure that when we nest tags, those tags don't get
    # indented.
    # For an example, try print td( pre( "hello\nworld" ) );
    # If we didn't care about stuff like that, the code would be
    # MUCH simpler.  BTW: I won't claim to be a regular expression
    # guru, so if anybody wants to contribute something that would
    # be quicker, easier to read, etc, I would be more than
    # willing to put it in - Brian

    my $tag = uc $tagname;


    *{"CGI3::Object::$tagname"} = sub {
        my $self = shift;

        my($attr) = '';
        if (ref($_[0]) && ref($_[0]) eq 'HASH') {
        my(@attr) = $self->make_attributes(%{shift()});
        $attr = " @attr" if @attr;
        }

        my($tag,$untag) = ("<$tag$attr>","</$tag>");
        return $tag unless @_;

        my @result;

        my $NON_PRETTIFY_ENDTAGS =  join "", map { "</$_>" } @CGI3::Pretty::AS_IS;
        if ( $NON_PRETTIFY_ENDTAGS =~ /$untag/ ) {
          return join "", map { "$tag$_$untag$CGI3::Pretty::LINEBREAK" }
         (ref($_[0]) eq 'ARRAY') ? @{$_[0]} : "@_";
        }
        else {
        return join "", map {
            chomp;
            if ( $_ !~ m{</} ) {
            s/$CGI3::Pretty::LINEBREAK/$CGI3::Pretty::LINEBREAK$CGI3::Pretty::INDENT/g;
            }
            else {
            CGI3::Pretty::_prettyPrint( $_ );
            }
            "$tag$CGI3::Pretty::LINEBREAK$CGI3::Pretty::INDENT$_$CGI3::Pretty::LINEBREAK$untag$CGI3::Pretty::LINEBREAK" }
        (ref($_[0]) eq 'ARRAY') ? @{$_[0]} : "@_";
        }
    };
}

sub start_html {
    return CGI3::start_html( @_ ) . $CGI3::Pretty::LINEBREAK;
}

sub end_html {
    return CGI3::end_html( @_ ) . $CGI3::Pretty::LINEBREAK;
}

sub new {
    my $class = shift;
    my $this = $class->SUPER::new( @_ );

    Apache->request->register_cleanup(\&CGI3::Pretty::_reset_globals) if ($CGI3::MOD_PERL);
    $class->_reset_globals if $CGI3::PERLEX;

    return bless $this, $class;
}

sub initialize_globals {
    # This is the string used for indentation of tags
    $CGI3::Pretty::INDENT = "\t";

    # This is the string used for seperation between tags
    $CGI3::Pretty::LINEBREAK = "\n";

    # These tags are not prettify'd.
    @CGI3::Pretty::AS_IS = qw( A PRE CODE SCRIPT TEXTAREA );

    1;
}
sub _reset_globals { initialize_globals(); CGI3::_reset_globals(); }

1;

=head1 NAME

CGI3::Pretty - module to produce nicely formatted HTML code

=head1 SYNOPSIS

    use CGI3::Pretty qw( :html3 );

    # Print a table with a single data element
    print table( TR( td( "foo" ) ) );

=head1 DESCRIPTION

CGI3::Pretty is a module that derives from CGI3.  It's sole function is to
allow users of CGI3 to output nicely formatted HTML code.

When using the CGI3 module, the following code:
    print table( TR( td( "foo" ) ) );

produces the following output:
    <TABLE><TR><TD>foo</TD></TR></TABLE>

If a user were to create a table consisting of many rows and many columns,
the resultant HTML code would be quite difficult to read since it has no
carriage returns or indentation.

CGI3::Pretty fixes this problem.  What it does is add a carriage
return and indentation to the HTML code so that one can easily read
it.

    print table( TR( td( "foo" ) ) );

now produces the following output:
    <TABLE>
       <TR>
          <TD>
             foo
          </TD>
       </TR>
    </TABLE>


=head2 Tags that won't be formatted

The <A> and <PRE> tags are not formatted.  If these tags were formatted, the
user would see the extra indentation on the web browser causing the page to
look different than what would be expected.  If you wish to add more tags to
the list of tags that are not to be touched, push them onto the C<@AS_IS> array:

    push @CGI3::Pretty::AS_IS,qw(CODE XMP);

=head2 Customizing the Indenting

If you wish to have your own personal style of indenting, you can change the
C<$INDENT> variable:

    $CGI3::Pretty::INDENT = "\t\t";

would cause the indents to be two tabs.

Similarly, if you wish to have more space between lines, you may change the
C<$LINEBREAK> variable:

    $CGI3::Pretty::LINEBREAK = "\n\n";

would create two carriage returns between lines.

If you decide you want to use the regular CGI3 indenting, you can easily do
the following:

    $CGI3::Pretty::INDENT = $CGI3::Pretty::LINEBREAK = "";

=head1 BUGS

This section intentionally left blank.

=head1 AUTHOR

Brian Paulsen <Brian@ThePaulsens.com>, with minor modifications by
Lincoln Stein <lstein@cshl.org> for incorporation into the CGI3.pm
distribution.

Copyright 1999, Brian Paulsen.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Bug reports and comments to Brian@ThePaulsens.com.  You can also write
to lstein@cshl.org, but this code looks pretty hairy to me and I'm not
sure I understand it!

=head1 SEE ALSO

L<CGI3>

=cut
