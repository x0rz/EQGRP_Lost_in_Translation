
package      ExploitUtils;

use strict;
autoflush STDOUT 1;

require Exporter;
@ExploitUtils::ISA = qw(Exporter);
@ExploitUtils::EXPORT_OK = qw(
	$EU_LOGFILE
	$EU_VERBOSE
	$EU_BATCHMODE
	@EU_SERVICES
	EU_LogInit
	EU_Log
	EU_ExitMessage
	EU_ExitMessageWait
	EU_GetInput
	EU_GetNum
	EU_GetAbsPath
	EU_GetExistingDir
	EU_GetExploitConfig
	EU_GetProtocol
	EU_GetIP
	EU_GetLocalIP
	EU_GetIPX
	EU_GetGenRootDir
	EU_GetRootDir
	EU_GetPort
	EU_GetPayloadFile
	EU_RunCommand
	EU_StopServices
	EU_StartServices
	EU_AdjustService
	EU_SaveEventLogs
	EU_ClearEventLogs
	EU_StartNetmon
	EU_StopNetmon
	EU_CleanDir
	EU_RunAndLog
	EU_TraceRoute
	EU_GetChoice
	EU_GetAddr
);


use vars qw($EU_LOGFILE $EU_VERBOSE $EU_BATCHMODE @EU_SERVICES);


$ExploitUtils::EU_VERBOSE		= 0;	
$ExploitUtils::EU_BATCHMODE		= 0;	


@ExploitUtils::EU_SERVICES = (
	"Alerter",           
	"Browser",           
	"Cisvc",             
	"DNS",               
	"LicenseService",    
	"Messenger",         
	"MSDTC",             
	"MSFTPSVC",          
	"MSIServer",         
	"Netlogon",          
	"PlugPlay",          
	"Schedule",          
	"SMTPSVC",           
	"Spooler",           
	"W3SVC",             
	"RPCLOCATOR",        

	"IISAdmin",          

	"LanmanServer",      
	"LanmanWorkstation", 
	"LmHosts",           
	"NtLmSsp",           
	"ProtectedStorage",  



);


use FindBin;				
use FileHandle;				
use File::Spec::Functions;	
use Cwd;					
use File::Path;				
use Sys::Hostname;			
use Socket;					
use Win32::Service;			


sub EU_LogInit() {
	my ($logprefix, $logsuffix, $logdir) = @_;
	my $logfilefmt = "${logprefix}%04d%02d%02d_%02d%02d%02d${logsuffix}"; 
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

	(-d $logdir) || die("*** Error: Directory for logging ($logdir) doesn't exist.\n");
	(-w $logdir) || die("*** Error: Directory for logging ($logdir) isn't writable.\n");

	$year += 1900;
	$mon  += 1;

	my $logfilename = sprintf($logfilefmt,$year,$mon,$mday,$hour,$min,$sec);

	$ExploitUtils::EU_LOGFILE = $logdir . "\\" . $logfilename;

	&EU_Log(1,"Exploitation log file: $ExploitUtils::EU_LOGFILE\n");
}



sub EU_Log() {
	my ($printStdout,$msg) = @_;
	my $logfile = new FileHandle;
	print "$msg\n" if ($printStdout || $ExploitUtils::EU_VERBOSE);

	if (defined $ExploitUtils::EU_LOGFILE) {
		open $logfile, ">>$ExploitUtils::EU_LOGFILE" || die("*** Error: unable to open logfile: $ExploitUtils::EU_LOGFILE");
		print $logfile "$msg\n";
		close $logfile;
	}
}



sub EU_ExitMessage() {
	my ($exit_code, $msg, $wait) = @_;
	&EU_Log(1,"$msg");
	if ($wait) {
		if (! $ExploitUtils::EU_BATCHMODE) {
			print "\nPress <Enter> to exit";
			my $input = <>;
		}
	}
	exit($exit_code);
}



sub EU_ExitMessageWait() {
	my ($exit_code, $msg) = @_;
	&EU_ExitMessage($exit_code, $msg, 1);
}



sub EU_GetInput() {
  my ($prompt, $defVal) = @_;
  my $input;
  
  if ($ExploitUtils::EU_BATCHMODE) {
    return $defVal;
  } else {
    print "$prompt";
    my $input = <>;
    if (lc($input) =~ /^\s*quit\s*$/) {
      &EU_ExitMessage(1,"User terminated script.");
    }
    elsif ("$input" =~ /^\s*$/) {
      return $defVal;
    } else {
      chomp($input);
      $input =~ s/^(\s*)(.*)/$2/;
      return $input;
    }
  }
}


