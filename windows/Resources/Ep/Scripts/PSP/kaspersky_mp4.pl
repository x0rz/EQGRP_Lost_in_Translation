#-----------------------------------------------------------------------------
# File: PSP\kaspersky_mp4.pl
# Description: Parses Kaspersky settinsg dump
#
# 2009-12-31 - First write to account for MP4 settings.  OP ID 12345
#-----------------------------------------------------------------------------

use Data::Dumper;
$|=0;

my $file = $ARGV[0];
my $out = "";

open(IN, "<$file") or die "Error: $!\n";
my @lines = <IN>;
close(IN);

my $bbFlag = 0;
my $fmFlag = 0;

my $mode;

my $subMode = "";

my $dbFlag = 0;
my $injectFlag = 0;
my $hideFlag = 0;

my %data;

# rg - Registry Guard
# aaa - Application Activity Analyzer
# bb - Behavior Blocking
# fm - File Monitoring
# db - Dangerous Behavior


my $dump = {};
my $curTab = 0;
my $lastTab = 0;
my $curName = "";
my $thisHash = $dump;
my $lastHash = $dump;
my @hashChain;		# push and pop names off the end of the hash chain as we go down....
for (my $i = 0; $i < scalar(@lines); $i++) 
{
	my $line = $lines[$i];
	$line =~ s/\r//gi;
	
	if ($line =~ m/^(\t*)\+\s(.*?)$/gi) {
		$curName = $2;
		my @tabs = split //, $1;
		$curTab = scalar(@tabs);	# count the tabs to know when to start a new hash ref
		if ($curTab <= $lastTab) {	
			# Same or lower level, we need to pop one off (what we were just doing) the stack and create a new level.
			$thisHash = retHashBase($dump, \@hashChain, $curTab);	# need to get this at the appropriate level

			# potential problem point with untested method.
			for (my $n = 0; $n <= $lastTab - $curTab; $n++) { pop @hashChain; }	# get rid of appropriate number of elements
		}
		push @hashChain, $curName;
		$thisHash->{$curName} = {};	# create new hashref for this val
		$thisHash = $thisHash->{$curName}; # set thishash to new hashref
		$lastTab = $curTab;  # update this tracking value
	} else {
		# this is a value, not a new level
		$line =~ s/\t*//g;
		my ($key, $val) = split /\s=\s/, $line;
		$val =~ s/\s*$//g;
		$thisHash->{$key} = $val;
	}
}

# At this point, $dump contains a tree-like listing in memory of all the configuration file.  Need to know a setting?  Try this:
# my $regguard = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"regguard2"}->{"enabled"};

