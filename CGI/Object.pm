package CGI::Object;
use 5.005;
use integer;

use autoload qw(
CGI::Object::Html
CGI::Object::Request
CGI::Object::Cookie
CGI::Object::CGIlib
CGI::Object::Response
CGI::Object::Multipart
);

use CGI::Object::State; # because we always need it
use CGI::Object::Misc;  # because it's so small, it costs more to autoload it than to actually load it


*a = \&CGI::Object::Html::a;
*Accept = \&CGI::Object::Request::Accept;
*address = \&CGI::Object::Html::address;
*append = \&CGI::Object::Misc::append;
*applet = \&CGI::Object::Html::applet;
*as_string = \&CGI::Object::Misc::dump;
*auth_type = \&CGI::Object::Request::auth_type;
*autoEscape = \&CGI::Object::Html::autoEscape;
*b = \&CGI::Object::Html::b;
*base = \&CGI::Object::Html::base;
*basefont = \&CGI::Object::Html::basefont;
*big = \&CGI::Object::Html::big;
*blink = \&CGI::Object::Html::blink;
*blockquote = \&CGI::Object::Html::blockquote;
*body = \&CGI::Object::Html::body;
*br = \&CGI::Object::Html::br;
*button = \&CGI::Object::Html::button;
*cache = \&CGI::Object::Response::cache;
*caption = \&CGI::Object::Html::caption;
*center = \&CGI::Object::Html::center;
*charset = \&CGI::Object::State::charset;
*checkbox = \&CGI::Object::Html::checkbox;
*checkbox_group = \&CGI::Object::Html::checkbox_group;
*cite = \&CGI::Object::Html::cite;
*code = \&CGI::Object::Html::code;
*comment = \&CGI::Object::Html::comment;
*compile = \&CGI::Object::Misc::compile;
*cookie = \&CGI::Object::Cookie::cookie;
*cookie_fetch = \&CGI::Object::Cookie::cookie_fetch;
*dd = \&CGI::Object::Html::dd;
*default_dtd = \&CGI::Object::Response::default_dtd;
*defaults = \&CGI::Object::Html::defaults;
*Delete = \&CGI::Object::Misc::delete;
*delete = \&CGI::Object::Misc::delete;
*Delete_all = \&CGI::Object::Misc::delete_all;
*delete_all = \&CGI::Object::Misc::delete_all;
*dfn = \&CGI::Object::Html::dfn;
*div = \&CGI::Object::Html::div;
*dl = \&CGI::Object::Html::dl;
*dt = \&CGI::Object::Html::dt;
*dump = \&CGI::Object::Misc::dump;
*Dump = \&CGI::Object::Misc::dump;
*em = \&CGI::Object::Html::em;
*embed = \&CGI::Object::Html::embed;
*end_form = \&CGI::Object::Html::endform;
*end_html = \&CGI::Object::Html::end_html;
*end_multipart_form = \&CGI::Object::Html::endform;
*endform = \&CGI::Object::Html::endform;
*escapeHTML = \&CGI::Object::Html::escapeHTML;
*expire_calc = \&CGI::Object::Cookie::expire_calc;
*expires = \&CGI::Object::Cookie::expires;
*filefield = \&CGI::Object::Html::filefield;
*font = \&CGI::Object::Html::font;
*fontsize = \&CGI::Object::Html::fontsize;
*frame = \&CGI::Object::Html::frame;
*frameset = \&CGI::Object::Html::frameset;
*get_fields = \&CGI::Object::Html::get_fields;
*h1 = \&CGI::Object::Html::h1;
*h2 = \&CGI::Object::Html::h2;
*h3 = \&CGI::Object::Html::h3;
*h4 = \&CGI::Object::Html::h4;
*h5 = \&CGI::Object::Html::h5;
*h6 = \&CGI::Object::Html::h6;
*head = \&CGI::Object::Html::head;
*header = \&CGI::Object::Response::header;
*hidden = \&CGI::Object::Html::hidden;
*hr = \&CGI::Object::Html::hr;
*html = \&CGI::Object::Html::html;
*HtmlBot = \&CGI::Object::Html::end_html;
*HtmlTop = \&CGI::Object::Html::start_html;
*http = \&CGI::Object::Request::http;
*https = \&CGI::Object::Request::https;
*i = \&CGI::Object::Html::i;
*ilayer = \&CGI::Object::Html::ilayer;
*image_button = \&CGI::Object::Html::image_button;
*img = \&CGI::Object::Html::img;
*import_names = \&CGI::Object::Misc::import_names;
*init = \&CGI::Object::State::init;
*input = \&CGI::Object::Html::input;
*isindex = \&CGI::Object::Html::isindex;
*kbd = \&CGI::Object::Html::kbd;
*keywords = \&CGI::Object::Misc::keywords;
*layer = \&CGI::Object::Html::layer;
*li = \&CGI::Object::Html::li;
*Link = \&CGI::Object::Html::Link;
*make_attributes = \&CGI::Object::Html::make_attributes;
*menu = \&CGI::Object::Html::menu;
*meta = \&CGI::Object::Html::meta;
*MethGet = \&CGI::Object::CGIlib::MethGet;
*MethPost = \&CGI::Object::CGIlib::MethPost;
*MULTIPART = \&CGI::Object::Html::MULTIPART;
*multipart_end = \&CGI::Object::Multipart::multipart_end;
*multipart_init = \&CGI::Object::Multipart::multipart_init;
*multipart_start = \&CGI::Object::Multipart::multipart_start;
*new_MultipartBuffer = \&CGI::Object::Multipart::new_MultipartBuffer;
*nextid = \&CGI::Object::Html::nextid;
*nph = \&CGI::Object::Response::nph;
*ol = \&CGI::Object::Html::ol;
*option = \&CGI::Object::Html::option;
*p = \&CGI::Object::Html::p;
*Param = \&CGI::Object::Html::Param;
*param = \&CGI::Object::State::param;
*params = \&CGI::Object::Misc::param_fetch;
*param_fetch = \&CGI::Object::Misc::param_fetch;
*parse_keywordlist = \&CGI::Object::Misc::parse_keywordlist;
*parse_params = \&CGI::Object::State::parse_params;
*password_field = \&CGI::Object::Html::password_field;
*path_info = \&CGI::Object::Request::path_info;
*path_translated = \&CGI::Object::Request::path_translated;
*popup_menu = \&CGI::Object::Html::popup_menu;
*pre = \&CGI::Object::Html::pre;
*previous_or_default = \&CGI::Object::Html::previous_or_default;
*PrintHeader = \&CGI::Object::Response::header;
*private_tempfiles = \&CGI::Object::Multipart::private_tempfiles;
*protocol = \&CGI::Object::Request::protocol;
*put = \&CGI::Object::Misc::print;
*print = \&CGI::Object::Misc::print;
*query_string = \&CGI::Object::Request::query_string;
*raw_cookie = \&CGI::Object::Misc::raw_cookie;
*raw_fetch = \&CGI::Object::Misc::raw_fetch;
*radio_group = \&CGI::Object::Html::radio_group;
*read_from_client = \&CGI::Object::State::read_from_client;
*read_from_cmdline = \&CGI::Object::Misc::read_from_cmdline;
*read_multipart = \&CGI::Object::Multipart::read_multipart;
*ReadParse = \&CGI::Object::CGIlib::ReadParse;
*redirect = \&CGI::Object::Response::redirect;
*referer = \&CGI::Object::Request::referer;
*remote_addr = \&CGI::Object::Request::remote_addr;
*remote_host = \&CGI::Object::Request::remote_host;
*remote_ident = \&CGI::Object::Request::remote_ident;
*remote_user = \&CGI::Object::Request::remote_user;
*request_method = \&CGI::Object::Request::request_method;
*reset = \&CGI::Object::Html::reset;
*restore = \&CGI::Object::Misc::restore;
*restore_parameters = \&CGI::Object::new;
*samp = \&CGI::Object::Html::samp;
*save = \&CGI::Object::Misc::save;
*save_parameters = \&CGI::Object::Misc::save;
*save_request = \&CGI::Object::State::save_request;
*script = \&CGI::Object::Html::script;
*script_name = \&CGI::Object::Request::script_name;
*scrolling_list = \&CGI::Object::Html::scrolling_list;
*Select = \&CGI::Object::Html::Select;
*self_url = \&CGI::Object::Request::self_url;
*server_name = \&CGI::Object::Request::server_name;
*server_port = \&CGI::Object::Request::server_port;
*server_protocol = \&CGI::Object::Request::server_protocol;
*SERVER_PUSH = \&CGI::Object::Multipart::SERVER_PUSH;
*server_software = \&CGI::Object::Request::server_software;
*small = \&CGI::Object::Html::small;
*span = \&CGI::Object::Html::span;
*SplitParam = \&CGI::Object::CGIlib::SplitParam;
*start_form = \&CGI::Object::Html::startform;
*start_html = \&CGI::Object::Html::start_html;
*start_multipart_form = \&CGI::Object::Html::start_multipart_form;
*startform = \&CGI::Object::Html::startform;
*state = \&CGI::Object::Request::self_url;
*strike = \&CGI::Object::Html::strike;
*strong = \&CGI::Object::Html::strong;
*style = \&CGI::Object::Html::style;
*Sub = \&CGI::Object::Html::Sub;
*submit = \&CGI::Object::Html::submit;
*sup = \&CGI::Object::Html::sup;
*table = \&CGI::Object::Html::table;
*td = \&CGI::Object::Html::td;
*textarea = \&CGI::Object::Html::textarea;
*textfield = \&CGI::Object::Html::textfield;
*th = \&CGI::Object::Html::th;
*title = \&CGI::Object::Html::title;
*tmpFileName = \&CGI::Object::Multipart::tmpFileName;
*to_filehandle = \&CGI::Object::Misc::to_filehandle;
*Tr = \&CGI::Object::Html::Tr;
*TR = \&CGI::Object::Html::TR;
*tt = \&CGI::Object::Html::tt;
*u = \&CGI::Object::Html::u;
*ul = \&CGI::Object::Html::ul;
*uploadInfo = \&CGI::Object::Multipart::uploadInfo;
*url = \&CGI::Object::Request::url;
*URL_ENCODED = \&CGI::Object::Html::URL_ENCODED;
*url_param = \&CGI::Object::Misc::url_param;
*use_named_parameters = \&CGI::Object::Misc::use_named_parameters;
*user_agent = \&CGI::Object::Request::user_agent;
*user_name = \&CGI::Object::Request::user_name;
*var = \&CGI::Object::Html::var;
*virtual_host = \&CGI::Object::Request::virtual_host;

