use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'CGI',
    'DISTNAME'  => 'CGI.pm',
    'VERSION'   => '2.13',
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'compress', 'SUFFIX' => 'Z'}
);
