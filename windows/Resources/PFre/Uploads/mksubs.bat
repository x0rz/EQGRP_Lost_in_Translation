@echo off
echo if (prompt("Do you want to wait until all files are finished downloading?"))
echo {
echo 	_PFre_WaitUntilCmdFinished("get", "dc22");
echo }
echo return true;
echo sub _PFre_IsCommandRunning(IN string $cmdToLookFor, IN string $strToLookFor)
echo {
echo 	@record on;
echo 	`commands`;
echo 	@record off;
echo 	string $cmdName;
echo 	string $cmdString;
echo 	GetCmdData("command::name", $cmdName);
echo 	GetCmdData("command::fullcommand", $cmdString);
echo 	for (int $i = 0; $i ^< sizeof($cmdName); $i++)
echo 	{
echo 		if ($cmdName[$i] == $cmdToLookFor)
echo 		{
echo 			/* Check that get is the one we are looking for */
echo 			string $matches;
echo 			if (RegExMatch($strToLookFor, $cmdString[$i], $matches) == true)
echo 			{
echo 				return true;
echo 			}
echo 		}
echo 	}
echo 	return false;
echo }

echo sub _PFre_WaitUntilCmdFinished(IN string $cmdToLookFor, IN string $strToLookFor)
echo {
echo 	int $delay = 5000;
echo 	while(_PFre_IsCommandRunning($cmdToLookFor, $strToLookFor))
echo 	{
echo 		int $sec = $delay;
echo 		$sec /= 1000;
echo 		echo "Waiting $sec seconds for command to finish";
echo 		sleep ($delay);
echo 		if ($delay ^< 30000)
echo 		{
echo 			$delay += 5000;
echo 		}
echo 		else
echo 		{
echo 			echo "Pausing script (command still running).";
echo 			pause;
echo 			$delay = 5000;
echo 		}
echo 	}
echo 	echo "Done";
echo 	return true;
echo }

echo sub _PFre_RunCmdAndWaitUntilFinished(IN string $cmdToRun)
echo {
echo 	_PFre_MyBanner("Running:  $cmdToRun");
echo 	`$cmdToRun`;
echo 	string $tokens;
echo 	RegExSplit(" ", $cmdToRun, 0, $tokens);
echo 	int $iCmd = 0;
echo 	int $iSearch;
echo 	if ($tokens[$iCmd] == "background")
echo 	{
echo 		$iCmd++;
echo 	}
echo 	$iSearch = $iCmd;
echo 	$iSearch++;
echo 	string $matches;
echo 	while (RegExMatch("^-", $tokens[$iSearch], $matches) == true)
echo 	{
echo 		$iSearch++;
echo 	}
echo 	string $myCmd;
echo 	SplitPath($tokens[$iSearch], $myCmd);
echo 	_PFre_WaitUntilCmdFinished($tokens[$iCmd], $myCmd[1]);
echo 	return true;
echo }
echo sub _PFre_MyBanner( IN string $msg )
echo {
echo 	_PFre_MySeparator(StrLen($msg));
echo 	echo "$msg";
echo 	_PFre_MySeparator(StrLen($msg));
echo }
echo sub _PFre_MySeparator (IN int $len)
echo {
echo 	if ( $len ^< 43 )
echo 	{
echo 		$len = 43;
echo 	}
echo 	string $line = "-------------------------------------------";
echo 	for (int $i = 43; $i ^< $len; $i++)
echo 	{
echo 		StrCat($line, "-");
echo 	}
echo 	echo "$line";
echo }
