package CGI3::Object;
use 5.005;
use integer;

use autoload qw(
CGI3::Object::Html
CGI3::Object::Request
CGI3::Object::Cookie
CGI3::Object::CGI3lib
CGI3::Object::Response
CGI3::Object::Multipart
);

use CGI3::Object::State; # because we always need it
use CGI3::Object::Misc;  # because it's so small, it costs more to autoload it than to actually load it


*a = \&CGI3::Object::Html::a;
*Accept = \&CGI3::Object::Request::Accept;
*address = \&CGI3::Object::Html::address;
*append = \&CGI3::Object::Misc::append;
*applet = \&CGI3::Object::Html::applet;
*as_string = \&CGI3::Object::Misc::dump;
*auth_type = \&CGI3::Object::Request::auth_type;
*autoEscape = \&CGI3::Object::Html::autoEscape;
*b = \&CGI3::Object::Html::b;
*base = \&CGI3::Object::Html::base;
*basefont = \&CGI3::Object::Html::basefont;
*big = \&CGI3::Object::Html::big;
*blink = \&CGI3::Object::Html::blink;
*blockquote = \&CGI3::Object::Html::blockquote;
*body = \&CGI3::Object::Html::body;
*br = \&CGI3::Object::Html::br;
*button = \&CGI3::Object::Html::button;
*cache = \&CGI3::Object::Response::cache;
*caption = \&CGI3::Object::Html::caption;
*center = \&CGI3::Object::Html::center;
*charset = \&CGI3::Object::State::charset;
*checkbox = \&CGI3::Object::Html::checkbox;
*checkbox_group = \&CGI3::Object::Html::checkbox_group;
*cite = \&CGI3::Object::Html::cite;
*code = \&CGI3::Object::Html::code;
*comment = \&CGI3::Object::Html::comment;
*compile = \&CGI3::Object::Misc::compile;
*cookie = \&CGI3::Object::Cookie::cookie;
*cookie_fetch = \&CGI3::Object::Cookie::cookie_fetch;
*dd = \&CGI3::Object::Html::dd;
*default_dtd = \&CGI3::Object::Response::default_dtd;
*defaults = \&CGI3::Object::Html::defaults;
*Delete = \&CGI3::Object::Misc::delete;
*delete = \&CGI3::Object::Misc::delete;
*Delete_all = \&CGI3::Object::Misc::delete_all;
*delete_all = \&CGI3::Object::Misc::delete_all;
*dfn = \&CGI3::Object::Html::dfn;
*div = \&CGI3::Object::Html::div;
*dl = \&CGI3::Object::Html::dl;
*dt = \&CGI3::Object::Html::dt;
*dump = \&CGI3::Object::Misc::dump;
*Dump = \&CGI3::Object::Misc::dump;
*em = \&CGI3::Object::Html::em;
*embed = \&CGI3::Object::Html::embed;
*end_form = \&CGI3::Object::Html::endform;
*end_html = \&CGI3::Object::Html::end_html;
*end_multipart_form = \&CGI3::Object::Html::endform;
*endform = \&CGI3::Object::Html::endform;
*escapeHTML = \&CGI3::Object::Html::escapeHTML;
*expire_calc = \&CGI3::Object::Cookie::expire_calc;
*expires = \&CGI3::Object::Cookie::expires;
*filefield = \&CGI3::Object::Html::filefield;
*font = \&CGI3::Object::Html::font;
*fontsize = \&CGI3::Object::Html::fontsize;
*frame = \&CGI3::Object::Html::frame;
*frameset = \&CGI3::Object::Html::frameset;
*get_fields = \&CGI3::Object::Html::get_fields;
*h1 = \&CGI3::Object::Html::h1;
*h2 = \&CGI3::Object::Html::h2;
*h3 = \&CGI3::Object::Html::h3;
*h4 = \&CGI3::Object::Html::h4;
*h5 = \&CGI3::Object::Html::h5;
*h6 = \&CGI3::Object::Html::h6;
*head = \&CGI3::Object::Html::head;
*header = \&CGI3::Object::Response::header;
*hidden = \&CGI3::Object::Html::hidden;
*hr = \&CGI3::Object::Html::hr;
*html = \&CGI3::Object::Html::html;
*HtmlBot = \&CGI3::Object::Html::end_html;
*HtmlTop = \&CGI3::Object::Html::start_html;
*http = \&CGI3::Object::Request::http;
*https = \&CGI3::Object::Request::https;
*i = \&CGI3::Object::Html::i;
*ilayer = \&CGI3::Object::Html::ilayer;
*image_button = \&CGI3::Object::Html::image_button;
*img = \&CGI3::Object::Html::img;
*import_names = \&CGI3::Object::Misc::import_names;
*init = \&CGI3::Object::State::init;
*input = \&CGI3::Object::Html::input;
*isindex = \&CGI3::Object::Html::isindex;
*kbd = \&CGI3::Object::Html::kbd;
*keywords = \&CGI3::Object::Misc::keywords;
*layer = \&CGI3::Object::Html::layer;
*li = \&CGI3::Object::Html::li;
*Link = \&CGI3::Object::Html::Link;
*make_attributes = \&CGI3::Object::Html::make_attributes;
*menu = \&CGI3::Object::Html::menu;
*meta = \&CGI3::Object::Html::meta;
*MethGet = \&CGI3::Object::CGI3lib::MethGet;
*MethPost = \&CGI3::Object::CGI3lib::MethPost;
*MULTIPART = \&CGI3::Object::Html::MULTIPART;
*multipart_end = \&CGI3::Object::Multipart::multipart_end;
*multipart_init = \&CGI3::Object::Multipart::multipart_init;
*multipart_start = \&CGI3::Object::Multipart::multipart_start;
*new_MultipartBuffer = \&CGI3::Object::Multipart::new_MultipartBuffer;
*nextid = \&CGI3::Object::Html::nextid;
*nph = \&CGI3::Object::Response::nph;
*ol = \&CGI3::Object::Html::ol;
*option = \&CGI3::Object::Html::option;
*p = \&CGI3::Object::Html::p;
*Param = \&CGI3::Object::Html::Param;
*param = \&CGI3::Object::State::param;
*params = \&CGI3::Object::Misc::param_fetch;
*param_fetch = \&CGI3::Object::Misc::param_fetch;
*parse_keywordlist = \&CGI3::Object::Misc::parse_keywordlist;
*parse_params = \&CGI3::Object::State::parse_params;
*password_field = \&CGI3::Object::Html::password_field;
*path_info = \&CGI3::Object::Request::path_info;
*path_translated = \&CGI3::Object::Request::path_translated;
*popup_menu = \&CGI3::Object::Html::popup_menu;
*pre = \&CGI3::Object::Html::pre;
*previous_or_default = \&CGI3::Object::Html::previous_or_default;
*PrintHeader = \&CGI3::Object::Response::header;
*private_tempfiles = \&CGI3::Object::Multipart::private_tempfiles;
*protocol = \&CGI3::Object::Request::protocol;
*put = \&CGI3::Object::Misc::print;
*print = \&CGI3::Object::Misc::print;
*query_string = \&CGI3::Object::Request::query_string;
*raw_cookie = \&CGI3::Object::Misc::raw_cookie;
*raw_fetch = \&CGI3::Object::Misc::raw_fetch;
*radio_group = \&CGI3::Object::Html::radio_group;
*read_from_client = \&CGI3::Object::State::read_from_client;
*read_from_cmdline = \&CGI3::Object::Misc::read_from_cmdline;
*read_multipart = \&CGI3::Object::Multipart::read_multipart;
*ReadParse = \&CGI3::Object::CGI3lib::ReadParse;
*redirect = \&CGI3::Object::Response::redirect;
*referer = \&CGI3::Object::Request::referer;
*remote_addr = \&CGI3::Object::Request::remote_addr;
*remote_host = \&CGI3::Object::Request::remote_host;
*remote_ident = \&CGI3::Object::Request::remote_ident;
*remote_user = \&CGI3::Object::Request::remote_user;
*request_method = \&CGI3::Object::Request::request_method;
*reset = \&CGI3::Object::Html::reset;
*restore = \&CGI3::Object::Misc::restore;
*restore_parameters = \&CGI3::Object::new;
*samp = \&CGI3::Object::Html::samp;
*save = \&CGI3::Object::Misc::save;
*save_parameters = \&CGI3::Object::Misc::save;
*save_request = \&CGI3::Object::State::save_request;
*script = \&CGI3::Object::Html::script;
*script_name = \&CGI3::Object::Request::script_name;
*scrolling_list = \&CGI3::Object::Html::scrolling_list;
*Select = \&CGI3::Object::Html::Select;
*self_url = \&CGI3::Object::Request::self_url;
*server_name = \&CGI3::Object::Request::server_name;
*server_port = \&CGI3::Object::Request::server_port;
*server_protocol = \&CGI3::Object::Request::server_protocol;
*SERVER_PUSH = \&CGI3::Object::Multipart::SERVER_PUSH;
*server_software = \&CGI3::Object::Request::server_software;
*small = \&CGI3::Object::Html::small;
*span = \&CGI3::Object::Html::span;
*SplitParam = \&CGI3::Object::CGI3lib::SplitParam;
*start_form = \&CGI3::Object::Html::startform;
*start_html = \&CGI3::Object::Html::start_html;
*start_multipart_form = \&CGI3::Object::Html::start_multipart_form;
*startform = \&CGI3::Object::Html::startform;
*state = \&CGI3::Object::Request::self_url;
*strike = \&CGI3::Object::Html::strike;
*strong = \&CGI3::Object::Html::strong;
*style = \&CGI3::Object::Html::style;
*Sub = \&CGI3::Object::Html::Sub;
*submit = \&CGI3::Object::Html::submit;
*sup = \&CGI3::Object::Html::sup;
*table = \&CGI3::Object::Html::table;
*td = \&CGI3::Object::Html::td;
*textarea = \&CGI3::Object::Html::textarea;
*textfield = \&CGI3::Object::Html::textfield;
*th = \&CGI3::Object::Html::th;
*title = \&CGI3::Object::Html::title;
*tmpFileName = \&CGI3::Object::Multipart::tmpFileName;
*to_filehandle = \&CGI3::Object::Misc::to_filehandle;
*Tr = \&CGI3::Object::Html::Tr;
*TR = \&CGI3::Object::Html::TR;
*tt = \&CGI3::Object::Html::tt;
*u = \&CGI3::Object::Html::u;
*ul = \&CGI3::Object::Html::ul;
*uploadInfo = \&CGI3::Object::Multipart::uploadInfo;
*url = \&CGI3::Object::Request::url;
*URL_ENCODED = \&CGI3::Object::Html::URL_ENCODED;
*url_param = \&CGI3::Object::Misc::url_param;
*use_named_parameters = \&CGI3::Object::Misc::use_named_parameters;
*user_agent = \&CGI3::Object::Request::user_agent;
*user_name = \&CGI3::Object::Request::user_name;
*var = \&CGI3::Object::Html::var;
*virtual_host = \&CGI3::Object::Request::virtual_host;

