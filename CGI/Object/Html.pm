package CGI::Object::Html;
use 5.004;

# See the bottom of this file for the POD documentation.  Search for the
# string '=head'.

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

# Copyright 1999-2000 Lincoln D. Stein and David James
# Copyright 1995-1998 Lincoln D. Stein
# It may be used and modified freely, but I do request that this copyright
# notice remain attached to the file.  You may modify this module as you
# wish, but if you redistribute a modified version, please attach a note
# listing the modifications you have made.

use CGI::Object;
use CGI::Object::SelfLoader;

@ISA = 'CGI::Object';

sub URL_ENCODED { 'application/x-www-form-urlencoded'; }
sub MULTIPART {  'multipart/form-data'; }

# These are the valid HTML tags to *generate* anew
%tags = ('h1'=>1, 'h2'=>1, 'h3'=>1, 'h4'=>1,
'h5'=>1, 'h6'=>1, 'p'=>1, 'br'=>1, 'hr'=>1,
'ol'=>1, 'ul'=>1, 'li'=>1,'dl'=>1, 'dt'=>1,
'dd'=>1, 'menu'=>1, 'code'=>1, 'var'=>1,
'strong'=>1,'em'=>1, 'tt'=>1, 'u'=>1, 'i'=>1,
'b'=>1, 'blockquote'=>1, 'pre'=>1,'img'=>1,
'a'=>1, 'address'=>1, 'cite'=>1, 'samp'=>1,
'dfn'=>1,'html'=>1, 'head'=>1, 'base'=>1,
'body'=>1, 'Link'=>1, 'nextid'=>1,'title'=>1,
'meta'=>1, 'kbd'=>1,
'input'=>1, 'Select'=>1, 'option'=>1, 'comment'=>1,
'blink'=>1,'fontsize'=>1, 'center'=>1, 'div'=>1,
'table'=>1, 'caption'=>1, 'th'=>1,'td'=>1,
'TR'=>1, 'Tr'=>1, 'sup'=>1, 'Sub'=>1,
'strike'=>1, 'applet'=>1,'Param'=>1,
'embed'=>1, 'basefont'=>1, 'style'=>1,
'span'=>1,'layer'=>1, 'ilayer'=>1, 'font'=>1,
'frameset'=>1, 'frame'=>1,'script'=>1, 'small'=>1,
'big'=>1);


sub _make_tag_func {
    my ($self,$tagname) = @_;

    my $tag = uc $tagname;

    if ($tag=~/START_(\w+)/) {
        $tag = $1;
        *{"CGI::Object::$tagname"} = sub {
            my $self = shift;
            my($attr) = '';
            if (ref($_[0]) && ref($_[0]) eq 'HASH') {
                my(@attr) = $self->make_attributes( %{shift()} );
                $attr = " @attr" if @attr;
            }
            return "<$tag$attr>";
        };
    } elsif ($tag=~/END_(\w+)/) {
        $tag = $1;
        *{"CGI::Object::$tagname"} = sub { "</$tag>" }
    } else {
        *{"CGI::Object::$tagname"} = sub {
            my $self = shift;
            my $attr = '';
            if (ref($_[0]) && ref($_[0]) eq 'HASH') {
                my(@attr) = $self->make_attributes( %{shift()} );
                $attr = " @attr" if @attr;
            }
            return "<$tag$attr>" unless @_;
            my @result = map { "<$tag$attr>$_</$tag>" } (ref($_[0]) eq 'ARRAY') ? @{$_[0]} : "@_";
            return "@result";
        };
    }
}

sub AUTOLOAD_FAIL {
    print STDERR "CGI::Html::AUTOLOAD for $AUTOLOAD\n" if $CGI::AUTOLOAD_DEBUG;
    my ($base) = $AUTOLOAD =~ /([^:]+)$/;
    my $nbase = $base;
    $nbase =~ s/^start_|^end_//;
    if ($tags{$nbase} || $CGI::EXPORT{':any'} ||
        $CGI::EXPORT{'-any'}) {
        my $cref = $_[0]->_make_tag_func($base);
        goto &$cref;
    }
    Carp::confess "Undefined $CGI::DefaultClass subroutine $AUTOLOAD";
}


sub make_attributes {
    shift;
    my (@att);
    my ($key,$value);
    while (@_) {
        $key = shift;
        $value = shift;
        $key=~s/^\-//;     # get rid of initial - if present
        $key=~tr/a-z_/A-Z-/; # parameters are upper case, use dashes
        push(@att,defined($value) ? qq/$key="$value"/ : qq/$key/);
    }
    return @att;
}

