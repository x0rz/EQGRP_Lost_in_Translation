#!/usr/bin/perl -wn
use strict;
s/\s//g;
print chr hex $1 while /([[:xdigit:]]{2})/g;
print "\n";
