#!/usr/bin/perl

# This reads in a file with a binary AccessProtectionUserRules string and parses it, like mcafee85.eps and mcafee87.eps.
# It supports hexidecimal text and binary files (with -b; ***this is good for Oly***).
# Text files can optionally have spaces or new lines between the hex numbers - all non-hexidecimal chars are ignored.
# Hashes (slightly modified format for Perl) updated from 11/10/2009 version of scripts.

use strict;

my $file = shift;
my $line = '';

my $is_binary = ($file =~ /\-b/i);
if ($is_binary) {
  $file = shift;
  print "Binary mode...\n\n";
} else {
  print "Text mode...\n\n";
}

die "Usage: $0 [-b] FILENAME\n\t -b  read file as binary data (not ASCII hexidecimal chars)" unless $file;
 
open (FILE,"$file") or die "Can't open $file: $!\n";
while (my $temp = <FILE>) {
  chomp $temp;
  if ($is_binary) {
    foreach my $char (split(//,$temp)) {
      $line .= sprintf('%x',ord($char));
    }
  } else {
    $temp =~ s/[^a-fA-F0-9]//g;
    $line .= $temp if $temp;
  }
}
$line = uc($line);
print $line,"\n";

close(FILE);

my $defaultSettings = '41636365737350726f74656374696f6e207b0d0a7d0d0a';

my %hexhash = (
'55736572456E666F7263652041564F30342031' => "TRUE = Block remote creation/modification of executable and configuration files",
'55736572456E666F7263652041564F30342030' => "FALSE = Block remote creation/modification of executable and configuration files", 
'557365725265706F72742041564F30342031' => "TRUE = Log remote creation/modification of executable and configuration files",
'557365725265706F72742041564F30342030' => "FALSE = Log remote creation/modification of executable and configuration files",
'55736572456E666F7263652041564F30372031' => "TRUE = Block svchost executing non-Windows executables",
'55736572456E666F7263652041564F30372030' => "FALSE = Block svchost executing non-Windows executables", 
'57365725265706F72742041564F30372031' => "TRUE = Log svchost executing non-Windows executables", 
'557365725265706F72742041564F30372030' => "FALSE = Log svchost executing non-Windows executables", 
'55736572456E666F7263652043573031612031' => "\n!!!!!\nTRUE = Block programs registering to autorun\nWILL PREVENT PC INSTALL\n!!!!!", 
'55736572456E666F7263652043573031612030' => "FALSE = Block programs registering to autorun", 
'557365725265706F72742043573031612031' => "\n!!!!!\nTRUE = Log programs registering to autorun\nWILL LOG PC INSTALL\n!!!!!", 
'557365725265706F72742043573031612030' => "FALSE = Log programs registering to autorun", 
'55736572456E666F7263652043573031622031' => "\n!!!!!\nTRUE = Block programs registering as a service\nWILL PREVENT DG/ST/OLY/UR/YAK/DS INSTALL\n!!!!!",
'55736572456E666F7263652043573031622030' => "FALSE = Block programs registering as a service",
'557365725265706F72742043573031622031' => "\n!!!!!\nTRUE = Log programs registering as a service\nWILL LOG DG/ST/OLY/UR/YAK/DS INSTALL\n!!!!!", 
'557365725265706F72742043573031622030' => "FALSE = Log programs registering as a service",
'55736572456E666F7263652043573032612031' => "\n!!!!!\nTRUE = Block creation of new executable files in the Windows folder\nWILL PREVENT PC/OLY/UR/YAK INSTALL\n!!!!!", 
'55736572456E666F7263652043573032612030' => "FALSE = Block creation of new executable files in the Windows folder", 
'557365725265706F72742043573032612031' => "\n!!!!!\nTRUE = Log creation of new executable files in the Windows folder\nWILL LOG PC/OLY/UR/YAK INSTALL\n!!!!!", 
'557365725265706F72742043573032612030' => "FALSE = Log creation of new executable files in the Windows folder", 
'55736572456E666F7263652041564F30382031' => "TRUE = Block Windows process spoofing",
'55736572456E666F7263652041564F30382030' => "FALSE = Block Windows process spoofing",
'557365725265706F72742041564F30382031' => "TRUE = Log Windows process spoofing",
'557365725265706F72742041564F30382030' => "FALSE = Log Windows process spoofing",
'55736572456E666F7263652041565730322031' => "TRUE = Block cached files from password and email address stealers",
'55736572456E666F7263652041565730322030' => "FALSE = Block cached files from password and email address stealers",
'557365725265706F72742041565730322031' => "TRUE = Log cached files from password and email address stealers",
'557365725265706F72742041565730322030' => "FALSE = Log cached files from password and email address stealers",
'557365725265706f72742041534f30312031' => "\n!!!!!\nTRUE = AntiSpyware: Protect Internet Explorer favorites and settings (Logging)\nWILL LOG ANY VAL/OLY/UR CONNECTIONS\n!!!!!",
'557365725265706f72742041534f30312030' => "\n!!!!!\nFALSE = AntiSpyware: Protect Internet Explorer favorites and settings (Logging)\nWas enabled at some point. Would have logged ANY VAL/OLY/UR connections\n!!!!!",
'55736572456e666f7263652041534f30312031' => "\n!!!!!\nTRUE = AntiSpyware: Protect Internet Explorer favorites and settings (Blocking)\nWILL BLOCK AND LOG ANY VAL/OLY/UR CONNECTIONS\n!!!!!",
'55736572456e666f7263652041534f30312030' => "\n!!!!!\nFALSE = AntiSpyware: Protect Internet Explorer favorites and settings (Blocking)\nWas enabled at some point. Would have blocked/logged ANY VAL/OLY/UR connections\n!!!!!",
'557365725265706f72742041535730322031' => "TRUE = AntiSpyware: Prevent all programs from running files from the Temp folder",
'557365725265706f72742041535730322030' => "FALSE = AntiSpyware:  Prevent all programs from running files from the Temp folder",
'55736572456e666f7263652041535730322031' => "TRUE = AntiSpyware:  Prevent all programs from running files from the Temp folder",
'55736572456e666f7263652041535730322030' => "FALSE = AntiSpyware: Prevent all programs from running files from the Temp folder",
'55736572456e666f7263652043573032622031' => "\n!!!!!\n True = Block creation of new executable files in the Program Files folder\nWatch where you drop files.\n!!!!!", 
'55736572456e666f7263652043573032622030' => "\n!!!!!\n False = Block creation of new executable files in the Program Files folder\nWas enabled at some time.\n!!!!!", 
'557365725265706f72742043573032622031' => "\n!!!!!\n True = Log creation of new executable files in the Program Files folder\nWatch where you drop files.\n!!!!!", 
'557365725265706f72742043573032622030' => "\n!!!!!\n False = Log creation of new executable files in the Program Files folder\nWatch where you drop files.\n!!!!!", 
'55736572456e666f72636520435730362031' => "\n!!!!!\n TRUE = Block HTTP Communication\nChoose your ports wisely.\n!!!!!",
'557365725265706f727420435730362031' => "\n!!!!!\n TRUE = Log HTTP Communication\nChoose your ports wisely.\n!!!!!",
'55736572456e666f72636520435730362030' => "FALSE = Block HTTP Communication",
'557365725265706f727420435730362030' => "FALSE = Log HTTP Communication",
'55736572456e666f72636520435730352031' => "\n!!!!!\n TRUE = Block FTP Communication\nChoose your ports wisely.\n!!!!!",
'557365725265706f727420435730352031' => "\n!!!!!\n TRUE = Log FTP Communication\nChoose your ports wisely.\n!!!!!",
'55736572456e666f72636520435730352030' => "FALSE = Block FTP Communication",
'557365725265706f727420435730352030' => "FALSE = Log FTP Communication",
'55736572456e666f72636520434f30362031' => "TRUE = Block installation of Browser Helper Objects and Shell Extensions",
'557365725265706f727420434f30362031' => "TRUE = Log installation of Browser Helper Objects and Shell Extensions",
'55736572456e666f72636520434f30362030' => "FALSE = Block installation of Browser Helper Objects and Shell Extensions",
'557365725265706f727420434f30362030' => "FALSE = Log installation of Browser Helper Objects and Shell Extensions",
'55736572456e666f72636520434f31322031' => "\n!!!!!\nTRUE = Protect Network Settings\nWill BLOCK PC2 install\n!!!!!",
'55736572456e666f72636520434f31322030' => "FALSE = (Block) Protect Network Setting",
'557365725265706f727420434f31322031' => "\n!!!!!\nTRUE = (Log) Protect Network Settings\nWill LOG PC2 install\n!!!!!",
'557365725265706f727420434f31322030' => "FALSE = (Log) Protect Network Setting",
);

if ($line =~ /$defaultSettings/i) {
  print "They are using the default settings for a McAfee 8.5 install.\nYou should be good.";
} else {
  foreach (keys(%hexhash)) {
    print $hexhash{$_},"\n" if $line =~ /$_/i;
  }
}

### uncomment if you want to print chars as ASCII - may contain unprintable chars (like bell sound)
#print "Printing all hex values as ASCII chars:\n";
#foreach($line =~ /[a-fA-F0-9]{2}/g) {
#  print chr(sprintf('%d',$_));
#}
#print "\nDone decoding.\n";
