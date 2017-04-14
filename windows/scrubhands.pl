my $version = "scrubhands.pl ver 2012.06.01";
my $opbase = 'D:/';
my $oplogs = "Logs/";
 
use strict;
use FindBin;
use File::Copy;
use File::Basename;
use File::Find;
use English;
use Term::ReadKey;		# for input masking
use feature ":5.10";	# to be able to use the 'say' and 'given/when' features
use Cwd 'chdir';		# for changing the PWD for the renamer

$OUTPUT_AUTOFLUSH = 1;		# makes sure stuff gets printed ASAP
$PROGRAM_NAME = basename($PROGRAM_NAME);
system ("title=$version");
say "\n$version\n";

my $sourcePath = "T:";
my $prepsourcePath = "Y:";
my $destPath = "D:";

my $winzip="C:\\Program Files\\WinZip\\WZUNZIP.EXE";
my $target = "\\OPSDisk";
my $DSZtarget = "\\DSZOPSDisk";
my $DSZOPSDiskZIP = "";
my $OPSDiskZIP = "OPSDisk.zip";
my $jscannerZIP = "jscanner.zip";
my $fuzzbunchZIP = "FUZZBUNCH3_Supplemental.zip";
my $fwZIP = "FW.zip";
my $temp;

#
# MOUNT TRUECRYPT
#

my $desc = "Mount Truecrypt";
while (!(-e "T:\\") && ($temp != -1)) {
	$temp = promptToRun ($desc, "cmd.exe /c c:\\progra~1\\TrueCrypt\\truecrypt.exe /l T /k c:\\progra~1\\TrueCrypt\\keyfile /v \\Device\\Harddisk2\\Partition1 /c n /q /m ro");
	$desc = "TRUECRYPT NOT MOUNTED!  Retry";
}

#added to find/set DSZOPSDisk w/ revision in the file name
my @disks;
opendir(DIR, $sourcePath);
while(my $tmpFile = readdir(DIR)) {
	next unless(-f "$sourcePath/$tmpFile");
	next unless($tmpFile =~ m/^DSZOpsDisk-\d+.*\.zip$/i);
	push @disks, $tmpFile;
}
closedir(DIR);
if ($#disks == 0) {
	$DSZOPSDiskZIP = $disks[0];
} elsif ($#disks > 0) {
	# Found multiple disks, prompt which one to use.
	my $max = $#disks + 1;
	say "Found multiple DSZOpsDisk zips:";
	for (my $i = 0; $i <= $#disks; $i++) {
		my $j = $i + 1;
		say "$j - $disks[$i]";
	}
	print "Which should I grab? (Q = Abort and skip tool unpack): ";
	do {
		chomp($temp = <STDIN>);
		if ($temp =~ /q/i) {
			goto SKIP_TOOL_UNPACKING_GOTO;
		}
		$temp = int($temp) or -1;
	} while ($temp < 1 and $temp > $max);
	$DSZOPSDiskZIP = $disks[$temp-1]
}

if (!$DSZOPSDiskZIP) {
	say "Could not determine the full name of the DSZOpsDisk zip.";
	print "Skip tool unpacking? [Y]: ";
	chomp($temp = <STDIN>);
	if ($temp =~ /na/i) {
		die "Cannot continue.";
	} else {
		goto SKIP_TOOL_UNPACKING_GOTO;
	}
}

printf '%50s',"-----------------------------\n";

#
# COPY OPSDisk
#

if (-e "$sourcePath\\$OPSDiskZIP") {
	$target = "$destPath$target";
	mkdir $target;
	$temp = copyFile("$sourcePath\\$OPSDiskZIP", "$target\\$OPSDiskZIP");
	if ($temp) { unzip ("$target\\$OPSDiskZIP", "$target\\"); }
} else {
	printf '%50s',"Copying $sourcePath\\$OPSDiskZIP...";
	print " NOT FOUND ON OPSDISK.  SKIPPING.\n";
}


#
# COPY JSCANNER TO OPSDISK
#

if ( -e "$sourcePath\\$jscannerZIP") {
	$temp = copyFile("$sourcePath\\$jscannerZIP", "$target\\$jscannerZIP");
	if ($temp) { unzip("$target\\$jscannerZIP", "$target\\tools\\jscanner\\"); }
} else {
	printf '%50s',"Copying $sourcePath\\$jscannerZIP...";
	print " NOT FOUND ON OPSDISK.  SKIPPING.\n";
}