sub EU_GetNum() {
	my ($prompt, $defVal) = @_;
	my $num;

	while (1) {
		if (defined $defVal) {
			$num = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} else {
			$num = &EU_GetInput("$prompt: ","");
		}

		if ($num =~ /^\d+$/) {
			return $num;
		} else {
			print "\"$num\" is not a valid numeric value.\n";
			print "You must enter a numeric value.\n\n";
		}
	}
}




sub EU_GetAbsPath() {
	my $path = $_[0];

	if (! -d $path) {
		return undef;
	} else {
		my $cdir = cwd();
		chdir $path || return undef;
		$path = cwd();
		chdir $cdir || &EU_ExitMessage(1,"Function EU_GetAbsPath unable to cd back to $cdir");
		$path =~ s/\//\\/g;
		return $path;
	}
}



sub EU_GetExistingDir() {
	my ($prompt, $defDir, $createFlag) = @_;
	my $dir;
	my $rtnDir;

	if (! defined $defDir) {
		$defDir = ".";
	}

	while (1) {
		$dir = &EU_GetInput("$prompt [$defDir]: ",$defDir);
		if ((! -d $dir) && $createFlag) {
			my $inp = &EU_GetInput("$dir doesn't exist. Create it ([y],n)? ","y");
			if (lc($inp) eq "y") {
				&EU_Log(0,"Attempting to create $dir");
				mkpath($dir,$ExploitUtils::EU_VERBOSE,0);
			}
		}
		if ($rtnDir = &EU_GetAbsPath($dir)) {
			return $rtnDir;
		} elsif ($ExploitUtils::EU_BATCHMODE) {
			&EU_ExitMessage(1,"Unable to open $dir.");
		} else {
			print "Unable to open $dir.\n";
			print "Please specify an alternate path.\n\n";
		}
	}
}


sub EU_GetProtocol() {
	my ($prompt, $defVal) = @_;
	my $protocol;

	while (1) 
	{
		if (defined $defVal) 
		{
			$protocol = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} 
		else 
		{
			$protocol = &EU_GetInput("$prompt: ","");
		}

		if ($protocol == 1 || $protocol == 2)
		{
			return $protocol;
		} 
		elsif ($ExploitUtils::EU_BATCHMODE) 
		{
			&EU_ExitMessage(1,"Invalid connection protocol ($protocol) specified.");
		} 
		else 
		{
			print "\"$protocol\" is not a valid connection protocol.\n";
			print "You must enter a connection protocol as either:\n";
			print "     1 = TCP\n";
			print "     2 = SPX\n";
		}
	}
}


sub EU_GetIPX() {
	my ($prompt, $defVal) = @_;
	my $ipx;
	my $len;

	while (1) 
	{
		if (defined $defVal) 
		{
			$ipx = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} 
		else 
		{
			$ipx = &EU_GetInput("$prompt: ","");
		}

		if ($ipx =~ /^\s*[A-Fa-f0-9]{8}\.[A-Fa-f0-9]{12}\s*$/) 
		{
			return $ipx;
		} 
		elsif ($ExploitUtils::EU_BATCHMODE) 
		{
			&EU_ExitMessage(1,"Invalid IPX address ($ipx) specified.");
		} 
		else 
		{
			print "\"$ipx\" is not a valid IPX address.\n";
			print "You must enter an IPX address of the form xxxxxxxx.xxxxxxxxxxxx.\n\n";
		}
	}
}



sub EU_GetIP() {
	my ($prompt, $defVal) = @_;
	my $ip;

	while (1) {
		if (defined $defVal) {
			$ip = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} else {
			$ip = &EU_GetInput("$prompt: ","");
		}

		if ($ip =~ /^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s*$/) {
			return $ip;
		} elsif ($ExploitUtils::EU_BATCHMODE) {
			&EU_ExitMessage(1,"Invalid IP address ($ip) specified.");
		} else {
			print "\"$ip\" is not a valid IP address.\n";
			print "You must enter an IP address of the form ddd.ddd.ddd.ddd.\n\n";
		}
	}
}