$data{"productName"} = $dump->{"Protection"}->{"settings"}->{"Ins_DisplayName"};
$data{"version"} = $dump->{"Protection"}->{"settings"}->{"SettingsVersion"};
$data{"productPath"} = $dump->{"Protection"}->{"settings"}->{"Ins_ProductPath"};
$data{"rgEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"regguard2"}->{"enabled"};
$data{"aicEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"pdm2"}->{"enabled"};
$data{"aaaEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"enabled"};	# Right now this is just a copy of BBenabled.  What is it really supposed to be????
$data{"fmEnabled"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"enabled"};
$data{"fmLevel"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"level"};
$data{"fmScanPacked"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"settings"}->{"ScanPacked"};
$data{"fmScanAction"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"settings"}->{"ScanAction"};
$data{"fmDisinfect"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"settings"}->{"TryDisinfect"};
$data{"fmDelete"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"settings"}->{"TryDelete"};
$data{"fmDeleteContainer"} = $dump->{"Protection"}->{"subItems"}->{"File_Monitoring"}->{"settings"}->{"TryDeleteContainer"};

# In KAV 6.0 MP4, this is called "P2P Worm Like Activity", if we should be targetting "Trojan Like Activity" instead, change the set values to 0001
$data{"dbEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0000"}->{"bEnabled"};
print "\n\n****** $data{dbEnabled} ****** \n\n";
$data{"dbAction"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0000"}->{"Action"};
$data{"dbLog"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0000"}->{"bLog"};
# No value for this in MP4....
$data{"dbQuarantine"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0000"}->{"bQuarantine"};

# In KAV 6.0 MP4, this is called "Keyloggers"
$data{"keyboardEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0007"}->{"bEnabled"};
$data{"keyboardAction"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0007"}->{"Action"};
$data{"keyboardLog"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0007"}->{"bLog"};
# No value for this in MP4....
$data{"keyboardQuarantine"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0007"}->{"bQuarantine"};

# In KAV 6.0 MP4, this is called "Hidden Process"
$data{"hideEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0006"}->{"bEnabled"};
$data{"hideAction"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0006"}->{"Action"};
$data{"hideLog"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0006"}->{"bLog"};
# No value for this in MP4....
$data{"hideQuarantine"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0006"}->{"bQuarantine"};

# In KAV 6.0 MP4, this is called "Intrusion Into Process" 0009 
$data{"injectEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0009"}->{"bEnabled"};
$data{"injectAction"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0009"}->{"Action"};
$data{"injectLog"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0009"}->{"bLog"};
# No value for this in MP4....
$data{"injectQuarantine"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"subItems"}->{"pdm2"}->{"settings"}->{"Set"}->{"0009"}->{"bQuarantine"};

$data{"protection"} = $dump->{"Protection"}->{"enabled"};
$data{"bbEnabled"} = $dump->{"Protection"}->{"subItems"}->{"Behavior_Blocking2"}->{"enabled"};


print $data{"productName"} . "\t"; #0
print $data{"version"} . "\t"; #1
print $data{"productPath"} . "\t"; #2
print $data{"protection"} . "\t"; #3
print $data{"bbEnabled"} . "\t"; #4
print $data{"dbEnabled"} . "\t"; #5 
print $data{"dbAction"} . "\t"; #6 
print $data{"dbLog"} . "\t"; #7 
print $data{"dbQuarantine"} . "\t"; #8 
print $data{"injectEnabled"} . "\t"; #9 
print $data{"injectAction"} . "\t"; #10
print $data{"injectLog"} . "\t"; #11
print $data{"injectQuarantine"} . "\t"; #12
print $data{"hideEnabled"} . "\t"; #13
print $data{"hideAction"} . "\t"; #14
print $data{"hideLog"} . "\t"; #15
print $data{"hideQuarantine"} . "\t"; #16 
print $data{"keyboardEnabled"} . "\t"; #17
print $data{"keyboardAction"} . "\t"; #18
print $data{"keyboardLog"} . "\t"; #19
print $data{"keyboardQuarantine"} . "\t"; #20
print $data{"rgEnabled"} . "\t"; #21
print $data{"aaaEnabled"} . "\t"; #22
print $data{"fmEnabled"} . "\t"; #23
print $data{"fmLevel"} . "\t"; #24
print $data{"fmScanPacked"} . "\t"; #25
print $data{"fmScanAction"} . "\t"; #26
print $data{"fmDisinfect"} . "\t"; #27
print $data{"fmDelete"} . "\t"; #28
print $data{"fmDeleteContainer"} . "\t"; #29
print $data{"aicEnabled"} . "\t"; #30

# return the hash base given the aboslute base plus the chain of keys that got us there.
sub retHashBase() {
	my ($hash, $elements, $num) = @_;
	return false unless ($hash && $elements);
	if (!$num) {
		$num = scalar(@{$elements});
	}
	my $key = "";
	my $arr = copyArrayRef($elements);	# make a working copy and store it in $arr	
	my $curLevel = $hash;
	#for (my $i = 0; $i < scalar(@{$arr}); $i++) {
	for (my $i = 0; $i < $num; $i++) {
		$key = $arr->[$i];
	 	$curLevel = $curLevel->{"$key"};
	}
	return $curLevel;
}

# Copies an array ref so we have a working copy to mutilate
sub copyArrayRef() {
	my ($src) = @_;
	return false unless ($src);
	my $dst = [];
	for (my $i = 0; $i < scalar(@{$src}); $i++) {
		push @{$dst}, $src->[$i];
	}
	return $dst;
}

