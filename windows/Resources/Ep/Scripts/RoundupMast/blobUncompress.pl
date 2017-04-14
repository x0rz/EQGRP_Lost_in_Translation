#!/usr/local/bin/perl
#####################################################################
# File: blobUncompress.pl
#
# Script to uncompress BLOBs that have been retrieved from the 
# Database.  This script will decompress and write out the readable 
# ASCII
#
# $Date$ $Revision$
# Modifications:
#  06/25/2008 - Created
#--------------------------------------------------------
#####################################################################
use Compress::Zlib;
use Getopt::Std;
use File::Basename;

# get the config file
my @files;
my $config_dir = "Get_Files\\";
my $file_to_process = "*_task_";


#####################################################################
sub ascii_to_hex($)
{
	## convert each asciihex to binary.. ie 79 (37 39) -> 79h
	(my $str = shift) =~ s/([a-fA-F0-9]{2})/chr(hex $1)/eg;
	return $str;
}

#####################################################################
getopts("f:h");
if ($opt_f){
	my $base = basename($opt_f);
	my $dir  = dirname($opt_f);
	$file_to_process = $base;
	$config_dir = $dir;
	print "optf is $opt_f\n";
	print "base is $base, file to process is $file_to_process\n";
	print "dir is $dir\n";	

}
	
if ($opt_h) {
	print"---------------------------------------------------------------------------\n";
	print "Usage: blobUncompress.pl [-h] [-f] <input file>\n";
	print "if no file name provided, will process all files with a rm_cmdResults in\n";
	print " the file name.\n";
	print "-f input_file, where input_file is the name of the non-standard\n";
	print "	ini file, including the full path.. i.e. C:\\decompressMe.now\n";
	print "-h display usage\n";
	print"---------------------------------------------------------------------------\n";	
	die;
}



# look files first
if ($opt_f){
   @files = glob "$config_dir\\$file_to_process";
   print $files;

}
else{
   #print "no -f config\file is ", 
   @files = glob "$config_dir\\$file_to_process*";
}

# If there are no files, go home
if ($#files < 0) {
	print "\n   *** No file found ***\n";
	exit 0;
}


for (@files) {
    
    my $usr_in = $_; 
    my ($status, $reinflate, $h_str, $y, $strToProc);
    my $ready = 0;
    # create a file name to save the uncompressed results to
	($Y,$M,$D,$h,$m,$s) = m/(\d{4})_?(\d{2})_?(\d{2})_(\d+)h(\d+)m(\d+)s/;
    if($opt_f){
       $usr_out = $file_to_process;
    }
    else{
       (my $taskID) = m/.+_task_(\d{1}-\d{1,10}).txt/;
       next if (!$taskID);
       $usr_out = sprintf "%s%04d%02d%02d_%02dh%02dm%02ds", $config_dir, $Y, $M, $D, $h, $m, $s;	
    }
    $usr_out .= "_$taskID";    	
    $usr_out .= "_rm_cmd_results.txt";
    $usr_out =~ tr/A-Z/a-z/;

    next if (-s $usr_out);

    open USR_IN, $usr_in;
    open USR_OUT, ">$usr_out";

    
    while (<USR_IN>)			# for every line in every file
    {
	($line = $_) =~ s/\s//g;
	if (m/^[z]/){
		#print "got a z...\n";
		#print "line is: ", $line, "\n";
		$ready = 1;
	}
	else{
		chomp($line);
		$strToProc .= $line;
		#print "storing line in strToProc as: ", $strToProc, "\n";
	}
	if ($ready == 1){
		$y = inflateInit() 
			or die "Cannot create an inflation stream\n";
		#print "processing string... $strToProc\n";
		$h_str = ascii_to_hex $strToProc;
		($reinflate, $status) = $y->inflate($h_str);
		#printf USR_OUT "Status is: $status\n";
		printf USR_OUT $reinflate;
		$ready = 0;
		$strToProc = "";
	}
		
    }

    close USR_OUT;
    close USR_IN;
    
    print "Processed -> $usr_out\n";
}

                             