sub EU_GetLocalIP() {
	my ($prompt, $defVal) = @_;
	my $ip;

	if (defined $defVal) {
		return &EU_GetIP($prompt, $defVal);
	} else {
		my $host = hostname();
		my ($name, $aliases, $addrtype, $length, @addrs) = gethostbyname($host);
		my $num_addresses = scalar @addrs;
		if ($num_addresses == 0) { 
			return &EU_GetIP($prompt, $defVal);
		} else {
			if ($num_addresses > 1) { 
				&EU_Log(1,"Multiple IP addresses found on this host:\n");
				my $i;
				for ($i = 0; $i < $num_addresses; $i++) {
					&EU_Log(1,"\t".inet_ntoa($addrs[$i]));
				}
				&EU_Log(1,"\n");
			}
			return &EU_GetIP($prompt, inet_ntoa($addrs[0]));
		}
	}
}



sub EU_GetGenRootDir() {
	my ($prompt, $root_dir, @files) = @_;
	my $file;
	my $okay;

	while (1) {
		$root_dir = &EU_GetExistingDir("$prompt", $root_dir, 0);

		$okay = 1;
		foreach $file (@files) {
			my $dir = "$root_dir\\";
			if ($file =~ /^[a-zA-Z]:.*$/) {
				$dir = "";
			} else {
				if (! -e "$dir$file") {
					&EU_Log(1,"Unable to find $file beneath specified directory ($dir)");
					$okay = 0;
					last;
				}
				if ($ExploitUtils::EU_VERBOSE) {
					print "\tFound $file beneath $dir\n";
				}
			}
		}
		if ($okay) {
			return($root_dir);
		}
		elsif ($ExploitUtils::EU_BATCHMODE) {
			&EU_ExitMessage(1,"Invalid root directory.");
		} else {
			&EU_Log(1,"Unable to use $root_dir as the root directory.");
		}
	}
}


sub EU_GetRootDir() {
	my ($root_dir, @files) = @_;

	return &EU_GetGenRootDir("Enter root directory", $root_dir, @files);

}



sub EU_GetPort() {
	my ($prompt, $defVal) = @_;
	my $port;

	while (1) {
		if (defined $defVal) {
			$port = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} else {
			$port = &EU_GetInput("$prompt: ","");
		}

		if ($port =~ /^\s*\d+\s*$/) {
			return $port;
		} elsif ($ExploitUtils::EU_BATCHMODE) {
			&EU_ExitMessage(1,"Invalid port ($port) specified.");
		} else {
			print "\"$port\" is not a valid port.\n";
			print "You must enter a numeric port value.\n\n";
		}
	}
}



sub EU_GetPayloadFile() {
	my ($prompt, $defVal) = @_;
	my ($pfile, $vol, $dir);

	if ($defVal =~ /^(.*):(.*)([a-zA-Z]):(.*)$/) {
		$defVal = "$3:$4";
	}

	while (1) {
		if (defined $defVal) {
			$pfile = &EU_GetInput("$prompt [$defVal]: ",$defVal);
		} else {
			$pfile = &EU_GetInput("$prompt: ","");
		}

		($vol, $dir, $pfile) = File::Spec->splitpath($pfile);
		if (defined $vol && $vol ne "") {
			$dir = &EU_GetAbsPath("$vol\\$dir");
		} else {
			$dir = &EU_GetAbsPath($dir);
		}
		$pfile = "$dir\\$pfile";

		if (-f $pfile) {
			return $pfile;
		} elsif ($ExploitUtils::EU_BATCHMODE) {
			&EU_ExitMessage(1,"Invalid payload file ($pfile) specified.");
		} else {
			print "\"$pfile\" doesn't exist.\n";
			print "You must specify an existing file.\n\n";
		}
	}
}



sub EU_RunCommand() {
	my ($cmd, $noExitFlag) = @_;
	my $rv;

	&EU_Log(0,"Running command: $cmd");
	$rv = system("\"$cmd\"");
	if ($rv) {
		$rv = system("$cmd");
		if ($rv) {
			if ($noExitFlag) {
				&EU_Log(1,"\nUnable to execute command (or command didn't return success status).");
			} else {
				&EU_ExitMessage(1,"\nUnable to execute command (or command didn't return success status).");
			}
		}
	}
	return $rv;
}



sub EU_StopServices() {
	my (@services) = @_;
	my $service;
	my $rv;
	my $okay = 1;

	&EU_Log(1,"\nAttempting to stop appropriate services.");
	foreach $service (@services) {
		&EU_Log(1,"Attempting to stop \"$service\".");
		$rv = &EU_AdjustService($service,0);
		if ($rv != 0) {
			if ($rv == 2) {
				&EU_Log(1,"Warning: unable to get status of service: $service");
			} else {
				$okay = 0;
				&EU_Log(1,"Problem stopping \"$service\".");
			}
		}
	}
	if ($okay == 0) {
		$okay = &EU_GetInput("\nThere was a problem stopping one or more services.\nDo you want to continue (y,[n])? ","n");
		&EU_ExitMessage(1,"User requested termination.") if ("$okay" ne "y");
	}
}



