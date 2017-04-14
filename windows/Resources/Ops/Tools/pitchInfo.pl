my $version = "pitchInfo.pl ver 2011.01.10";
my $opbase = 'D:/';
my $oplogs = "Logs/";

# TODO: uncomment me when alarm() works in ActiveState
#$SIG{ALARM}= \&endProgram;
#
#sub endProgram {
#	exit(0);
#}
use strict;
use FindBin;	
use File::Copy;		

system("title=$version");
print "\n$version\n\n";

my $opsdisk="$FindBin::Bin/..";
my $phonelog="$opsdisk/phonelog.txt";

# get ip
my $ip="";
open IN, "<c:\\note.txt"; # (don't need anymore) or warn "Cannot open suite info file c:\\note.txt";
while (my $line = <IN>) {
	if ($line =~ /linuxop/i) {
		$line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/;
		$ip = $1;
		last;
	}
}
if (!$ip) {
	print "Couldn't get Linux IP from suite info. Falling back to old way (tcp interface default gateway)...\n";
	my @ipconfig=`ipconfig`;
	my $tcp="";
	foreach my $line (@ipconfig) {
		if ($tcp) {
			chomp($line);
			if ($line =~ /Default Gateway . . . . . . . . . : ([\d\.]*)/) {
				$ip=$1;
				last;
			}
		} else {
			if ($line =~ /^Ethernet adapter (Tcp|tcp)/i) {
	#		if ($line =~ /^Ethernet adapter/i) {
				$tcp=1;
			} elsif ($line =~ /^\S/) {
				$tcp="";
			}
		}
	}
}
print "Linux station appears to be at '$ip'. Is this where I should send the opnotes? [Y] ";
my $tmp;
chomp($tmp = <STDIN>);
if ($tmp =~ /[na]/i) {
	print "Please enter the correct IP now: ";
	chomp($ip = <STDIN>);
}

# read this in, echo to screen and to file
my $nc;
if (-e "D:/DSZOpsDisk/Resources/LegacyWindowsExploits/Resources/Tools/nc.exe"){
	$opsdisk = "D:/DSZOPSDisk";
	$nc = "${opsdisk}/Resources/LegacyWindowsExploits/Resources/Tools/nc.exe";
} else {
	print "nc.exe not found! Please enter the full path to the nc.exe binary: ";
	chomp($nc = <STDIN>);
	$nc =~ /^([^\/\\][\/\\]).*/;
	$opsdisk = $1;
}

#!!!!!!!!!! new section

#!!!!!!!!!!!!!!!!!!!remove me

#<DSZ1.1>
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
print "$opbase$oplogs\n@files\n";
while (my $dir = shift(@files)) {
	if (-d $dir) {
		push @dirs, $dir;
	}
}
#</DSZ1.1>

foreach my $dir (@dirs) {
	print "Found $dir\n";
}


print "Finding opnotes.\n";
my @opnotes=();
my @dirfornotes=();
my %systype;
foreach my $dir (@dirs) {
	if (-e "$dir/opnotes.txt") {
		push @opnotes, "$dir/opnotes.txt";
		push @dirfornotes, "$dir";
	}
	if (-e "$dir/router.log") {
		$systype{$dir}="r";
	}
	if (-e "$dir/pbx.log") {
		$systype{$dir}="p";
	}
	if (-e "$dir/FTP_ScreenDump") {
		$systype{$dir}="p";
	}
}
my $opnotes=$opnotes[0];
my $dirfornotes=$dirfornotes[0];


if (not(-e $opnotes)) {
	print STDERR "Couldn't find any opnotes!!!!\n";
	print STDERR "Do a ^C and go put your opnotes where I can find them (named opnotes.txt, in\n";
	print STDERR "  the top-level of one of the ops directories.\n";
	<STDIN>;
	exit;
}

#found opnotes, now nc them over to linux for vetting

print "Sending opnotes over to linux box for validation.\n";
print "$nc -w 1 -n $ip 9999 < $opnotes:\n";

my $ncout = `$nc -w 1 -n $ip 9999 < $opnotes`;

if ($ncout != "") {
	print "Some error occurred.  Try again.";
	exit;
}

#print "Hit enter when you're ready for the Linux side to send the opnotes back.";
#<STDIN>;

#!!!!!!! end new section



print "Running the following command (it is expected to hang; exit the window to end):\n";
print "$nc -l -p 9999:\n";
open NC, "$nc -l -p 9999 |";
while (my $line=<NC>) {
# TODO: uncomment me when alarm() works in ActiveState
#		alarm(2);
	open PHONELOG, ">>$phonelog";
	print $line;
	print PHONELOG $line;
	close PHONELOG;
	# TODO: timeout after a certain period
}
close NC;

move("$opnotes", "$dirfornotes/prevet_opnotes.txt");
#copy("$phonelog", "$opnotes");
#no phone log needed anymore?  it's already in the opnotes now.
move("$phonelog", "$opnotes");

