#!/usr/bin/perl

#
# commit hook to check if MAC addresses are capitalized
#

use strict;
use Getopt::Long;
use Term::ANSIColor;

my $MAC_re = '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}';

# disable colors if not connected to a terminal
$ENV{'ANSI_COLORS_DISABLED'} = 1 unless -t STDERR;

my @errs;
my $fix;
GetOptions('fix!' => \$fix) || usage();
$^I = '*' if $fix;
usage() unless scalar @ARGV;

# check each file
while (<>) {
  if (/($MAC_re)/ and $1 =~ /[A-F]/) {

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
  print STDERR "$0 [--fix|--nofix] [files...]\n";
  exit 1;
}