*_reset_globals = \&initialize_globals;
*_make_tag_func = \&CGI::Object::Html::_make_tag_func;
*_read_cookie_data = \&CGI::Object::Cookie::_read_cookie_data;
*_script = \&CGI::Object::Html::_script;
*_set_values_and_labels = \&CGI::Object::Html::_set_values_and_labels;
*_style = \&CGI::Object::Html::_style;
*_tableize = \&CGI::Object::Html::_tableize;
*_textfield = \&CGI::Object::Html::_textfield;


use Carp;

sub new
{
    my $class = shift;
    my $self = {
        '.parameters'=>[ ],
        '.named'=>0
    };

    if ($CGI::MOD_PERL) {
        Apache->request->register_cleanup(\&CGI::Object::_reset_globals);
        undef $NPH;
    }
    $self->_reset_globals if $CGI::PERLEX;

    bless $self, ref $class || $class || 'CGI::Object';

    $self->init(@_);

    return $self;
}

my ($defaults,$self,$map);
sub rearrange
{
    # Get Arguments
    ($self, $map) = splice(@_,0,2);
    if (ref $map eq "ARRAY")
    {
        my %map;
        $i = 0;
        foreach (@$map) {
            foreach (ref($_) ? @$_ : $_) { $map{$_} = $i; }
            $i++;
        }
        $#$defaults = $#$map;
        $map = \%map;
    }
    else
    {
        $defaults = shift;
    }
    my $sub = shift if ref $_[0] eq "CODE";

    if (@_ < 2)
    {
        if (ref $_[0] eq "HASH")
        {
            @_ = %{$_[0]}
        }
        else
        {
            return (@_, @$defaults[scalar(@_)..$#$defaults]);
        }
    }

    return (@_, @$defaults[scalar(@_)..$#$defaults])
        unless defined $_[0] and (substr($_[0],0,1) eq "-" or $self->{'.named'});

    # Temporary variables
    my ($key,$val,@widowed);
    my @result = @$defaults;

    # Iterate through each key=value pair.
    while (($key,$val) = splice(@_,0,2))
    {
        # Get rid of dash if necessary
        $key =~ s/^-//;
        if (exists($map->{uc $key}))
        {
            $result[$map->{uc $key}]=$val;
        }
        else
        {
            push(@widowed,$key,$val);
        }
    }

    # Return the new parameter list
    push (@result,defined $sub ? $sub->($self,@widowed) : @widowed) if (@widowed);
    return wantarray ? @result : \@result;
}

sub initialize_globals {
    # Set this to 1 to enable copious autoloader debugging messages
    $CGI::AUTOLOAD_DEBUG = 0;

    # Change this to the preferred DTD to print in start_html()
    # or use default_dtd('text of DTD to use');
    $CGI::DEFAULT_DTD = [ '-//W3C//DTD HTML 4.01 Transitional//EN',
                          'http://www.w3.org/TR/html4/loose.dtd' ] ;
    # Set this to 1 to enable NPH scripts
    # or:
    #    1) use CGI qw(-nph)
    #    2) $CGI::nph(1)
    #    3) print header(-nph=>1)
    $CGI::NPH = 0;

    # Set this to 1 to disable debugging from the
    # command line
    $CGI::NO_DEBUG = 1;

    # Set this to 1 to make the temporary files created
    # during file uploads safe from prying eyes
    # or do...
    #    1) use CGI qw(:private_tempfiles)
    #    2) $CGI::private_tempfiles(1);
    $CGI::PRIVATE_TEMPFILES = 0;

    # Set this to a positive value to limit the size of a POSTing
    # to a certain number of bytes:
    $CGI::POST_MAX = -1;

    # Change this to 1 to disable uploads entirely:
    $CGI::DISABLE_UPLOADS = 0;

    # Change this to 1 to suppress redundant HTTP headers
    $CGI::HEADERS_ONCE = 0;

    # The separator to divide parameters. Set this to a positive value
    # to enable new style URLS.
    $CGI::USE_PARAM_SEMICOLONS = 0;

    # Other globals that you shouldn't worry about.
    undef $CGI::Q;
    $CGI::BEEN_THERE = 0;
    undef %CGI::QUERY_PARAM;
    undef %CGI::EXPORT;

    # prevent complaints by mod_perl
    1;
}

&initialize_globals;

if (exists $ENV{'GATEWAY_INTERFACE'})
{
    if ($CGI::MOD_PERL = $ENV{'GATEWAY_INTERFACE'} =~ /^CGI-Perl\//)
    {
        $| = 1;
        require Apache;
    }
    $CGI::PERLEX++ if defined($ENV{'GATEWAY_INTERFACE'}) && $ENV{'GATEWAY_INTERFACE'} =~ /^CGI-PerlEx/;
}

sub DESTROY { }
sub import {
    if (@_>1)
    {
        require CGI;
        goto &CGI::import;
    }
}

sub AUTOLOAD {
	if (!$AUTOLOAD) { die ("Can't find $AUTOLOAD at " . caller()); }
    my $name = *$AUTOLOAD{NAME};
    if ($name =~ /^start_|^end_/)
    {
        *$AUTOLOAD = \&{"CGI::Object::Html::$name"};
        goto &{"CGI::Object::Html::$name"};
    }
    Carp::croak("Function $AUTOLOAD does not exist");
}



unless ($CGI::OS) {
    unless ($CGI::OS = $^O) {
    require Config;
    $CGI::OS = $Config::Config{'osname'};
    }
}
if ($CGI::OS=~/Win/i) {
    $CGI::OS = 'WINDOWS';
} elsif ($CGI::OS=~/vms/i) {
    $CGI::OS = 'VMS';
} elsif ($CGI::OS=~/^MacOS$/i) {
    $CGI::OS = 'MACINTOSH';
} elsif ($CGI::OS=~/os2/i) {
    $CGI::OS = 'OS2';
} else {
    $CGI::OS = 'UNIX';
}

# Some OS logic.  Binary mode enabled on DOS, NT and VMS
$needs_binmode = $CGI::OS=~/^(WINDOWS|VMS|OS2)/;

if ($needs_binmode) {
    binmode(main::STDOUT);
    binmode(main::STDIN);
    binmode(main::STDERR);
}

$CGI::EBCDIC = "\t" ne "\011";
if ($CGI::OS eq 'VMS') {
    $CGI::CRLF = "\n";
} elsif ($CGI::EBCDIC) {
    $CGI::CRLF= "\r\n";
} else {
    $CGI::CRLF = "\015\012";
}

$escape = qr/([^a-zA-Z0-9_.-])/;
$unescape = qr/%([0-9A-Fa-f]{2})/;

sub escape {
  my $val = shift;
  $val =~ s/$CGI::Object::escape/uc sprintf("%%%02x",ord($1))/ego;
  $val;
}

1;

# CGI3 alpha (not for public distribution)
# Copyright Lincoln Stein & David James 1999