$make_attributes = \&make_attributes;

%SUBS = (


#### Method: autoescape
# If you want to turn off the autoescaping features,
# call this method with undef as the argument
'autoEscape' => <<'END_OF_FUNC',
sub autoEscape {
    my $self = shift;
    $self->{'dontescape'}=!shift;
}
END_OF_FUNC

#### Method: start_html
# Canned HTML header
#
# Parameters:
# $title -> (optional) The title for this HTML document (-title)
# $author -> (optional) e-mail address of the author (-author)
# $base -> (optional) if set to true, will enter the BASE address of this document
#          for resolving relative references (-base)
# $xbase -> (optional) alternative base at some remote location (-xbase)
# $target -> (optional) target window to load all links into (-target)
# $script -> (option) Javascript code (-script)
# $no_script -> (option) Javascript <noscript> tag (-noscript)
# $meta -> (optional) Meta information tags
# $head -> (optional) any other elements you'd like to incorporate into the <HEAD> tag
#           (a scalar or array ref)
# $style -> (optional) reference to an external style sheet
# @other -> (optional) any other named parameters you'd like to incorporate into
#           the <BODY> tag.
####
'start_html' => <<'END_OF_FUNC',
my $format = {
    TITLE=>0,
    AUTHOR=>1,
    BASE=>2,
    XBASE=>3,
    SCRIPT=>4,
    NOSCRIPT=>5,
    TARGET=>6,
    META=>7,
    HEAD=>8,
    STYLE=>9,
    DTD=>10
};
my $defaults = ['Untitled Document','','','',undef,'','','','',undef,''];
sub start_html {
    my $self = shift;
    my ($title, $author, $base,$xbase,$script,$noscript, $target, $meta, $head,$style,$dtd,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);

    # strangely enough, the title needs to be escaped as HTML
    # while the author needs to be escaped as a URL
    $self->escapeHTML($title);
    $author =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/eg;

    if ($dtd) {
        if (ref $dtd && $ref eq 'ARRAY') {
            $dtd = $CGI::DEFAULT_DTD unless $dtd->[0] =~ m|^-//|;
        } else {
            $dtd = $CGI::DEFAULT_DTD unless $dtd =~ m|^-//|;
        }
    } else {
        $dtd = $CGI::DEFAULT_DTD;
    }

    my @result;
    if (ref($dtd) && ref($dtd) eq 'ARRAY') {
        push(@result,qq(<!DOCTYPE HTML PUBLIC "$dtd->[0]"\n\t"$dtd->[1]">));
    } else {
        push(@result,qq(<!DOCTYPE HTML PUBLIC "$dtd">));
    }
    push(@result,"<HTML><HEAD><TITLE>$title</TITLE>");
    push(@result,"<LINK REV=MADE HREF=\"mailto:$author\">") if $author;

    if ($base || $xbase || $target) {
        my $href = $xbase || $self->url('-path'=>1);
        $target = qq/ TARGET="$target"/ if $target;
        push(@result,qq/<BASE HREF="$href"$target>/);
    }

    if (ref $meta eq "HASH") {
        while (($key,$value) = each %$meta)
        {
            push(@result,qq(<META NAME="$key" CONTENT="$value">));
        }
    }

    push(@result,ref($head) ? @$head : $head) if $head;

    # handle the infrequently-used -style and -script parameters
    push(@result,$self->_style($style)) if defined $style;
    push(@result,$self->_script($script)) if defined $script;

    # handle -noscript parameter
    push(@result,<<"END") if $noscript;
<NOSCRIPT>
$noscript
</NOSCRIPT>
END
    my $other = @other ? " @other" : '';
    push(@result,"</HEAD><BODY$other>");
    return join("\n",@result);
}
END_OF_FUNC

### Method: _style
# internal method for generating a CSS style section
####
'_style' => <<'END_OF_FUNC',
my $format = {
    SRC=>0,
    CODE=>1,
    TYPE=>2,
};
my $defaults = [
    '','','text/css'
];
sub _style {
    my ($self,$style) = @_;
    my (@result);
    if (ref($style)) {
        my ($src,$code,$type) =
        $self->rearrange($format,$defaults,
                 '-foo'=>'bar', # a trick to allow the '-' to be omitted
                 ref($style) eq 'ARRAY' ? @$style : %$style);
        push(@result,qq/<LINK REL="stylesheet" HREF="$src">/) if $src;
        push(@result,style({'type'=>$type},"<!--\n$code\n-->")) if $code;
    } else {
        push(@result,style({'type'=>'text/css'},"<!--\n$style\n-->"));
    }
    @result;
}
END_OF_FUNC


'_script' => <<'END_OF_FUNC',
my $format = {
    SRC=>0,
    CODE=>1,
    LANGUAGE=>2
};
my $defaults = [ '','','Javascript' ];

sub _script {
    my ($self,$script) = @_;
    my (@result);
    my (@scripts) = ref($script) eq 'ARRAY' ? @$script : ($script);
    foreach $script (@scripts) {
    my($src,$code,$language);
    if (ref($script)) { # script is a hash
        ($src,$code,$language) =
        $self->rearrange($format,$defaults,
                 '-foo'=>'bar', # a trick to allow the '-' to be omitted
                 ref($style) eq 'ARRAY' ? @$script : %$script);

    } else {
        ($src,$code,$language) = ('',$script,'JavaScript');
    }
    my(@satts);
    push(@satts,'src'=>$src) if $src;
    push(@satts,'language'=>$language || 'JavaScript');
    $code = "<!-- Hide script\n$code\n// End script hiding -->"
        if $code && $language=~/javascript/i;
    $code = "<!-- Hide script\n$code\n\# End script hiding -->"
        if $code && $language=~/perl/i;
    push(@result,$self->script({@satts},$code));
    }
    @result;
}
END_OF_FUNC

#### Method: end_html
# End an HTML document.
# Trivial method for completeness.  Just returns "</BODY></HTML>"
####
'end_html' => <<'END_OF_FUNC',
sub end_html {
    return "</BODY></HTML>";
}
END_OF_FUNC


################################
# METHODS USED IN BUILDING FORMS
################################

#### Method: isindex
# Just prints out the isindex tag.
# Parameters:
#  $action -> optional URL of script to run
# Returns:
#   A string containing a <ISINDEX> tag
'isindex' => <<'END_OF_FUNC',
my $format = {
    ACTION=>0
};
my $defaults = [''];
sub isindex {
    my $self = shift;
    my($action,@other) = $self->rearrange($format,$defaults,$make_attributes,@_);
    $action = qq/ACTION="$action"/ if $action;
    my $other = @other ? " @other" : '';
    return "<ISINDEX $action$other>";
}
END_OF_FUNC


#### Method: startform
# Start a form
# Parameters:
#   $method -> optional submission method to use (GET or POST)
#   $action -> optional URL of script to run
#   $enctype ->encoding to use (URL_ENCODED or MULTIPART)
'startform' => <<'END_OF_FUNC',
my $format = {
    METHOD=>0,
    ACTION=>1,
    ENCTYPE=>2
};
my $defaults = [
    'POST','',&URL_ENCODED
];

sub startform {
    my $self = shift;

    my($method,$action,$enctype,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);

    if ($action) {
        $action = qq/ACTION="$action" /;
    } elsif ($method eq 'GET') {
        $action = 'ACTION="' . $self->script_name . '" ';
    }
    my($other) = @other ? " @other" : '';
    $self->{'.parametersToAdd'}={};
    return qq/<FORM METHOD="$method" ${action}ENCTYPE="$enctype"$other>\n/;
}
END_OF_FUNC


#### Method: endform
# End a form
'endform' => <<'END_OF_FUNC',
sub endform {
    my $self = shift;
    return ($self->get_fields,"</FORM>");
}
END_OF_FUNC

'get_fields' => <<'END_OF_FUNC',
sub get_fields {
    my($self) = @_;
    return $self->hidden('-name'=>'.cgifields',
                  '-values'=>[keys %{$self->{'.parametersToAdd'}}],
                  '-override'=>1);
}
END_OF_FUNC



#### Method: start_multipart_form
'start_multipart_form' => <<'END_OF_FUNC',
my $format = {
    METHOD=>0,
    ACTION=>1
};
my $defaults = ['',''];
sub start_multipart_form {
    my $self = shift;
    if ($self->use_named_parameters ||
    (defined($param[0]) && substr($param[0],0,1) eq '-')) {
    my(%p) = @_;
    $p{'-enctype'}=&MULTIPART;
    return $self->startform(%p);
    } else {
    my($method,$action,@other) =
        $self->rearrange($format,$defaults,$make_attributes,@_);
    return $self->startform($method,$action,&MULTIPART,@other);
    }
}
END_OF_FUNC


'_textfield' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    DEFAULT=>1,VALUE=>1,
    SIZE=>2,
    MAXLENGTH=>3,
    OVERRIDE=>4,FORCE=>4
};
my $defaults = ['','','','',''];
sub _textfield {
    my $self = shift;
    my $tag = shift;
    my($name,$default,$size,$maxlength,$override,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);

    my $current = $override ? $default : (defined($self->param($name)) ? $self->param($name) : $default);

    $self->escapeHTML($current);
    $self->escapeHTML($name);
    $size = qq/ SIZE=$size/ if $size ne '';
    $maxlength = qq/ MAXLENGTH=$maxlength/ if $maxlength ne '';
    my($other) = @other ? " @other" : '';

    # this entered at cristy's request to fix problems with file upload fields
    # and WebTV -- not sure it won't break stuff
    $current = qq( VALUE="$current") if $current ne '';

    return qq/<INPUT TYPE="$tag" NAME="$name"$current$size$maxlength$other>/;
}
END_OF_FUNC