sub EU_StartServices() {
	my (@services) = @_;
	my $service;
	my $rv;
	my $okay = 1;

	&EU_Log(1,"\nAttempting to start appropriate services.");
	foreach $service (@services) {
		&EU_Log(1,"Attempting to start \"$service\".");
		$rv = &EU_AdjustService($service,1);
		if ($rv != 0) {
			$okay = 0;
			&EU_Log(1,"Problem starting \"$service\".");
		}
	}
	if ($okay == 0) {
		$okay = &EU_GetInput("\nThere was a problem starting one or more services.\nDo you want to continue (y,[n])? ","n");
		&EU_ExitMessage(1,"User requested termination.") if ("$okay" ne "y");
	}
}



sub EU_AdjustService() {
	my ($service,$mode) = @_;
	my %status;
	my $STOPPED = 1;	
	my $STARTED = 4;	
	my $PAUSED  = 7;	

	if (Win32::Service::GetStatus("",$service, \%status) == 0) {
		&EU_Log(1,"Warning: GetStatus for \"$service\" failed -- assuming that service doesn't exist.");
		return 2;
	}
	if ($mode == 0) { 
		if ($status{CurrentState} == $STOPPED) {
			&EU_Log(0,"\"$service\" is already off.");
			return 0;
		} else {
			if (Win32::Service::StopService("",$service) == 0) {
				if ($ExploitUtils::EU_BATCHMODE || (&EU_RunCommand("net stop $service",1) != 0)) {
					&EU_Log(1,"Unable to stop \"$service\".");
					return 3;
				}
				else {
					&EU_Log(0,"Stopped \"$service\" (and dependencies).");
					return 0;
				}
			} else {
				sleep(2);
				&EU_Log(0,"Stopped \"$service\".");
				return 0;
			}
		}
	} elsif ($mode == 1) { 
		if ($status{CurrentState} == $STARTED) {
			&EU_Log(0,"\"$service\" is already on.");
			return 0;
		} elsif ($status{CurrentState} == $PAUSED) {
			if (Win32::Service::ResumeService("",$service) == 0) {
				&EU_Log(1,"Unable to start (resume) \"$service\".");
				return 4;
			} else {
				&EU_Log(0,"Started (resumed) \"$service\".");
				return 0;
			}
		} else {
			if (Win32::Service::StartService("",$service) == 0) {
				&EU_Log(1,"Unable to start \"$service\".");
				return 4;
			} else {
				&EU_Log(0,"Started \"$service\".");
				return 0;
			}
		}
	} elsif ($mode == 2) { 
		if ($status{CurrentState} == $PAUSED) {
			&EU_Log(0,"\"$service\" is already paused.");
			return 0;
		} elsif ($status{CurrentState} == $STARTED) {
			if (Win32::Service::PauseService("",$service) == 0) {
				&EU_Log(1,"Unable to pause \"$service\".");
				return 5;
			} else {
				&EU_Log(0,"Paused \"$service\".");
				return 0;
			}
		} else {
			&EU_Log(1,"Unable to pause \"$service\" because it is currently stopped.");
			return 6;
		}
	} elsif ($mode == 3) { 
		if ($status{CurrentState} == $STARTED) {
			&EU_Log(0,"\"$service\" is already on.");
			return 0;
		} elsif ($status{CurrentState} == $PAUSED) {
			if (Win32::Service::ResumeService("",$service) == 0) {
				&EU_Log(1,"Unable to resume \"$service\".");
				return 7;
			} else {
				&EU_Log(0,"Resumed \"$service\".");
				return 0;
			}
		} else {
			if (Win32::Service::StartService("",$service) == 0) {
				&EU_Log(1,"Unable to resume (start) \"$service\".");
				return 7;
			} else {
				&EU_Log(0,"Resumed (started) \"$service\".");
				return 0;
			}
		}
	} else { 
		&EU_Log(1,"Invalid mode parameter passed to EU_AdjustService: [$mode]");
		return 1;
	}
}


