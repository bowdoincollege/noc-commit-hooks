#!/usr/bin/perl

#
# commit hook to check IPv6 literals are capitalized
#

use strict;
use Getopt::Long;
use Term::ANSIColor;

# from Regexp::IPv6
my $IPv4 =
    "((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.]"
  . "(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.]"
  . "(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.]"
  . "(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}))";
my $G = "[0-9a-fA-F]{1,4}";
my @tail = (":",
            "(:($G)?|$IPv4)",
            ":($IPv4|$G(:$G)?|)",
            "(:$IPv4|:$G(:$IPv4|(:$G){0,2})|:)",
            "((:$G){0,2}(:$IPv4|(:$G){1,2})|:)",
            "((:$G){0,3}(:$IPv4|(:$G){1,2})|:)",
            "((:$G){0,4}(:$IPv4|(:$G){1,2})|:)"
           );
my $IPv6_re = $G;
$IPv6_re = "$G:($IPv6_re|$_)" for @tail;
$IPv6_re = qq/:(:$G){0,5}((:$G){1,2}|:$IPv4)|$IPv6_re/;
$IPv6_re =~ s/\(/(?:/g;

my @errs;
my $fix;
my $color = -t STDERR;    # default to using color if connected to tty
GetOptions('fix!' => \$fix, 'color!' => \$color) || usage();
$^I = '*' if $fix;
$ENV{'ANSI_COLORS_DISABLED'} = not $color;
usage() unless scalar @ARGV;

# check each file
while (<>) {
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