#
# COPY FUZZBUNCH
#

if (-e "$sourcePath\\$fuzzbunchZIP") {
	$temp = copyFile("$sourcePath\\$fuzzbunchZIP", "$target\\$fuzzbunchZIP");
	if ($temp) { unzip("$target\\$fuzzbunchZIP", "$destPath"); }
} else {
	printf '%50s',"Copying $sourcePath\\$fuzzbunchZIP...";
	print " NOT FOUND ON OPSDISK.  SKIPPING.\n";
}

printf '%50s',"-----------------------------\n";


#
# COPY DSZOPSDisk
#

$DSZtarget = "$destPath$DSZtarget";
mkdir $DSZtarget;
$temp = copyFile("$sourcePath\\$DSZOPSDiskZIP", "$DSZtarget\\$DSZOPSDiskZIP");
if ($temp) { unzip("$DSZtarget\\$DSZOPSDiskZIP", "$DSZtarget\\"); }
if ( -e "$sourcePath\\$jscannerZIP") {
	if ($temp) { unzip("$target\\$jscannerZIP", "$DSZtarget\\resources\\jscanner\\"); }
}


#
# COPY Overlay
#

my @overlayList = (0);		# We prepopulate this with a null, so that when we start adding files, we'll start at one.
my @prepList = (0);			# We prepopulate this with a null, so that when we start adding files, we'll start at one.
my $overlayZip = "";
my $input = "";

find(\&desiredFiles, $prepsourcePath);

if ($#overlayList == 0) {						# If there are no overlays skip to the next section
	$overlayZip = $overlayList[0];
	goto SKIP_OVERLAY_UNPACKING_GOTO;
} elsif ($#overlayList > 0 ) {					# If more than one is found, display a list of those found and prompt for a selection
	say "\nFound potential overlays:";
	say "-------------------------";
	my $moreOverlays = 1;
	while ($moreOverlays) {
		say "0 - Skip";
		for (my $o = 1; $o < scalar(@overlayList); $o++){
			say "$o - $overlayList[$o]";
		}
		while ($input !~ m/^\d{1}$/) {				# Until input is a single digit within the correct range, stay in this loop
			print "\nWhich overlay should I grab: ";
			chomp($input = <STDIN>);
			if ($input =~ m/^[0]{1}$/) {			# If input is a single zero, skip the overlay section
				say "OK, skipping...\n";
				$input = "";
				goto SKIP_OVERLAY_UNPACKING_GOTO;
			} elsif ($input =~ m/^\D+$/) {			# If input is/are non-numeric character(s), prompt again
				say "That's not a valid selection!";
				$input = "";
			} elsif ($input < 0 or $input > $#overlayList) {		# If input is a number less than or greater than the number of available entries, prompt again
				say "Please select a number from the choices above...";
				$input = "";
			}
		}
		say "";
		$overlayZip = "$overlayList[$input]";

		if (!$overlayZip) {
		say "Something happened and I could not determine the correct overlay...you will have to grab it manually";
		goto SKIP_OVERLAY_UNPACKING_GOTO;
		}

		(my $overlayZipPath = $overlayZip) =~ tr!/!\\!;		# convert the path to Win friendly path ( with \ instead of / ) so we can copy the preps correctly
		(my $overlayFileName = $overlayZip) =~ s{.*/}{};	# extract the filename from the path and assign it to $OverlayFileName

		$temp = copyFile("$overlayZipPath", "$destPath\\$overlayFileName");
		if ($temp) { unzip("$destPath\\$overlayFileName", "$destPath"); }

		print "\nDo you have more overlays to grab? [N]: ";
		chomp($temp = <STDIN>);
		$moreOverlays = 0 unless ($temp =~ /y/i);
		$input = "";
	}	
}
SKIP_OVERLAY_UNPACKING_GOTO:

printf '%50s',"-----------------------------\n";


#
# COPY PREPS AND PREPARE OPNOTES
#

my $date;
my $project;
my $prepsZip= "";

