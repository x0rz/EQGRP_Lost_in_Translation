open(IN, "<$ARGV[0]") or die "Error: $!";
my @lines=<IN>;
close(IN);

foreach my $line (@lines)
{
	$line =~ s/\x00//gi;
	while($line =~ m/ServerAddress.*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/gi)
	{
		print "$1";
	}
}
