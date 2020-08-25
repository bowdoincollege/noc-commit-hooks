use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
  NAME          => 'Local::CommitHooks',
  VERSION       => "0.03",
  EXE_FILES     => [qw(hooks/check-ipv6-case.pl hooks/check-macaddr-case.pl)],
  PREREQ_PM     => { "Term::ANSIColor" => 0, "Regexp::IPv6" => 0 },
  TEST_REQUIRES => { "Test::Script" => 0, "Devel::Cover" => 0 },
  test          => { TESTS => 'tests/*.t' }
             );
