use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
print STDERR "*** WARNING: This is ALPHA SOFTWARE. *** \n";
print STDERR "*** For production systems, use the CGI 2.X series. ***\n";
WriteMakefile(
    'INSTALLDIRS' => 'perl',
    'NAME'	=> 'CGI3',
    'DISTNAME'  => 'CGI.pm',
    'VERSION_FROM'   => 'CGI.pm',
    'PMLIBDIRS'    => ['CGI'],
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'}
);
