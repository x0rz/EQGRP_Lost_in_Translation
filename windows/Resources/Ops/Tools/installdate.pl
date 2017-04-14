#Provide hex or EP log as command-line argument or as input

$hex=shift();

my $cmdInput=1;

if (not(defined($hex)) or ($hex eq "")) {
	print "Gimme hex: ";
	$hex=<STDIN>;
	chomp($hex);
	$cmdInput=0;
}

if ($hex =~ /EP/) {
	open EP, $hex;
	while (<EP>) {
		$_ =~ s/\x00//g;
		$_ =~ s/\x0D//g;
		$_ =~ s/\x0A//g;
		if ($_ =~ /InstallDate/) {
			$line=<EP>;
			chomp($line);
			$line =~ s/\x00//g;
			$line =~ s/\x0D//g;
			$line =~ s/\x0A//g;
			if ($line =~ /Reg_Dword:  (\d\d:\d\d:\d\d.\d+ \d+ - )?(\S*)/) {
				$hex=$2;
				last;
			}
		}
	}
}

$dec=hex($hex);
$time=localtime($dec);
print "$hex in decimal=$dec\n\n";

print "Installed on $time\n";
if (not($cmdInput)) {
	print "\nHit return to exit.\n";
	<STDIN>;
}