my $prepsNOTdone=1;
if (!@prepList) {
	say "Uncompressing preps... SKIPPED";
	$prepsNOTdone = 0;
} else {
	while ($prepsNOTdone) {
		my $morepreps = 1;
		say "\nFound potential preps:";
		say "----------------------";
		while ($morepreps) {
			say "0 - Skip";

			for (my $p = 1; $p < scalar(@prepList); $p++){
				say "$p - $prepList[$p]";
			}
			$input = "";
			while ($input !~ m/^\d{1}$/) {
				print "\nWhich prep should I grab: ";
				chomp($input = <STDIN>);
				if ($input =~ m/^[0]{1}$/) {						# If input is a single zero, skip the overlay section
					say "OK, skipping...\n";
					$input = "";
					goto SKIP_PREP_UNPACKING_GOTO;
				} elsif ($input =~ m/^\D+$/) {						# If input is/are non-numeric character(s), prompt again
					say "That's not a valid selection!";
					$input = "";
				} elsif ($input < 0 or $input > $#prepList) {		# If input is a number less than or greater than the number of available entries, prompt again
					say "Please select a number from the choices above...";
					$input = "";
				}
			}
			say "";
			$prepsZip = "$prepList[$input]";
						
			(my $prepszipPath = $prepsZip) =~ tr!/!\\!;		# convert the path to Win friendly path ( with \ instead of / ) so we can copy the preps correctly
			(my $prepfileName = $prepsZip) =~ s{.*/}{};		# extract the filename from the path and assign it to $prepfileName
			($project = $prepfileName) =~ s{\..*}{};		# remove the file extension from filename to get project name and assign to $project
			
			mkdir "$DSZtarget\\Preps";
			$temp = copyFile ("$prepszipPath", "$DSZtarget\\Preps\\$prepfileName");
			if ($temp) {
				unzip ("$DSZtarget\\Preps\\$prepfileName", "$DSZtarget\\Preps\\");
				mkdir "$DSZtarget\\Resources\\Pc\\Keys\\$project";
				copyFile ("$DSZtarget\\Preps\\$project\\PC2_keys\\private_key.bin","$DSZtarget\\Resources\\Pc\\Keys\\$project\\private_key.bin");
				copyFile ("$DSZtarget\\Preps\\$project\\PC2_keys\\public_key.bin","$DSZtarget\\Resources\\Pc\\Keys\\$project\\public_key.bin");
			}

			$temp = "";		
			print "\nDo you have more preps to grab? [N]: ";
			chomp($temp = <STDIN>);
			$morepreps = 0 unless ($temp =~ /y/i);
		}
		if (!$project) {
			# shouldn't get here unless we skip
			last;
		}

		SKIP_PREP_UNPACKING_GOTO:
		$project = uc($project);


		#
		# PREPARE OPNOTES
		#

		printf '%50s',"Preparing opnotes for $project...";

		my $date = getDateTime();

		open (OPNOTES, "$target\\Tools\\opnotes.txt");
		my @lines = <OPNOTES>;
		close(OPNOTES);

		foreach my $line (@lines) {
			$line =~ s/Project: \n/Project: $project\n/;
			$line =~ s/Date: \n/Date: $date\n/;
		}

		open (OPNOTES, ">$target\\Tools\\opnotes.txt");
		print OPNOTES @lines;
		close(OPNOTES);
		say " DONE";
		$prepsNOTdone = 0;
	}
}

#
# CHECK FOR USER-PROVIDED OPNOTES
#

my $userNotes;

if (-e "$sourcePath\\opnotes.txt") {
	open (OPNOTES, "$sourcePath\\opnotes.txt");
	my @lines = <OPNOTES>;
	close(OPNOTES);
	
	foreach my $line (@lines) {
		if ($line =~ /Project: $project\n/) {
			$userNotes = "$sourcePath\\opnotes.txt";
		}
	}
} elsif (-e "$sourcePath\\${project}_opnotes.txt") {
	$userNotes = "$sourcePath\\${project}_opnotes.txt";
} elsif (-e "$sourcePath\\${project}_todo.txt") {
	$userNotes = "$sourcePath\\${project}_todo.txt";
} elsif (-e "$sourcePath\\todo_${project}.txt") {
	$userNotes = "$sourcePath\\todo_${project}.txt";
}

