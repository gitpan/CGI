use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'INSTALLDIRS' => 'perl',
    'NAME'	=> 'CGI3',
    'DISTNAME'  => 'CGI3.pm',
    'VERSION_FROM'   => 'CGI3.pm',
    'PMLIBDIRS'    => ['CGI3'],
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'}
);
