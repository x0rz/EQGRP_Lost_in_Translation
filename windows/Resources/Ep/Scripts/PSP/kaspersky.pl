#-----------------------------------------------------------------------------
# File: PSP\kaspersky.pl
# Description: Parses Kaspersky settinsg dump
#
# 2008-07-08 - First Release
# 2008-08-08 - Fixed some pattern matching glitches
#-----------------------------------------------------------------------------

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


foreach my $line (@lines)
{
	$line =~ s/\r//gi;
	if($line =~ m/^\t\t\+/gi)	# unset flags
	{
		$behaviorBlockingFlag = 0;
		$fileMonitoringFlag = 0;
	}


	# major section flags
	if($line =~ m/\+.Protection/i) { $mode = "protection"; }
	if($line =~ m/\+.Behavior_Blocking/i) { $mode = "bb"; }
	if($line =~ m/\+.File_Monitoring/i) { $mode = "fm"; }

	# Protection flags
	if(($mode eq "protection") && ($line =~ m/\tenabled\s=\s(.*?)$/gi)) { $data{"protection"} = $1; $mode = "";}

	# behavior blocking flags
	if(($mode eq "bb") && ($line =~ m/\+.0000$/gi)) { $subMode = "db"; }
	if(($mode eq "bb") && ($line =~ m/\+.0002$/gi)) { $subMode = "inject"; }
	if(($mode eq "bb") && ($line =~ m/\+.0003$/gi)) { $subMode = "hide"; }
	if(($mode eq "bb") && ($line =~ m/\+.0007$/gi)) { $subMode = "keyboard"; }
	if(($mode eq "bb") && ($line =~ m/\+.RegGroup_List/gi)) {$mode = ""; }

	# file monitoring flags
	if(($mode eq "fm") && ($line =~ m/\+\ssettings$/gi)) { $subMode = "fmSettings"; }

	# single name matches
	if($line =~ m/Ins_DisplayName\s=\s(.*?)$/gi) { $data{"productName"} = $1; }
	elsif($line =~ m/Ins_ProductPath\s=\s(.*?)$/gi) { $data{"productPath"} = $1; }
	elsif($line =~ m/(SettingsVersion|Ins_ProductVersion)\s=\s(.*?)$/gi) { $data{"version"} = $2; }
	elsif($line =~ m/bRegMonitoring_Enabled\s=\s(.*?)$/gi) { $data{"rgEnabled"} = $1; }
	elsif($line =~ m/bBehaviourEnabled\s=\s(.*?)$/gi) { $data{"aaaEnabled"} = $1; }
	elsif($line =~ m/bAppMonitoring_Enabled\s=\s(.*?)$/gi) { $data{"aicEnabled"} = $1; }

	# major section conditional matches
	elsif(($mode eq "bb") && ($line =~ m/\tenabled\s=\s(.*?)$/gi) && ($data{"bbEnabled"} eq "") ) { $data{"bbEnabled"} = $1; }
	elsif(($mode eq "fm") && ($line =~ m/enabled\s=\s(.*?)$/gi) && ($data{"fmEnabled"} eq "")) { $data{"fmEnabled"} = $1; }
	elsif(($mode eq "fm") && ($line =~ m/level\s=\s(.*?)$/gi) && ($data{"fmLevel"} eq "")) { $data{"fmLevel"} = $1; }

	# behavior blocking conditional matches
	elsif(($subMode eq "db") && ($line =~ m/bEnabled\s=\s(.*?)$/gi)) { $data{"dbEnabled"} = $1; }
	elsif(($subMode eq "db") && ($line =~ m/Action\s=\s(.*?)$/gi)) { $data{"dbAction"} = $1; }
	elsif(($subMode eq "db") && ($line =~ m/bLog\s=\s(.*?)$/gi)) { $data{"dbLog"} = $1;  }
	elsif(($subMode eq "db") && ($line =~ m/bQuarantine\s=\s(.*?)$/gi)) { $data{"dbQuarantine"} = $1; $subMode = ""; }

	elsif(($subMode eq "inject") && ($line =~ m/bEnabled\s=\s(.*?)$/gi)) { $data{"injectEnabled"} = $1; }
	elsif(($subMode eq "inject") && ($line =~ m/Action\s=\s(.*?)$/gi)) { $data{"injectAction"} = $1; }
	elsif(($subMode eq "inject") && ($line =~ m/bLog\s=\s(.*?)$/gi)) { $data{"injectLog"} = $1; }
	elsif(($subMode eq "inject") && ($line =~ m/bQuarantine\s=\s(.*?)$/gi)) { $data{"injectQuarantine"} = $1; $subMode = ""; }

	elsif(($subMode eq "hide") && ($line =~ m/bEnabled\s=\s(.*?)$/gi)) { $data{"hideEnabled"} = $1; }
	elsif(($subMode eq "hide") && ($line =~ m/Action\s=\s(.*?)$/gi)) { $data{"hideAction"} = $1; }
	elsif(($subMode eq "hide") && ($line =~ m/bLog\s=\s(.*?)$/gi)) { $data{"hideLog"} = $1; }
	elsif(($subMode eq "hide") && ($line =~ m/bQuarantine\s=\s(.*?)$/gi)) { $data{"hideQuarantine"} = $1; $subMode = "";}

	elsif(($subMode eq "keyboard") && ($line =~ m/bEnabled\s=\s(.*?)$/gi)) { $data{"keyboardEnabled"} = $1; }
	elsif(($subMode eq "keyboard") && ($line =~ m/Action\s=\s(.*?)$/gi)) { $data{"keyboardAction"} = $1; }
	elsif(($subMode eq "keyboard") && ($line =~ m/bLog\s=\s(.*?)$/gi)) { $data{"keyboardLog"} = $1;  }
	elsif(($subMode eq "keyboard") && ($line =~ m/bQuarantine\s=\s(.*?)$/gi)) { $data{"keyboardQuarantine"} = $1; $subMode = ""; }

	# file monitoring conditional matches
	elsif(($subMode eq "fmSettings") && ($line =~ m/ScanPacked\s=\s(.*?)$/gi)) { $data{"fmScanPacked"} = $1; }
	elsif(($subMode eq "fmSettings") && ($line =~ m/ScanAction\s=\s(.*?)$/gi)) { $data{"fmScanAction"} = $1; }
	elsif(($subMode eq "fmSettings") && ($line =~ m/TryDisinfect\s=\s(.*?)$/gi)) { $data{"fmDisinfect"} = $1; }
	elsif(($subMode eq "fmSettings") && ($line =~ m/TryDelete\s=\s(.*?)$/gi)) { $data{"fmDelete"} = $1; }
	elsif(($subMode eq "fmSettings") && ($line =~ m/TryDeleteContainer\s=\s(.*?)$/gi)) { $data{"fmDeleteContainer"} = $1; $subMode = ""; $mode = ""; }


}

