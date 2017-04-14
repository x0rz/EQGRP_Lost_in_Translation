#!/usr/bin/perl
use strict;
#This file is used to accomodate the corner case when a machine has a reaaaaaaaaly long registry value
#07-Jan-09 Initial creation
my $file = shift;
my $line = '';
die "Usage: $0 FILENAME" unless $file;
open (FILE,"$file") or die "Can't open $file: $!\n";
while (my $temp = <FILE>) {
  $temp =~ s/\s+//g;
  $line .= uc($temp);
}
close(FILE);
print "Starting Perl parsing. In this case, no output != 100% safe\n\n";

my %hexhash = (
'55736572456E666F7263652041564F30342031' => "BLOCK remote creation/modification of executable and configuration files\n	!!!WILL PREVENT ZB ATTEMPT: USE ZZ!!!\n",
#'55736572456E666F7263652041564F30342030' => "FALSE = Block remote creation/modification of executable and configuration files\n", 
'557365725265706F72742041564F30342031' => "LOG Remote creation/modification of executable and configuration files\n	!!!WILL LOG ZB ATTEMPT: USE ZZ!!!\n",
#'557365725265706F72742041564F30342030' => "FALSE = Log remote creation/modification of executable and configuration files\n",
'55736572456E666F7263652041564F30372031' => "BLOCK Svchost executing non-Windows executables\n	!!!WILL LOG DRIVERS -LIST IN DSZ!!!\n",
#'55736572456E666F7263652041564F30372030' => "FALSE = Block svchost executing non-Windows executables\n", 
'557365725265706F72742041564F30372031' => "LOG Svchost executing non-Windows executables\n	!!!WILL LOG DRIVERS -LIST IN DSZ!!!\n", 
#'557365725265706F72742041564F30372030' => "FALSE = Log svchost executing non-Windows executables\n", 
'55736572456E666F7263652043573031612031' => "BLOCK Programs registering to autorun\n	!!!WILL PREVENT PC INSTALL!!!\n", 
#'55736572456E666F7263652043573031612030' => "FALSE = Block programs registering to autorun\n", 
'557365725265706F72742043573031612031' => "LOG Programs registering to autorun\n	!!!WILL LOG PC INSTALL!!!\n", 
#'557365725265706F72742043573031612030' => "FALSE = Log programs registering to autorun\n", 
'55736572456E666F7263652043573031622031' => "BLOCK Programs registering as a service\n	!!!WILL PREVENT DG/FLAV/ST/OLY/YAK/DS INSTALL!!!\n",
#'55736572456E666F7263652043573031622030' => "FALSE = Block programs registering as a service\n",
'557365725265706F72742043573031622031' => "LOG Programs registering as a service\n	!!!WILL LOG DG/FLAV/ST/OLY/YAK/DS INSTALL!!!\n", 
#'557365725265706F72742043573031622030' => "FALSE = Log programs registering as a service\n",
'55736572456E666F7263652043573032612031' => "BLOCK Creation of new EXE/DLL in the Windows folder\n	!!!WILL PREVENT PC/OLY/UR/YAK INSTALL!!!\n", 
#'55736572456E666F7263652043573032612030' => "FALSE = Block creation of new EXE/DLL in the Windows folder\n", 
'557365725265706F72742043573032612031' => "LOG Creation of new EXE/DLL in the Windows folder\n	!!!WILL LOG PC/OLY/UR/YAK INSTALL!!!\n", 
#'557365725265706F72742043573032612030' => "FALSE = Log creation of new EXE/DLL in the Windows folder\n", 
'55736572456E666F7263652041564F30382031' => "BLOCK Windows process spoofing\n	!!!DONT USE COMMON WINDOWS NAMES!!!\n",
#'55736572456E666F7263652041564F30382030' => "FALSE = Block Windows process spoofing\n",
'557365725265706F72742041564F30382031' => "LOG Windows process spoofing\n	!!!DONT USE COMMON WINDOWS NAMES!!!\n",
#'557365725265706F72742041564F30382030' => "FALSE = Log Windows process spoofing\n",
'55736572456E666F7263652041565730322031' => "BLOCK Cached files from password and email address stealers \n	!!!WILL PREVENT UR/MB RUNNING!!!\n",
#'55736572456E666F7263652041565730322030' => "FALSE = Block cached files from password and email address stealers\n",
'557365725265706F72742041565730322031' => "LOG Cached files from password and email address stealers\n	!!!WILL PREVENT UR/MB RUNNING!!!\n",
#'557365725265706F72742041565730322030' => "FALSE = Log cached files from password and email address stealers\n",
'557365725265706f72742041534f30312031' => "LOG Protect Internet Explorer favorites and settings \n	!!!WILL LOG ANY VAL/OLY/UR CONNECTIONS!!!\n",
#'557365725265706f72742041534f30312030' => "FALSE = Log Protect Internet Explorer favorites and settings \nWas enabled at some point. Would have logged ANY VAL/OLY/UR connections\n",
'55736572456e666f7263652041534f30312031' => "BLOCK Protect Internet Explorer favorites and settings \n	!!!WILL BLOCK AND LOG ANY VAL/OLY/UR CONNECTIONS!!!\n",
#'55736572456e666f7263652041534f30312030' => "FALSE = Block Protect Internet Explorer favorites and settings \nWas enabled at some point. Would have blocked/logged ANY VAL/OLY/UR connections\n",
'557365725265706f72742041535730322031' => "LOG Prevent all programs from running files from the Temp folder\n	!!!WILL LOG DMW RUNNING!!!\n",
#'557365725265706f72742041535730322030' => "FALSE = Log Prevent all programs from running files from the Temp folder\n",
'55736572456e666f7263652041535730322031' => "BLOCK Prevent all programs from running files from the Temp folder\n	!!!WILL LOG DMW RUNNING!!!\n",
#'55736572456e666f7263652041535730322030' => "FALSE = Block Prevent all programs from running files from the Temp folder\n",
'55736572456e666f7263652043573032622031' => "BLOCK Creation of new EXE/DLL in the Program Files folder\n	!!!WATCH WHERE YOU DROP FILES!!!\n", 
#'55736572456e666f7263652043573032622030' => "FALSE = Block creation of new EXE/DLL in the Program Files folder\n	Was enabled at some time.\n", 
'557365725265706f72742043573032622031' => "LOG Creation of new EXE/DLL in the Program Files folder\n	!!!WATCH WHERE YOU DROP FILES!!!\n", 
#'557365725265706f72742043573032622030' => "FALSE = Log creation of new EXE/DLL in the Program Files folder\n	!!!Watch where you drop files!!!\n", 
'55736572456e666f72636520435730362031' => "BLOCK HTTP Communication\n	!!!AVOID PORTS 80/443/CANGETOUT!!!\n",
'557365725265706f727420435730362031' => "LOG HTTP Communication\n	!!!AVOID PORTS 80/443/CANGETOUT!!!\n",
#'55736572456e666f72636520435730362030' => "FALSE = Block HTTP Communication\n",
#'557365725265706f727420435730362030' => "FALSE = Log HTTP Communication\n",
'55736572456e666f72636520435730352031' => "BLOCK FTP Communication\n	!!!AVOID PORT 20!!!\n",
'557365725265706f727420435730352031' => "LOG FTP Communication\n	!!!AVOID PORT 20!!!\n",
#'55736572456e666f72636520435730352030' => "FALSE = Block FTP Communication\n",
#'557365725265706f727420435730352030' => "FALSE = Log FTP Communication\n",
'55736572456e666f72636520434f30362031' => "BLOCK Installation of Browser Helper Objects and Shell Extensions\n",
'557365725265706f727420434f30362031' => "LOG Installation of Browser Helper Objects and Shell Extensions\n",
#'55736572456e666f72636520434f30362030' => "FALSE = Block installation of Browser Helper Objects and Shell Extensions\n",
#'557365725265706f727420434f30362030' => "FALSE = Log installation of Browser Helper Objects and Shell Extensions\n",
'55736572456e666f72636520434f31322031' => "BLOCK Protect Network Settings\n	!!!WILL BLOCK PC2 INSTALL!!!\n",
#'55736572456e666f72636520434f31322030' => "FALSE = (Block) Protect Network Setting\n",
'557365725265706f727420434f31322031' => "LOG Protect Network Settings\n	!!!WILL LOG PC2 INSTALL!!!\n",
#'557365725265706f727420434f31322030' => "FALSE = Log Protect Network Setting\n",
'55736572456E666F726365204153573031' => "BLOCK Prevent installation of new CLSIDs, APPIDs and TYPELIBs\n	!!!WILL BLOCK VAL INSTALL!!!\n",
'557365725265706F72742041535730312031' => "LOG Prevent installation of new CLSIDs, APPIDs and TYPELIBs\n	!!!WILL LOG VAL INSTALL!!!\n",
'55736572456E666F7263652041564F31302031' => "BLOCK Prevent mass mailing worm from sending mail\n	!!!AVOID PORT 25/110/587!!!\n",
'557365725265706F72742041564F31302031' => "LOG Prevent mass mailing worm from sending mail\n	!!!AVOID PORT 25/110/587!!!\n",
'557365725265706F7274204F4230312031' => "LOG Make shares read-only\n	!!!WILL LOG ZB ATTEMPT!!!\n",
'55736572456E666F726365204F4230312031' => "BLOCK Make shares read-only\n	!!!WILL BLOCK ZB ATTEMPT!!!\n",
'557365725265706F7274204F4230312031' => "BLOCK Block read and write access to all shares\n	!!!WILL BLOCK ZB ATTEMPT!!!\n",
'55736572456E666F726365204F4230312031' => "LOG Block read and write access to all shares\n	!!!WILL LOG ZB ATTEMPT!!!\n",
);

foreach (keys(%hexhash)) {
    print $hexhash{$_},"\n" if $line =~ /$_/i;
}


