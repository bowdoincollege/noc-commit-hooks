#!/usr/bin/perl

#
# commit hook to check if MAC addresses are capitalized
#

use strict;
use Getopt::Long;
use Term::ANSIColor;

my $MAC_re = '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}';
my @errs;
my $fix;
my $color = -t STDERR;    # default to using color if connected to tty
GetOptions('fix!' => \$fix, 'color!' => \$color) || usage();
$^I = '*' if $fix;
$ENV{'ANSI_COLORS_DISABLED'} = not $color;
usage() unless scalar @ARGV;

# check each file
while (<>) {
  if (grep { /[A-F]/ } /($MAC_re)/g) {

    # for each MAC address in a line, highlight each set of capital hex chars
    (my $line = $_) =~ s{$MAC_re}{
                          $& =~ s{[A-F]+}
                          {colored($&,'on_red')}ger
                        }ge;

    push @errs, colored("$ARGV line $.:", 'green'), $line;

    # downcase all MAC addresses on line
    s/$MAC_re/lc($&)/ge if $fix;
  }
} continue {
  print if $fix;
}

# output any errors
if (scalar @errs) {
  print STDERR colored(  "MAC address with capital hex letters "
                       . ($fix ? "fixed" : "found")
                       . ":", 'red'), "\n";
  print STDERR @errs;
  exit 1;
}

sub usage {
  print STDERR "$0 [--fix|--nofix] [--color|--nocolor] [files...]\n";
  exit 1;
}
