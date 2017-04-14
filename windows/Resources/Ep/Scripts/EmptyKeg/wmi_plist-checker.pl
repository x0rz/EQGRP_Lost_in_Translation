sub PadString ;

# "Magic" values
my @pathParts = split /\\/, $0;
my $elistLocation = "$pathParts[0]\\OPSDisk\\Resources\\EP\\elist.txt" ;

# For sorted output, we need these
my @knownProcs ;
my @unknownProcs ;
my @badProcs ;

# Make hash table of elist.txt
# Create hash tables of elist and plist
my %prochash ;
open(ELIST, "<:encoding(UTF-16)", $elistLocation) or die "Couldn't open $elistLocation for reading: $!\n";
while(my $eline=<ELIST>) {
        chomp $eline;
        if((my $proc, my $desc)=( $eline =~/^(.+?):\s+(.+?)\s*$/i)){
                $proc = lc($proc);
                $prochash{$proc}=$desc;
        }
}
close(ELIST);


my $line = <STDIN> ;
	
# Info for processes are divided by ':', so split it to get an array of the info for processes
my @processes = split /\;/, $line ;

# Garbage at the end to eliminate
pop @processes ;

# Create well-formatted headers
my $pidHeader 		= PadString( "PID", 6 ) ;
my $imageHeader		= PadString( "Image", 20 ) ;
my $pathHeader 		= PadString( "Path", 40 ) ;
my $seperator		= PadString( "-", 66, "-" ) ;

# Print header stuff
print "$pidHeader$imageHeader$pathHeader\n" ;
print "$seperator\n" ;

foreach $process (@processes ) {
	# Within the process info, individual pieces are divided by ',', so split again!
	my @processField = split /,/, $process ;

	# Found a couple of ugly looking fields, so we can clean it up.
	my @imageParts = split /\./, $processField[0] ;
	my $imageName = $imageParts[0] . "\.exe" ;

	$displayImageName 	= PadString( $imageName, 20 ) ;
	$pid			= PadString( $processField[1], 6 ) ;
	$path			= PadString( $processField[2], 40 ) ;

	# Push results into arrays
	if( $prochash{ lc( $imageName ) } =~ /^!!!/ ) {
		my $string = "$pid $displayImageName $path \n\t" . $prochash{ lc( $imageName ) } . "\n";
		push @badProcs, $string;
	} elsif ( $prochash{ lc( $imageName ) } ) {
		my $string = "$pid $displayImageName $path \n\t" . $prochash{ lc( $imageName ) } . "\n";
		push @knownProcs, $string;
	} else {
		my $string = "$pid $displayImageName $path \n\t" . $prochash{ lc( $imageName ) } . "\n";
		push @unknownProcs, $string;
	}
}

# print the results!
my $entry;
foreach $entry (@knownProcs) { print $entry; }
foreach $entry (@unknownProcs) { print $entry; }
foreach $entry (@badProcs) { print $entry; }

exit ;

sub PadString( $string, $length, $padding ) {
	my $string = shift ;
	my $length = shift ;
	my $padding = shift ;

	my $stringCounter = length( $string ) ;

	while($stringCounter < $length) {
		if( !$padding ) {
			$string = "$string " ;
		} else {
			$string = "$string$padding" ;
		}
		$stringCounter += 1 ;
	}

	return $string ;
}