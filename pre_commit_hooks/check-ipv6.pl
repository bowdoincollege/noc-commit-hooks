#!/usr/bin/perl

use strict;
use Regexp::IPv6;

exit 1 if /($IPv6_re)/ and $1 =~ /[A-F]/;