print $data{"productName"} . "\t";
print $data{"version"} . "\t";
print $data{"productPath"} . "\t";

print $data{"protection"} . "\t";

print $data{"bbEnabled"} . "\t";

#if($data{"bbEnabled"} eq "yes")
print $data{"dbEnabled"} . "\t";
print $data{"dbAction"} . "\t";
print $data{"dbLog"} . "\t";
print $data{"dbQuarantine"} . "\t";
print $data{"injectEnabled"} . "\t";
print $data{"injectAction"} . "\t";
print $data{"injectLog"} . "\t";
print $data{"injectQuarantine"} . "\t";
print $data{"hideEnabled"} . "\t";
print $data{"hideAction"} . "\t";
print $data{"hideLog"} . "\t";
print $data{"hideQuarantine"} . "\t";
print $data{"keyboardEnabled"} . "\t";
print $data{"keyboardAction"} . "\t";
print $data{"keyboardLog"} . "\t";
print $data{"keyboardQuarantine"} . "\t";

print $data{"rgEnabled"} . "\t";
print $data{"aaaEnabled"} . "\t";

print $data{"fmEnabled"} . "\t";


print $data{"fmLevel"} . "\t";
print $data{"fmScanPacked"} . "\t";
print $data{"fmScanAction"} . "\t";
print $data{"fmDisinfect"} . "\t";
print $data{"fmDelete"} . "\t";
print $data{"fmDeleteContainer"} . "\t";

print $data{"aicEnabled"} . "\t";


sub bbAction
{
	my $action = @_[0];
	if($action eq "00000000") { return "Allowed"; }
	if($action eq "00000001") { return "Ask User"; }
	if($action eq "00000002") { return "Terminate/Block"; }
	if($action eq "00000004") { return "Alert"; }
}

sub fmLevel
{
	my $level = @_[0];
	if($level eq "00000000") { return "Low" }
	if($level eq "00000002") { return "Recommended - Medium" }
	if($level eq "00000003") { return "High" }
}
