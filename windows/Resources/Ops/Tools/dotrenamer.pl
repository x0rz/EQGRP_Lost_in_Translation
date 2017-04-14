use strict;
use Getopt::Long;
use Cwd;

my $pattern = "";
my $help = 0;

GetOptions("pattern=s"=>\$pattern,"help"=>\$help);
#,"\/\?"=>\$help,"\?"=>\$help); 

if ( $help ){
	print "Usage: e:/tools/dotrenamer.pl <-pattern xxx> [-help] ( note: you MUST be in the dir you want renamed. )\n";
	print "Note: the pattern replaces the dit (.) not the dit%.\n";
	exit ( 0 );
}

if ($pattern eq ""){
	print "You MUST supply a pattern for me to replace the dit(.) with.\n";
	print "Usage: e:/tools/dotrenamer.pl <-pattern xxx> [-help] ( note: you MUST be in the dir you want renamed. )\n";
	print "Note: the pattern replaces the dit (.) not the dit%.\n";
	exit ( 0 );
}

my $dir = cwd();

opendir DIR, $dir;
my @dirlist = readdir DIR;
closedir DIR;

my $file;
my $newFile;


foreach $file ( @dirlist){
	if ( $file =~ /^(\.)(%.*)/ ){
		$newFile = "$pattern$2";
		print "Renaming $file to $newFile\n";
		`rename $file $newFile`;
	}
}
print " Done\n";
