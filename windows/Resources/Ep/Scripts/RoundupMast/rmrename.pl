#!/usr/bin/perl -w
#####################################################################
# RoundupMastRename
#
# $Date: 2007-06-04 12:12:52-04 $ $Revision: 1.2 $
#####################################################################

$oracle_directory = "Get_files";
$mml_directory = "Logs";

# Log directories to parse
@oracle_files = glob "$oracle_directory\\runsql_*.EP";
@mml_files = glob "$mml_directory\\*run*.EP3";

# SQL logs..
for (@oracle_files)
{
#	print "$_\n";

	($Y,$M,$D,$h,$m,$s) = m/(\d+)_(\d+)_(\d+)_(\d+)h(\d+)m(\d+)s/;
	($script_name) = m/runsql_(.+).sql~/;
	next if (!$script_name);

	$script_name =~ s/^RoundupMast%//;
	
	# create the new file name 
	# format = datetime_sqlcmd.txt
	$newname = sprintf "%04d%02d%02d_%02dh%02dm%02ds", $Y, $M, $D, $h, $m, $s;
	$newname .= "_$script_name";
	$newname .= ".txt";
	$newname =~ tr/A-Z/a-z/;

	#Check if a file already exists with the same name.. it shouldn't because the time and
	#date stamp should be different
	if (-e "$oracle_directory\\$newname")
	{
		print "\n *** $newname already exists! ***\n";
		next;
	}

	#write out the new file name with .txt extension
	rename ($_, "$oracle_directory\\$newname") and print "-> $newname\n";
}

# MML commands ...
for (@mml_files)
{
	($Y,$M,$D,$h,$m,$s) = m/(\d+)_(\d+)_(\d+)_(\d+)h(\d+)m(\d+)s/;
	
	# Open MML file with "run" in the file name and assign the first line
	# inside the file to $x
	open(MMLFILE, "$_") or die "Couldn't open $_ for reading \n";
	$x = <MMLFILE>;
	close(MMLFILE);

	# remove the space before the " Command" in the first line of the 
	# .EP3 file
	$x =~ s/^.*(Command)/$1/;

	# confirm that it actually is a ROUNDUPMAST Command log by
	# confirming that drmclien.exe is actually being called
	# NOTE: IF WE EVER CHANGE THE NAME OF THE CLIENT FOR 
	# ROUNUPMAST V1, WE NEED TO UPDATE THIS SECTION OF THE CODE	
	if ($x =~ m/drmclien.exe -c ([^:; ]+) ([^:";]+)/)
	{
		($NEname, $command) = $x =~ m/drmclien.exe -c ([^:; ]+) ([^:";]+)/;
		$command =~ tr/ /_/;
	}


	next if (!$command);
	
	# get parameters
	(@parameters) = $x =~ m/\b([a-zA-Z0-9.'+-]+=[^,;_+]+)/g;
	$params = "";
	foreach $p (@parameters)
	{
		$p =~ s/[%\\"*]//g;
		last if (length "$params,$p" > 40);
		$params .= ",$p";
	}

	# remove initial comma
	$params =~ s/^,//;

	# create the new file name
	$newname = sprintf "%04d%02d%02d_%02dh%02dm%02ds", $Y, $M, $D, $h, $m, $s;
	$newname .= "_$NEname";
	$newname .= "_$command";
	$newname .= "_$params" if ($params);
	$newname .= ".txt";
	$newname =~ tr/A-Z/a-z/;

	if (-e "$mml_directory\\$newname")
	{
		print "\n *** $newname already exists! ***\n";
		next;
	}
	rename ($_, "$mml_directory\\$newname") and print "-> $newname\n";
	
}


