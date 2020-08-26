use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME    => 'Local::CommitHooks',
  VERSION => "0.04",
  EXE_FILES => [
    qw(
      hooks/check-ipv6-case.pl
      hooks/check-macaddr-case.pl
      )
  ],
  PREREQ_PM => { "Term::ANSIColor" => "4",
                 "Regexp::IPv6"    => "0.03",
               },
  TEST_REQUIRES => { "Test::Script" => "1.23",
                     "Devel::Cover" => "1.32",
                   },
  test => { TESTS => 'tests/*.t' }
             );