sub EU_SaveEventLogs() {
	my ($dir,$prog) = @_;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);
	$year += 1900;
	$mon  += 1;
	my $error = 0;

	my $datestamp = sprintf("%04d%02d%02d_%02d%02d%02d",
		$year,$mon,$mday,$hour,$min,$sec);

	my $syslog = "$dir\\${datestamp}-System.log";
	my $applog = "$dir\\${datestamp}-Application.log";
	my $seclog = "$dir\\${datestamp}-Security.log";

	&EU_Log(1,"\nAttempting to save event logs to $dir.");

	&EU_Log(0,"Saving system data to $syslog.");
	&EU_RunCommand("\"$prog\" -f \"$syslog\" -l system",1);

	&EU_Log(0,"Saving application data to $applog.");
	&EU_RunCommand("\"$prog\" -f \"$applog\" -l application",1);

	&EU_Log(0,"Saving security data to $seclog.");
	&EU_RunCommand("\"$prog\" -f \"$seclog\" -l security",1);

	if ((! -f $syslog) || (! -f $applog) || (! -f $seclog)) {
		$error = 1;
		&EU_Log(1,"Problem saving off event log data.");
		if (&EU_GetInput("Continue ([y],n)? ","y") ne "y") {
			&EU_ExitMessage(1,"User terminated script.");
		}
	}

	return $error;
}


sub EU_ClearEventLogs() {
	my ($prog) = @_;
	my $error = 0;

	&EU_Log(1,"\nAttempting to clear event logs.");
	if (&EU_RunCommand("\"$prog\"",1)) {
		$error = 1;
		&EU_Log(1,"Problem clearing event log data.");
		if (&EU_GetInput("Continue ([y],n)? ","y") ne "y") {
			&EU_ExitMessage(1,"User terminated script.");
		}
	}

	return $error;
}


sub EU_StartNetmon() {
	my ($dir) = @_;
	my $error = 0;
	my $found = 0;
	my $prog;
	my @locations = (
		"C:\\smsadmin\\netmon\\i386\\netmon.exe",
		"D:\\smsadmin\\netmon\\i386\\netmon.exe",
		"C:\\winnt\\system32\\netmonfull\\netmon.exe",
	);

	&EU_Log(1,qq~
Attempting to start the network monitor with a buffer size of 40 MB.
Once it is up and running, reposition the window as desired, and
verify that it is capturing on the appropriate adapter. Then
return to this script to continue.
~);
	if (&EU_GetInput("Start the network monitor ([y],n)? ","y") ne "y") {
		$error = 1;
	} else {
		foreach (@locations) {
			if (-x $_) {
				$prog = $_;
				$found = 1;
				last;
			}
		}
		if (! $found) {
			&EU_Log(1,"Unable to locate network monitor program.");
			if (&EU_GetInput("Continue anyway ([y],n)? ","y") ne "y") {
				&EU_ExitMessage(1,"User terminated script.");
			}
			$error = 1;
		} else {
			my $cur_dir = cwd();
			chdir($dir) || &EU_Log(1,"Unable to change to $dir to start network monitor.");
			if (&EU_RunCommand("start $prog /BUFFERSIZE:40 /AUTOSTART",1)) {
				&EU_Log(1,"Problem starting network monitor.");
				if (&EU_GetInput("Continue anyway ([y],n)? ","y") ne "y") {
					&EU_ExitMessage(1,"User terminated script.");
				}
				$error = 1;
			}
			chdir($cur_dir) || &EU_Log(1,"Unable to change back to $cur_dir from $dir.");
		}
	}

	if ($error != 0) {
		&EU_Log(1,"You must start the network monitor manually.");
	}
	if (&EU_GetInput("\nAre you ready to continue ([y],n)? ","y") ne "y") {
		&EU_ExitMessage(1,"User terminated script.");
	}

	return $error;
}


sub EU_StopNetmon() {
	my ($dir) = @_;

	&EU_Log(1,qq~
You must manually stop the network monitor and save the captures to:
	$dir
You may then continue with the cleanup.
~);
	if (&EU_GetInput("Are you ready to continue ([y],n)? ","y") ne "y") {
		&EU_ExitMessage(1,"User terminated script.");
	}

	return 0;
}