#### Method: textfield
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
'textfield' => <<'END_OF_FUNC',
sub textfield {
    my $self = shift;
    $self->_textfield('text',@_);
}
END_OF_FUNC


#### Method: filefield
# Parameters:
#   $name -> Name of the file upload field
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
'filefield' => <<'END_OF_FUNC',
sub filefield {
    my $self = shift;
    $self->_textfield('file',@_);
}
END_OF_FUNC


#### Method: password
# Create a "secret password" entry field
# Parameters:
#   $name -> Name of the field
#   $default -> Optional default value of the field if not
#                already defined.
#   $size ->  Optional width of field in characters.
#   $maxlength -> Optional maximum characters that can be entered.
# Returns:
#   A string containing a <INPUT TYPE="password"> field
#
'password_field' => <<'END_OF_FUNC',
sub password_field {
    my $self = shift;
    $self->_textfield('password',@_);
}
END_OF_FUNC

#### Method: textarea
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $rows ->  Optional number of rows in text area
#   $columns -> Optional number of columns in text area
# Returns:
#   A string containing a <TEXTAREA></TEXTAREA> tag
#
'textarea' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    DEFAULT=>1,VALUE=>1,
    ROWS=>2,
    COLS=>3,COLUMNS=>3,
    OVERRIDE=>4,FORCE=>4
};
my $defaults = [
    '','','','',''
];
sub textarea {
    my $self = shift;

    my($name,$default,$rows,$cols,$override,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);

    my ($current) = $override ? $default :
        exists($self->{$name}) ? $self->param($name) : $default;

    $self->escapeHTML($name) if defined $name;
    $self->escapeHTML($current) if defined $current;
    $rows = $rows ? " ROWS=$rows" : '';
    $cols = $cols ? " COLS=$cols" : '';
    my $other = @other ? " @other" : '';
    return qq{<TEXTAREA NAME="$name"$rows$cols$other>$current</TEXTAREA>};
}
END_OF_FUNC