*_reset_globals = \&initialize_globals;
*_make_tag_func = \&CGI3::Object::Html::_make_tag_func;
*_read_cookie_data = \&CGI3::Object::Cookie::_read_cookie_data;
*_script = \&CGI3::Object::Html::_script;
*_set_values_and_labels = \&CGI3::Object::Html::_set_values_and_labels;
*_style = \&CGI3::Object::Html::_style;
*_tableize = \&CGI3::Object::Html::_tableize;
*_textfield = \&CGI3::Object::Html::_textfield;


use Carp;

sub new
{
    my $class = shift;
    my $self = {
        '.parameters'=>[ ],
        '.named'=>0
    };

    if ($CGI3::MOD_PERL) {
        Apache->request->register_cleanup(\&CGI3::Object::_reset_globals);
        undef $NPH;
    }
    $self->_reset_globals if $CGI3::PERLEX;

    bless $self, ref $class || $class || 'CGI3::Object';

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
    $CGI3::AUTOLOAD_DEBUG = 0;

    # Change this to the preferred DTD to print in start_html()
    # or use default_dtd('text of DTD to use');
    $CGI3::DEFAULT_DTD = [ '-//W3C//DTD HTML 4.01 Transitional//EN',
                          'http://www.w3.org/TR/html4/loose.dtd' ] ;
    # Set this to 1 to enable NPH scripts
    # or:
    #    1) use CGI3 qw(-nph)
    #    2) $CGI3::nph(1)
    #    3) print header(-nph=>1)
    $CGI3::NPH = 0;

    # Set this to 1 to disable debugging from the
    # command line
    $CGI3::NO_DEBUG = 1;

    # Set this to 1 to make the temporary files created
    # during file uploads safe from prying eyes
    # or do...
    #    1) use CGI3 qw(:private_tempfiles)
    #    2) $CGI3::private_tempfiles(1);
    $CGI3::PRIVATE_TEMPFILES = 0;

    # Set this to a positive value to limit the size of a POSTing
    # to a certain number of bytes:
    $CGI3::POST_MAX = -1;

    # Change this to 1 to disable uploads entirely:
    $CGI3::DISABLE_UPLOADS = 0;

    # Change this to 1 to suppress redundant HTTP headers
    $CGI3::HEADERS_ONCE = 0;

    # The separator to divide parameters. Set this to a positive value
    # to enable new style URLS.
    $CGI3::USE_PARAM_SEMICOLONS = 0;

    # Other globals that you shouldn't worry about.
    undef $CGI3::Q;
    $CGI3::BEEN_THERE = 0;
    undef %CGI3::QUERY_PARAM;
    undef %CGI3::EXPORT;

    # prevent complaints by mod_perl
    1;
}

