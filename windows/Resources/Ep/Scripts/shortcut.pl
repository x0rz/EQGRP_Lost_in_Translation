#Extracts the actual file path from a Windows link file.

use File::Copy;
use File::Path;
use Win32::Shortcut;

our $MAX = 1;
our $START = 0;

if (@ARGV != 1) {
	print "\nUsage: shortcut.pl <Get_Files path>\n ";
 	exit;	
}

$NOSEND_DIR = $ARGV[0];

#-------------------------------------------------
#get the actual file paths from the provided links
#-------------------------------------------------
`cd $NOSEND_DIR`;
opendir (NOSEND, $NOSEND_DIR);
@getLinks = grep(!/^\.+$/, readdir(NOSEND));
@getLinks = grep (!/Recent/, @getLinks);
closedir (NOSEND_DIR);

#copy link files to Recent directory
foreach $file (@getLinks) {
	if ($file =~ /^[\d\w\D]+\.lnk/) {
		$newname = $&; 
		$oldname = $file;
		$file = $newname;
		copy ("$NOSEND_DIR\\$oldname", "$NOSEND_DIR\\Recent\\$file");
	}
}

#------------------------------------------------------
#create LINKS.txt script to collect recent file
#------------------------------------------------------
print "-\n";
print "- Parsing link files ...\n";
opendir (RECENT, "$NOSEND_DIR\\Recent");
@links = grep(!/^\.+$/, readdir(RECENT));
closedir (RECENT);

$directory = `cd`;
$directory =~ s/\s+$//;
open (OUTFILE, ">>$directory\\LINKS.txt");

chdir "$NOSEND_DIR\\Recent";
$L=new Win32::Shortcut();
$counter = $START;
$a = $START;
foreach $link (@links) {
	$L->Load("$link") or print "\n$link not found!\n";
	
	#print "\nPath: $L->{'WorkingDirectory'}\n";

	#check to see if .lnk file is for a directory or an actual file
	#if file then append working directory to filename to get full path
	if ($L->{'WorkingDirectory'}) {
		$path = $L->{'WorkingDirectory'};
		$path =~ s/\\/\\\\/g;
		@temp = split (/\\/, $L->{'Path'});
		$filename = @temp[$#temp];
		#print "FILENAME: $filename\n";
		
		print OUTFILE "$path\\\\$filename\n";
		
		if ($counter == $MAX) {
			print OUTFILE "pause;\n";
			$counter = $START;	
		}
		
		
	}
	
}
close (OUTFILE);