#### Method: button
# Create a javascript button.
# Parameters:
#   $name ->  (optional) Name for the button. (-name)
#   $value -> (optional) Value of the button when selected (and visible name) (-value)
#   $onclick -> (optional) Text of the JavaScript to run when the button is
#                clicked.
# Returns:
#   A string containing a <INPUT TYPE="button"> tag
####
'button' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUE=>1,LABEL=>1,
    ONCLICK=>2,SCRIPT=>2
};
my $defaults = [
    '','',''
];
sub button {
    my $self = shift;

    my($label,$value,$script,@other) = $self->rearrange($format,$defaults,$make_attributes,@_);

    if ($label)
    {
        $self->escapeHTML($label);
        $label = qq/ NAME="$label"/;
    }
    if ($value)
    {
        $self->escapeHTML($value);
        $value = qq/ VALUE="$value"/;
    }
    else
    {
        $value = $label;
    }
    if ($script)
    {
        $self->escapeHTML($script);
        $script = qq/ ONCLICK="$script"/;
    }
    my $other = @other ? " @other" : '';
    return qq/<INPUT TYPE="button"$label$value$script$other>/;
}
END_OF_FUNC


#### Method: submit
# Create a "submit query" button.
# Parameters:
#   $name ->  (optional) Name for the button.
#   $value -> (optional) Value of the button when selected (also doubles as label).
#   $label -> (optional) Label printed on the button(also doubles as the value).
# Returns:
#   A string containing a <INPUT TYPE="submit"> tag
####
'submit' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUE=>1,LABEL=>1
};
my $defaults = [
    '.submit',''
];
sub submit {
    my $self = shift;

    my($label,$value,@other) = $self->rearrange($format,$defaults,$make_attributes,@_);

    $self->escapeHTML($label);
    if ($value) {
        $self->escapeHTML($value);
    } else {
        $value = $label unless $label eq '.submit';
    }
    $label = qq/ NAME="$label"/ if $label;
    $value = qq/ VALUE="$value"/ if $value;

    my($other) = @other ? " @other" : '';
    return qq/<INPUT TYPE="submit"$label$value$other>/;
}
END_OF_FUNC