if ($userNotes) {
	deleteFile ("$target\\Tools\\opnotes.txt");
	copyFile ("$userNotes", "$target\\Tools\\opnotes.txt");

	printf '%50s',"Preparing user-provided opnotes from $userNotes...";

	open (OPNOTES, "$target\\Tools\\opnotes.txt");
	my @lines = <OPNOTES>;
	close(OPNOTES);

	my $date = getDateTime();
	foreach my $line (@lines) {
		$line =~ s/Project: \n/Project: $project\n/;
		$line =~ s/Date: \n/Date: $date\n/;
	}

	open (OPNOTES, ">$target\\Tools\\opnotes.txt");
	print OPNOTES @lines;
	close(OPNOTES);
	say " DONE";
}

printf '%50s',"-----------------------------\n";

#
# UNMOUNT TRUECRYPT
#

promptToRun ("Unmount TrueCrypt", "c:\\progra~1\\TrueCrypt\\truecrypt.exe /l T /d /q /s /f /w");


#
# LAUNCH OPNOTES
#
SKIP_TOOL_UNPACKING_GOTO:
chdir "$destPath\\";
printf '%50s',"Waiting for user to close opnotes (".getDateTime().")...";
`$target\\Tools\\opnotes.txt`;
print " DONE\n\n";

printf '%50s',"-----------------------------\n";

#
# CHECK THAT D:\IPs OR D:\PROJECTs AND OPNOTES EXIST
#

my $IPfolder;
my $foundOpNotesFLAG = 0;
opendir OPS, $opbase;
my @files = grep { s/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/$opbase$1/ } readdir OPS;
closedir OPS;
opendir OPS, "$opbase$oplogs";
foreach my $file (readdir OPS) {
	if ($file eq '..' or $file eq '.') {
		next;
	}
	push @files, "$opbase$oplogs$file";
}
closedir OPS;
my @dirs;
while (my $dir = shift(@files)) {
	if (-d $dir) {
		push @dirs, $dir;
	}
}
#</DSZ1.1>
closedir OPS;
if (@dirs) {
	foreach my $dir (@dirs) {
		$IPfolder = "$dir";
		if (-e "$dir\\opnotes.txt") {
			$foundOpNotesFLAG = 1;
		}
	}
} else {
	# fail
	system ("color 0C");
	print "ERROR: Could not find a project folder or old IP folder structure. Continue anyway? [N] ";
	chomp($temp = <STDIN>);
		if ($temp =~ /n/i || $temp =~ /a/i || !($temp)) {
			exit;
		}
	system ("color 07");
}


##################################
# Prep FB logs and ship
##################################

promptToRun ("Process FB logs?", "python D:\\DSZOpsDisk\\Resources\\Ops\\Tools\\fb_logs.py D:\\DSZOpsDisk D:\\logs");

if ($foundOpNotesFLAG == 0) {
	# opendir OPS, $destPath;
	# my @dirs= grep { /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ } readdir OPS;
	# closedir OPS;
	if (@dirs) {
		print "You didn't save your opnotes to $destPath\\IP.  Copy them to $IPfolder? [Y] ";
		chomp($temp = <STDIN>);
		if ($temp =~ /n/i) {
			print "Fine, then.  Do it yourself.  I'll wait...";
			`explorer.exe $destPath\\`;
			chomp($temp = <STDIN>);
		} else {
			copyFile("$target\\tools\\opnotes.txt", "$IPfolder\\opnotes.txt");
			print "\n\n";
		}
	} else {
		system ("color 0C");
		print "ERROR:  There are no $destPath\\IP folders.  Continue anyway? [N] ";
		chomp($temp = <STDIN>);
		if ($temp =~ /n/i || $temp =~ /a/i || !($temp)) {
			exit;
		}
		system ("color 07");
	}
}

#
# RUN PITCHINFO.PL
#
promptToRun ("Run pitchInfo.pl", "cmd.exe /c \"C:\\Perl\\bin\\perl.exe d:\\DSZOpsDisk\\Resources\\Ops\\Tools\\pitchInfo.pl\"");	
if (!(-e "$IPfolder\\prevet_opnotes.txt")) {
	system ("color 0C");
	promptToRun ("Looks like pitchInfo.pl failed.  Retry", "cmd.exe /c \"C:\\Perl\\bin\\perl.exe d:\\DSZOpsDisk\\Resources\\Ops\\Tools\\pitchInfo.pl\"");	
	system ("color 07");
}


