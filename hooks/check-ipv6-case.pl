#!/usr/bin/perl

#
# commit hook to check IPv6 literals are capitalized
#

use strict;
use Getopt::Long;
use Term::ANSIColor;
use Regexp::IPv6 qw($IPv6_re);

my (@errs, $file, $fix);
my $color = -t STDERR;    # default to using color if connected to tty
GetOptions('fix!' => \$fix, 'color!' => \$color) || usage();
$^I = '*' if $fix;
$ENV{'ANSI_COLORS_DISABLED'} = not $color;
usage() unless scalar @ARGV;

# check each file
while (<>) {
  $. = 1 if $file ne $ARGV;
  if (grep { /[A-F]/ } /($IPv6_re)/g) {

    # for each IP in a line, highlight each set of capital hex chars
    (my $line = $_) =~ s{$IPv6_re}{
                          $& =~ s{[A-F]+}
                          {colored($&,'on_red')}ger
                        }ge;

    push @errs, colored("$ARGV line $.:", 'green'), $line;

    # downcase all IPv6 addresses on line
    s/$IPv6_re/lc($&)/ge if $fix;
  }
} continue {
  $file = $ARGV;
  print if $fix;
}

# output any errors
if (scalar @errs) {
  print STDERR colored(  "Literal IPv6 address with capital hex letters "
                       . ($fix ? "fixed" : "found")
                       . ":", 'red'), "\n";
  print STDERR @errs;
  exit 1;
}

sub usage {
  print STDERR "$0 [--fix|--nofix] [--color|--nocolor] [files...]\n";
  exit 1;
}