#### Method: reset
# Create a "reset" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="reset"> tag
####
'reset' => <<'END_OF_FUNC',
my $format = {
    NAME=>0
};
my $defaults = [
    ''
];
sub reset {
    my $self = shift;
    my($label,@other) = $self->rearrange($format,$defaults,$make_attributes,@_);
    if ($label)
    {
        $self->escapeHTML($label);
        $label = qq/ VALUE="$label"/;
    }
    my($other) = @other ? " @other" : '';
    return qq/<INPUT TYPE="reset"$label$other>/;
}
END_OF_FUNC


#### Method: defaults
# Create a "defaults" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="submit" NAME=".defaults"> tag
#
# Note: this button has a special meaning to the initialization script,
# and tells it to ERASE the current query string so that your defaults
# are used again!
####
'defaults' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,VALUE=>0
};
my $defaults = ["Defaults"];
sub defaults {
    my $self = shift;

    my($label,@other) = $self->rearrange($format,$defaults,$make_attributes,@_);

    $self->escapeHTML($label);
    my($other) = @other ? " @other" : '';

    return qq/<INPUT TYPE="submit" NAME=".defaults" VALUE="$label"$other>/;
}
END_OF_FUNC


#### Method: comment
# Create an HTML <!-- comment -->
# Parameters: a string
'comment' => <<'END_OF_FUNC',
sub comment {
    my $self = shift;
    return "<!-- @_ -->";
}
END_OF_FUNC

#### Method: checkbox
# Create a checkbox that is not logically linked to any others.
# The field value is "on" when the button is checked.
# Parameters:
#   $name -> Name of the checkbox
#   $checked -> (optional) turned on by default if true
#   $value -> (optional) value of the checkbox, 'on' by default
#   $label -> (optional) a user-readable label printed next to the box.
#             Otherwise the checkbox name is used.
# Returns:
#   A string containing a <INPUT TYPE="checkbox"> field
####
'checkbox' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    CHECKED=>1,SELECTED=>1,ON=>1,
    VALUE=>2,
    LABEL=>3,
    OVERRIDE=>4,FORCE=>4
};
my $defaults = [
    '','','on',undef,''
];
sub checkbox {
    my $self = shift;

    my($name,$checked,$value,$label,$override,@other) =
        $self->rearrange($format,$defaults,$make_attributes,@_);

    if (!$override && ($self->{'.fieldnames'}->{$name} ||
               exists $self->{$name})) {
        $checked = ' CHECKED' if grep($_ eq $value,$self->param($name));
    } else {
        $checked = ' CHECKED' if $checked;
    }
    $label = defined $label ? $label : $name;
    $self->escapeHTML($name);
    $self->escapeHTML($value);
    $self->escapeHTML($label);
    my($other) = @other ? " @other" : '';
    $self->{'.parametersToAdd'}->{$name}++;
    return qq(<INPUT TYPE="checkbox" NAME="$name" VALUE="$value"$checked$other>$label);
}
END_OF_FUNC