&initialize_globals;

if (exists $ENV{'GATEWAY_INTERFACE'})
{
    if ($CGI3::MOD_PERL = $ENV{'GATEWAY_INTERFACE'} =~ /^CGI3-Perl\//)
    {
        $| = 1;
        require Apache;
    }
    $CGI3::PERLEX++ if defined($ENV{'GATEWAY_INTERFACE'}) && $ENV{'GATEWAY_INTERFACE'} =~ /^CGI3-PerlEx/;
}

sub DESTROY { }
sub import {
    if (@_>1)
    {
        require CGI3;
        goto &CGI3::import;
    }
}

sub AUTOLOAD {
	if (!$AUTOLOAD) { die ("Can't find $AUTOLOAD at " . caller()); }
    my $name = *$AUTOLOAD{NAME};
    if ($name =~ /^start_|^end_/)
    {
        *$AUTOLOAD = \&{"CGI3::Object::Html::$name"};
        goto &{"CGI3::Object::Html::$name"};
    }
    Carp::croak("Function $AUTOLOAD does not exist");
}



unless ($CGI3::OS) {
    unless ($CGI3::OS = $^O) {
    require Config;
    $CGI3::OS = $Config::Config{'osname'};
    }
}
if ($CGI3::OS=~/Win/i) {
    $CGI3::OS = 'WINDOWS';
} elsif ($CGI3::OS=~/vms/i) {
    $CGI3::OS = 'VMS';
} elsif ($CGI3::OS=~/^MacOS$/i) {
    $CGI3::OS = 'MACINTOSH';
} elsif ($CGI3::OS=~/os2/i) {
    $CGI3::OS = 'OS2';
} else {
    $CGI3::OS = 'UNIX';
}

# Some OS logic.  Binary mode enabled on DOS, NT and VMS
$needs_binmode = $CGI3::OS=~/^(WINDOWS|VMS|OS2)/;

if ($needs_binmode) {
    binmode(main::STDOUT);
    binmode(main::STDIN);
    binmode(main::STDERR);
}

$CGI3::EBCDIC = "\t" ne "\011";
if ($CGI3::OS eq 'VMS') {
    $CGI3::CRLF = "\n";
} elsif ($CGI3::EBCDIC) {
    $CGI3::CRLF= "\r\n";
} else {
    $CGI3::CRLF = "\015\012";
}

$escape = qr/([^a-zA-Z0-9_.-])/;
$unescape = qr/%([0-9A-Fa-f]{2})/;

1;

# Copyright Lincoln Stein & David James 1999
