use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'         => 'Data::Pointer',
    'VERSION_FROM' => 'Pointer.pm', # finds $VERSION
    'PREREQ_PM'    => {
    	'Want'        => 0.05,
    	'Tie::File'	  => 0.93,
    	'Tie::IxHash' => 1.12,
    },
);