#### Method: checkbox_group
# Create a list of logically-linked checkboxes.
# Parameters:
#   $name -> Common name for all the check boxes
#   $values -> A pointer to a regular array containing the
#             values for each checkbox in the group.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of checkbox values,
#             then this will be used to decide which
#             checkboxes to turn on by default.
#             2. If a scalar, will be assumed to hold the
#             value of a single checkbox in the group to turn on.
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   An ARRAY containing a series of <INPUT TYPE="checkbox"> fields
####
'checkbox_group' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUES=>1,VALUE=>1,
    DEFAULTS=>2,DEFAULT=>2,
    LINEBREAK=>3,
    LABELS=>4,
    ROWS=>5,
    COLUMNS=>6,COLS=>6,
    ROWHEADERS=>7,
    COLHEADERS=>8,
    OVERRIDE=>9,FORCE=>9,
    NOLABELS=>10
};
my $defaults = [
    '',undef,'','','',undef,undef,'','','',''
];
sub checkbox_group {
    my $self = shift;

    my($name,$values,$defaults,$linebreak,$labels,$rows,$columns,
       $rowheaders,$colheaders,$override,$nolabels,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);

    my($checked,$break,$result,$label);

    my(%checked) = $self->previous_or_default($name,$defaults,$override);

    $break = $linebreak ? "<BR>" : '';
    $self->escapeHTML($name) if $name;

    # Create the elements
    my (@elements,@values);

    @values = $self->_set_values_and_labels($values,$name,\$labels);

    my($other) = @other ? " @other" : '';
    foreach (@values) {
        $checked = $checked{$_} ? ' CHECKED' : '';
        $label = '';
        unless ($nolabels) {
            $label = defined $labels->{$_} ? $labels->{$_} : $_;
            $self->escapeHTML($label);
        }
        $self->escapeHTML($_);
        push(@elements,qq/<INPUT TYPE="checkbox" NAME="$name" VALUE="$_"$checked$other>${label}${break}/);
    }
    $self->{'.parametersToAdd'}->{$name}++;

    return wantarray ? @elements : join(' ',@elements)
        unless defined($columns) || defined($rows);



    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}
END_OF_FUNC