sub EU_CleanDir() {
	my ($dirname,$cleandir) = @_;

	if (! -d $cleandir) {
		&EU_Log(1,"Can't clean non-existent $dirname: $cleandir.");
		return 1;
	}
	if (&EU_GetInput("Okay to delete all files in $cleandir ([y],n)? ","y") eq "y") {
		if (&EU_RunCommand("del /q /s \"$cleandir\\*.*\"",1)) {
			&EU_Log(1,"Unable to remove all files from $cleandir.");
			if (&EU_GetInput("Continue ([y],n)? ","y") ne "y") {
				&EU_ExitMessage(1,"User terminated script.");
			}
			return 1;
		} else {
			return 0;
		}
	} else {
		&EU_Log(1,"You must clean $cleandir manually.");
		if (&EU_GetInput("Continue ([y],n)? ","y") ne "y") {
			&EU_ExitMessage(1,"User termianted script.");
		}
		return 1;
	}
	return 0;
}


sub EU_RunAndLog {
	my ($stdoutFlag, $cmd) = @_;
	my $status;

	my $handle = new FileHandle;
	&EU_Log(1,"\nExecuting: $cmd");
	if (!open($handle,"$cmd|")) {
		&EU_Log(1,"Unable to execute command");
		return 1;
	}

	while (<$handle>) {
		chomp;
		&EU_Log($stdoutFlag,$_);
	}
	$status = $?;

	&EU_Log(0,"Command returned status value of: [$status].");
	return $status;
}


sub EU_TraceRoute {
	my ($targetIP, $maxHops, $timeout) = @_;

	my $handle = new FileHandle;
	my $okay = 0;

	if (! defined $maxHops) {
		$maxHops = 30;
	}

	if (! defined $timeout) {
		$timeout = 10000;	
	}

	&EU_Log(1,"\nPerforming tracert to $targetIP (maximum of $maxHops hops).");
	if (!open($handle,"tracert -h $maxHops -w $timeout $targetIP|")) {
		&EU_Log(1,"Unable to execute: tracert -h $maxHops -w $timeout $targetIP");
		return 1;
	}

	while (<$handle>) {
		chomp;
		&EU_Log(1,$_);
		if ((! /^Tracing/) && (/$targetIP/)) {
			$okay = 1; 
		}	
	}

	if ($okay) {
		&EU_Log(0,"$targetIP seen in tracert.");
		return 0;
	} else {
		&EU_Log(0,"$targetIP not seen in tracert.");
		return 2;
	}
}


sub EU_GetChoice {
	my ($prompt, $def, @choices) = @_;

	while (1) {

		&EU_Log(1, "\nAvailable Choices:\n\n");
		&EU_Log(1, " 0. Quit");

		my $choice;
		my $count = @choices;	
		for ($choice=1; $choice <= $count; $choice++) {
			if ($choice < 10) {
				&EU_Log(1," $choice. $choices[$choice-1]->{name}");
			} else {
				&EU_Log(1,"$choice. $choices[$choice-1]->{name}");
			}
		};

		&EU_Log(1,"");
		$choice = &EU_GetNum($prompt,$def);
		&EU_Log(0,"Choice [$choice] specified.");
		if ($choice > scalar(@choices)) {
			&EU_Log(1,"Invalid choice. Choice must be <= " . scalar(@choices));
			if ($ExploitUtils::BATCHMODE) { 
				return undef;
			}
		} elsif ($choice == 0) {
			return undef;
		} else {
			return $choices[$choice-1];
		}
	}
}



sub EU_GetAddr() {
  my ($prompt, $defVal) = @_;
  my $addr;
  my $retval;

  while (1) {
    if (defined $defVal) {
      $addr = &EU_GetInput("$prompt [$defVal]: ",$defVal);
    } else {
      $addr = &EU_GetInput("$prompt: ","");
    }
    
    if ($addr =~ /^\d{1,10}$/) { 
      $retval = &EU_GetInput("\nThis will be parsed as a DECIMAL value. Is this correct ([y],n)? \n", "y");
      next if($retval ne "y");
      return $addr;
    } elsif ($addr =~ /^0x[0-9A-F]{1,8}$/i) { 
      return $addr;
    } else {
      print "\"$addr\" is not a valid address.\n";
      print "You must enter a decimal or hex (0x) value.\n\n";
    }
  }
}

sub EU_GetExploitConfig() {
	my ($logFile) = @_;

	my $handle = new FileHandle $logFile;
    my %values;
    if (defined($handle)) {
		my $line;
		while ($line = $handle->getline()) {
			chomp($line);
			if ($line =~ /^\s*$/) {
				next;
			} elsif ($line =~ /^#/) {
				next;
			}
		
			my ($name, $value) = split(/=/, $line, 2);
			$values{$name} = $value;	    
		}
		$handle->close();
		return \%values;
    } else {
		return undef;
	}
}



return 1;

__END__
