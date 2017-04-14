#!/usr/local/bin/perl
# $Revision: 1.2 $ $Date: 2007-06-04 12:12:51-04 $

use Getopt::Std;

$key = "0c49ddf746be87bbf39ddea725b78d3e4aabdd83b13367d71f". 
       "d612bd725502134150ffb547ea4eeda6de9dbe5a58fa4e1694";

$pad = 1;

getopts("nh");
if ($opt_n) { $pad = 0; }
if ($opt_h) {
	print "Usage: rmdecrypt.pl [-n] [files]\n";
	print "         -n  do not pad with whitespace to maintain columns\n";
	die;
}

my $nename = shift;

# get the config file
my @files;
my $config_dir = "Get_Files\\";

# look files first
@files = glob "$config_dir\\*rm_config*";

# If there are no files, go home
if ($#files < 0) {
	print "\n   *** No Config dump file found ***\n";
	exit 0;
}

for (@files) {
    my $usr_in = $_;
    	# create a file name to save the VLR list to
	# find the network element name to match the LI list
	($Y,$M,$D,$h,$m,$s) = m/(\d{4})_?(\d{2})_?(\d{2})_(\d+)h(\d+)m(\d+)s/;
    
    $usr_out = sprintf "%s%04d%02d%02d_%02dh%02dm%02ds", $config_dir, $Y, $M, $D, $h, $m, $s;
    
    #$usr_out .= "_$nename";
    	
    $usr_out .= "_rm_decrypt.txt";
    $usr_out =~ tr/A-Z/a-z/;

    next if (-s $usr_out);

    open USR_IN, $usr_in;
    open USR_OUT, ">$usr_out";
    
    while (<USR_IN>)			# for every line in every file
    {
    	$line = $_;
	$line =~ s/	\b			# match the beginning of a word boundary
		( 			# store the result in $1
		(?:[\da-f]{4}) +	# match 4 hexadecimal characters 1 or more times
		)			# end store
		\b			# match the end of a word boundary 
	/decrypt($1)			# substitute with decrypted password
	/ioxge;				# case insensitive, compile once, permit comments, global, expression
	printf USR_OUT "$line";		# print the line
    }
    close USR_OUT;
    close USR_IN;
    
    print "Processed -> $usr_out\n";
}

sub decrypt
{
	my ($encrpass) = @_;		# receive encryped password as parameter
	my $decrpass = "=";		# initialize decrypted password
	my ($echar, $kchar, $dchar);	# declare local variables

	for ($i = 0; $i < length($encrpass); $i += 4) {
		$echar = hex(substr($encrpass,$i,4));
		$kchar = hex(substr($key,$i,4));
		$dchar = $echar ^ $kchar;
		($dchar & 0xff) && return $encrpass; # bailout!
		$decrpass .= sprintf "%c", ($dchar >> 8);
	}
	!($decrpass =~ m/\0$/ ) && return $encrpass; # bailout!
	$decrpass =~ s/\0$//; # remove trailing null
	$decrpass .= "=";
	if ($pad) {
		while ((length $decrpass) < (length $encrpass)) {
			$decrpass .= " ";
		}
	}

	return $decrpass;	
}