# Escape HTML -- used internally
'escapeHTML' => <<'END_OF_FUNC',
my %r = ('&'=>'&amp;','<'=>'&lt;','>'=>'&gt;','"'=>'&quot;',"\x8b"=>'&#139;',"\x9b",'&#155;');
sub escapeHTML {
    my $self = shift;
    if (defined $_[0])
    {
        if (uc $self->{'.charset'} eq 'ISO-8859-1') {
            $_[0] =~ s/([&"><\x8b\x9b])/$r{$1}/g;
        }
        else
        {
            $_[0] =~ s/(.)/'&#'.ord($1).';'/gse;
        }
    }
}
END_OF_FUNC

# unescape HTML -- used internally
'unescapeHTML' => <<'END_OF_FUNC',
sub unescapeHTML {
    # thanks to Randal Schwartz for the correct solution to this one
    if (defined $_[0])
    {
        $_[0]=~ s[&(.*?);]{
        local $_ = $1;
        /^amp$/i    ? "&" :
        /^quot$/i   ? '"' :
        /^gt$/i     ? ">" :
        /^lt$/i     ? "<" :
        /^#(\d+)$/i ? chr($1) :
        /^#x([0-9a-fA-F]+)$/ ? chr(hex($1)) :
        $_
        }gsex;
    }
}
END_OF_FUNC

# Internal procedure - don't use
'_tableize' => <<'END_OF_FUNC',
sub _tableize {
    my($rows,$columns,$rowheaders,$colheaders,@elements) = @_;
    my($result);

    if (defined($columns)) {
    $rows = int(0.99 + @elements/$columns) unless defined($rows);
    }
    if (defined($rows)) {
    $columns = int(0.99 + @elements/$rows) unless defined($columns);
    }

    # rearrange into a pretty table
    $result = "<TABLE>";
    my($row,$column);
    unshift(@$colheaders,'') if defined(@$colheaders) && defined(@$rowheaders);
    $result .= "<TR>" if defined(@{$colheaders});
    foreach (@{$colheaders}) {
    $result .= "<TH>$_</TH>";
    }
    for ($row=0;$row<$rows;$row++) {
    $result .= "<TR>";
    $result .= "<TH>$rowheaders->[$row]</TH>" if defined(@$rowheaders);
    for ($column=0;$column<$columns;$column++) {
        $result .= "<TD>" . $elements[$column*$rows + $row] . "</TD>"
        if defined($elements[$column*$rows + $row]);
    }
    $result .= "</TR>";
    }
    $result .= "</TABLE>";
    return $result;
}
END_OF_FUNC


#### Method: radio_group
# Create a list of logically-linked radio buttons.
# Parameters:
#   $name -> Common name for all the buttons.
#   $values -> A pointer to a regular array containing the
#             values for each button in the group.
#   $default -> (optional) Value of the button to turn on by default.  Pass '-'
#               to turn _nothing_ on.
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   An ARRAY containing a series of <INPUT TYPE="radio"> fields
####
'radio_group' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUES=>1,VALUE=>1,
    DEFAULT=>2,
    LINEBREAK=>3,
    LABELS=>4,
    ROWS=>5,
    COLUMNS=>6,COLS=>6,
    ROWHEADERS=>7,
    COLHEADERS=>8,
    OVERRIDE=>9,FORCE=>9,
    NOLABELS=>10
};
my $defaults = [
    '',undef,undef,'','',undef,undef,'','','',''
];
sub radio_group {
    my $self = shift;

    my($name,$values,$default,$linebreak,$labels,$rows,$columns,$rowheaders,$colheaders,$override,$nolabels,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);
    my($result,$checked);

    if (!$override && exists($self->{$name})) {
        $checked = $self->param($name);
    } else {
        $checked = $default;
    }
    my(@elements,@values);
    @values = $self->_set_values_and_labels($values,$name,\$labels);

    # If no check array is specified, check the first by default
    $checked = $values[0] if !defined $checked;
    $self->escapeHTML($name);

    my $checkit = '';
    my $break = $linebreak ? '<BR>' : '';
    my $other = @other ? " @other" : '';

    foreach (@values) {
        next unless defined $_;
        $checkit = $checked eq $_ ? ' CHECKED' : '';
        $label = $nolabels ? '' : exists ($labels->{$_}) ? $labels->{$_} : $_;
        $self->escapeHTML($label);
        $self->escapeHTML($_);
        push(@elements,qq/<INPUT TYPE="radio" NAME="$name" VALUE="$_"$checkit$other>$label${break}/);
    }
    $self->{'.parametersToAdd'}->{$name}++;
    return wantarray ? @elements : "@elements"
           unless defined($columns) || defined($rows);
    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}
END_OF_FUNC


#### Method: popup_menu
# Create a popup menu.
# Parameters:
#   $name -> Name for all the menu
#   $values -> A pointer to a regular array containing the
#             text of each menu item.
#   $default -> (optional) Default item to display
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a popup menu.
####
'popup_menu' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUES=>1,VALUE=>1,
    DEFAULT=>2,DEFAULTS=>2,
    LABELS=>3,
    OVERRIDE=>4,FORCE=>4
};
my $defaults = ['','','','',''];
sub popup_menu {
    my $self = shift;

    my($name,$values,$default,$labels,$override,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);
    my($result,$selected);

    if (!$override && defined($self->{$name})) {
        $selected = $self->param($name);
    } else {
        $selected = $default;
    }
    $self->escapeHTML($name);
    my $other = @other ? " @other" : '';

    my @values = $self->_set_values_and_labels($values,$name,\$labels);

    my $selectit;
    $result = qq/<SELECT NAME="$name"$other>\n/;
    foreach (@values) {
        $selectit = $selected eq $_ ? 'SELECTED ' : '';
        $label = $labels->{$_} || $_;
        $self->escapeHTML($label);
        $self->escapeHTML($_);
        $result .= "<OPTION ${selectit}VALUE=\"$_\">$label\n";
    }

    $result .= "</SELECT>\n";
    return $result;
}
END_OF_FUNC


#### Method: scrolling_list
# Create a scrolling list.
# Parameters:
#   $name -> name for the list
#   $values -> A pointer to a regular array containing the
#             values for each option line in the list.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of options,
#             then this will be used to decide which
#             lines to turn on by default.
#             2. Otherwise holds the value of the single line to turn on.
#   $size -> (optional) Size of the list.
#   $multiple -> (optional) If set, allow multiple selections.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a scrolling list.
####
'scrolling_list' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    VALUES=>1,VALUE=>1,
    DEFAULTS=>2,DEFAULT=>2,
    SIZE=>3,
    MULTIPLE=>4,
    LABELS=>5,
    OVERRIDE=>6,FORCE=>6
};
my $defaults = ['','','','','','',''];
sub scrolling_list {
    my $self = shift;
    my($name,$values,$defaults,$size,$multiple,$labels,$override,@other)
        = $self->rearrange($format,$defaults,$make_attributes,@_);

    my($result,@values);
    @values = $self->_set_values_and_labels($values,$name,\$labels);

    $size = scalar(@values) unless $size;

    my(%selected) = $self->previous_or_default($name,$defaults,$override);
    my($is_multiple) = $multiple ? ' MULTIPLE' : '';
    my($has_size) = $size ? " SIZE=$size" : '';
    my($other) = @other ? " @other" : '';

    $self->escapeHTML($name) if $name;
    $result = qq/<SELECT NAME="$name"$has_size$is_multiple$other>\n/;
    foreach (@values) {
        my($selectit) = $selected{$_} ? ' SELECTED' : '';
        $label = $labels->{$_} || $_;
        $self->escapeHTML($label);
        $self->escapeHTML($_);
        $result .= "<OPTION$selectit VALUE=\"$_\">$label\n";
    }
    $result .= "</SELECT>\n";
    $self->{'.parametersToAdd'}->{$name}++;
    return $result;
}
END_OF_FUNC