#
# MAP FRED'S SHARE
#

my $fredIP;
my $fredPW;
open IN, "<c:\\note.txt"; # (don't need to warn on this anymore) or warn "Cannot open suite info file c:\\note.txt";
while (my $line = <IN>) {
	if ($line =~ /linuxop/i) {
		$line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/;
		$fredIP = $1;
		last;
	}
}
if (!$fredIP) {
	((`ipconfig`) =~ /Default Gateway . . . . . . . . . : (192.\S+)/);
	$fredIP = $1;
}
# Always prompt, no matter how we got the IP.
print "Is '$fredIP' the correct address for the Linux station?  [Y] ";
chomp($temp = <STDIN>);
if ($temp =~ /[na]/i) {
	print "Enter the correct IP: ";
	chomp($fredIP = <STDIN>);
}

$temp="";
if (!(-e "Y:\\")) {
	print "Map shares? [Y] ";
	chomp($temp = <STDIN>);
}

while (! ($temp =~ /n/i) && !(-e "Y:\\")) {
	$temp = system ("cmd.exe /c \"net use Y: \\\\$fredIP\\downshare /USER:fred /PERSISTENT:NO\"");

	if (!(-e "Y:\\")) {
		system ("color 0C");
		print "Looks like we were unable to map the share.  (Try 'service smb restart')  Retry? [Y] ";
		chomp($temp = <STDIN>);
		system ("color 07");
		$fredPW = "";
	}
}


#
# RUN FINISHOP.PL
#
chdir "$target\\tools";
promptToRun ("Run finishOp.pl", "cmd.exe /c \"C:\\Perl\\bin\\perl.exe d:\\DSZOpsDisk\\Resources\\Ops\\Tools\\finishOp.pl\"");


#
# RUN COPY_DATA.BAT
#
promptToRun ("Run copy_data.bat", "cmd.exe /c \"C:\\batch\\copy-data.bat\"");
system ("color 07");

#
# UNMOUNT TRUECRYPT
#
promptToRun ("Unmount TrueCrypt", "c:\\progra~1\\TrueCrypt\\truecrypt.exe /l T /d /q /s /f /w");


#
# WIPE OPSDisk AND DSZOPSDisk FOLDERS
#

print "Clean up $destPath\\? [Y] ";
chomp($temp = <STDIN>);
chdir "$destPath\\";
if (!($temp =~ /n/i)) {
	deleteFolder ("$target");
	deleteFolder ("$DSZtarget");
	deleteFolder ("$destPath\\logs");
	deleteFolder ("$destPath\\ReplayDisk");
}


#
# REMOVE SHARED DRIVES
#
if (-e "Y:\\") {
	$temp = system("cmd /c \"net use Y: /DELETE\"");
}
if (-e "Z:\\") {
	$temp = system("net use Z: /DELETE");
}

#
# CLEAR RECENT DOCUMENTS
#

deleteFile ("c:\\docume~1\\%USERNAME%\\recent\\*");

#
# CLEAR FUZZBUNCH LOGS
#

deleteFile ("d:\\fuzzbunch*.log");

#
# Check for remnants in D:\Logs
#
opendir OPS, "$opbase$oplogs";
@files = readdir OPS;
closedir OPS;
if (@files) {
	system ("color 0C");
	print "There is data in $opbase$oplogs. This folder should be empty by now.\n";
	print "Please take care of this, then press enter to continue.\n";
	$temp = <STDIN>;
}

#
# REBOOT
#
my $default = "R";
if ($fredIP =~ /^192\./) {
	$default = "S";
}
print "(R)eboot, (S)hutdown, or (N)othing? [$default] ";
chomp(my $input = <STDIN>);

