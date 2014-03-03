use 5.014002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WebService::Bitstamp',
    VERSION_FROM      => 'lib/WebService/Bitstamp.pm', # finds $VERSION
    PREREQ_PM         => {
	 	Mojolicious	=> 4.0,
	 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WebService/Bitstamp.pm', # retrieve abstract from module
       VERSION_FROM   => 'lib/WebService/Bitstamp.pm',
       AUTHOR         => 'Sven Eppler <cpan@sveneppler.de>') : ()),
);