#### Method: hidden
# Parameters:
#   $name -> Name of the hidden field
#   @default -> (optional) Initial values of field (may be an array)
#      or
#   $default->[initial values of field]
# Returns:
#   A string containing a <INPUT TYPE="hidden" NAME="name" VALUE="value">
####
'hidden' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    DEFAULT=>1,VALUE=>1,VALUES=>1,
    OVERRIDE=>2,FORCE=>2
};
my $defaults = ['',undef,''];

sub hidden {
    my $self = shift;
    # this is the one place where we departed from our standard
    # calling scheme, so we have to special-case (darn)
    my(@result,@value);
    my($name,$default,$override,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);
    my $do_override = 0;
    if ($name eq '' or $name eq $_[0]) {
        foreach ($default,$override,@other) {
            push(@value,$_) if defined($_);
        }
    } else {
        @value = ref($default) ? @{$default} : $default;
        $do_override = $override;
    }

    # use previous values if override is not set
    my @prev = $self->param($name);
    @value = @prev if !$do_override && @prev;
    $self->escapeHTML($name);
    foreach (@value) {
        $self->escapeHTML($_);
        push(@result,qq/<INPUT TYPE="hidden" NAME="$name" VALUE="$_">/);
    }

    return wantarray ? @result : join('',@result);
}
END_OF_FUNC


#### Method: image_button
# Parameters:
#   $name -> Name of the button
#   $src ->  URL of the image source
#   $align -> Alignment style (TOP, BOTTOM or MIDDLE)
# Returns:
#   A string containing a <INPUT TYPE="image" NAME="name" SRC="url" ALIGN="alignment">
####
'image_button' => <<'END_OF_FUNC',
my $format = {
    NAME=>0,
    SRC=>1,
    ALIGN=>2
};
my $defaults = ['','',''];
sub image_button {
    my $self = shift;

    my($name,$src,$alignment,@other) =
    $self->rearrange($format,$defaults,$make_attributes,@_);
    $alignment = " ALIGN=\U$alignment" if $alignment;
    my($other) = @other ? " @other" : '';
    $self->escapeHTML($name);
    return qq/<INPUT TYPE="image" NAME="$name" SRC="$src"$alignment$other>/;
}
END_OF_FUNC



# -------------- really private subroutines -----------------
'previous_or_default' => <<'END_OF_FUNC',
sub previous_or_default {
    my($self,$name,$defaults,$override) = @_;
    return unless defined $name;
    my(%selected);

    if (!$override && ($self->{'.fieldnames'}->{$name} ||
               exists($self->{$name}) ) ) {
        foreach ($self->param($name)) { $selected{$_}++ }
    } elsif (defined($defaults) && ref($defaults) &&
         (ref($defaults) eq 'ARRAY')) {
        foreach (@{$defaults}) { $selected{$_}++ }
    } else {
        $selected{$defaults}++ if defined($defaults);
    }

    return %selected;
}
END_OF_FUNC

'_set_values_and_labels' => <<'END_OF_FUNC',
sub _set_values_and_labels {
    my ($self,$v,$n,$l) = @_;
    $$l = $v if !ref($$l) and ref($v) eq 'HASH';

    return ($self->param($n)) unless defined($v);
    return $v unless ref($v);
    return ref($v) eq 'HASH' ? keys %$v : @$v;
}
END_OF_FUNC

);

1;

__END__

# CGI3 alpha (not for public distribution)
# Copyright Lincoln Stein & David James 1999