if (($input eq "" and $default eq "R") || $input =~ /r/i) {
	$temp=10;
	system ("color 0C");
	while ($temp > 0) {
		$temp--;
		print "Rebooting in $temp seconds (CTRL-C TO ABORT)...\n\n";
		sleep 1;
	}
	system("shutdown.exe -f -r -t 15 -c \"Use Start -> Run 'shutdown -a' to abort.\"");
} elsif ($input =~ /s/i or ($default eq "S")) {
	system("color 0c");
	$temp = 10;
	while ($temp > 0) {
		--$temp;
		print "System going to shut down in $temp seconds (CTRL+C TO ABORT)...\n\n";
		sleep 1;
	}
	system("shutdown.exe -f -s -t 15 -c \"Use Start -> Run 'shutdown -a' to abort.\"");
} else {
	exit;
}


#######################################################################################################################################
############################################################## FUNCTIONS ##############################################################
#######################################################################################################################################

sub unzip {
	my ($zipFile,$destPath) = @_;
	$_ = $zipFile;
	m/[^\\]*$/;
	printf '%50s',"Uncompressing $&...";
	if (-e $zipFile) {
		$temp = `cmd.exe /c \"$winzip\" -d -o \"$zipFile\" \"$destPath\\\"`;
		print " DONE\n";
		return 0;
	} else {
		print " ERROR (not found)\n";
		system("color 0C");
		chomp(my $input = <STDIN>);
		exit;
	}
}

sub copyFile {
	my ($from,$to) = @_;
	$_ = $from;
	m/[^\\]*$/;
	printf '%50s',"Copying $&...";
	if (-e "$to") {
		print " Already exists\n";
		return 0;
	}
	if (-e $from) {
		my $temp = copy("$from", "$to");
		if (-e $to) {
			print " DONE\n";
			return 1;
		} else {
			print " FAILED\n";
			return 0;
		}
	} else {
		print " NOT FOUND\n";
		return -1;
	}
}

sub desiredFiles {
	# This subroutine will search recursively through Y: for any overlay files and populate them into overlayList and prepList
	/down/ and $File::Find::prune = 1;		# exclude the 'Y:\down' directory
	my $file = $File::Find::name;
	if (-f && $file =~ /.*xqz2_.*\.zip$/i || $file =~ /.*ovlgen_.*\.zip$/i || $file =~ /.*ckm8_.*\.zip$/i){		# If a known overlay file is found, put it in the list
		push(@overlayList, $file);
	} elsif (-f && $file =~ /.*zip$/i && !($file =~ /.*xqz2_.*\.zip$/i || $file =~ /.*ovlgen_.*\.zip$/i || $file =~ /.*ckm8_.*\.zip$/i || $file =~ /.*\.txt$/i || $file =~ /.*\.tar$/i || $file =~ /.*\.bz2$/i || $file =~ /$OPSDiskZIP/i || $file =~ /DSZOpsDisk-\d+.*\.zip$/i || $file =~ /$jscannerZIP/i || $file =~ /$fuzzbunchZIP/i || $file =~ /$fwZIP/i || $file =~ /HASH/)){		# If other zips found are not already accounted for, present them as potential preps
		push(@prepList, $file);
	}
}

sub promptToRun {
	my ($desc, $cmd) = @_;

	print "$desc? [Y] ";
	chomp(my $input = <STDIN>);
	
	if ($input =~ /q/i) {
		print "ABORTED AT USER REQUEST";
		exit;
	} elsif ($input =~ /n/i) {
		return -1;
	} else {
		$temp = system($cmd);
		print "\n\n";
		return 0;
	}
}

sub deleteFolder {
	my ($folder) = @_;
	printf '%50s',"Deleting $folder...";
	if (-e "$folder") {
		$temp = system("rmdir /s /q $folder");
		if (!$temp) {
			print " DONE\n";
		} else {
			print " ERROR!\n";
		}
	} else {
		print " NOT FOUND\n";
	}
}


sub deleteFile {
	my ($folder) = @_;
	system("del /q $folder");
}

sub getDateTime {
	(my $sec,my $min,my $hour,my $day,my $mon,my $year) = localtime(time);
	my $ampm = "AM";
	if ($hour>12) {
		$ampm = "PM";
		$hour = $hour-12;
	} elsif ($hour=="0") {
		$ampm = "AM";
		$hour = 12;
	}

	if ($min<10) { $min = "0".$min; }
	$year = $year + 1900;
	$mon++;
	return "$hour:$min $ampm $mon/$day/$year";
}