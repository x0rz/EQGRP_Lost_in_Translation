@echo off
echo @include "_PFreIncludes.dsi";
echo @include "_Commands.dsi";
echo string $logsDirectoryPath;
echo _GetLpLogsDirectory($logsDirectoryPath);
echo string $myHomebase;
echo @record on;
echo `environment -var HOME_BASE -get`;
echo @record off;
echo GetCmdData("environment::value::value", $myHomebase);
echo @record on;
echo `local environment -var SQL_SCRIPT_DIR -get`;
echo @record off;
echo string $tempDownloadDirPath;
echo _PFre_GetTempDownloadDir($tempDownloadDirPath);
echo string $uploadDirPath;
echo GetCmdData("environment::value::value", $uploadDirPath);
echo if (! defined( $uploadDirPath )) 
echo {
echo 	_PFre_MyBanner("We need to identify where the SQL scripts are located on the local machine.", "\n");
echo 	GetInput("Please enter the full path to where the SQL scripts are located.", $uploadDirPath);
echo 	echo "\n";
echo 	`local environment -var SQL_SCRIPT_DIR -set $uploadDirPath`;
echo }
echo @record on;
echo `environment -var ORACLE_SID -get`;
echo @record off;
echo string $dbsid;
echo GetCmdData("environment::value::value", $dbsid);
echo #
echo ########################################################################################
echo # OPTIONAL - Run query to retrieve table names to append to the "%1%2_user" file.  	#
echo # 	          This will allow you to limit the export to a specific set of tables.  	#
echo ########################################################################################
echo int $dc4_id;
echo int $dc40_id;
echo int $dc41_id;
echo _StartCommand("put $uploadDirPath\\dc4.bat -name dc4.bat", $dc4_id);
echo _StartCommand("put $uploadDirPath\\dc40.tmp -name dc40.tmp", $dc40_id);
echo _StartCommand("put $tempDownloadDirPath\\dc41_$dbsid\_%1%2.tmp -name dc41.tmp", $dc41_id);
echo #
echo echo "\n\n";
echo #
echo @echo on;
echo _PFre_RunCmdAndWaitUntilFinished("run -command $myHomebase\\dc4.bat -redirect");
echo @echo off;
echo #
echo echo "\n\n";
echo _PFre_GetAndNameFile( "dc411.tmp", "$dbsid\_%1%2_tables.txt_" );
echo _PFre_DeleteFileAndStopId("dc4.bat", $dc4_id);
echo _PFre_DeleteFileAndStopId("dc40.tmp", $dc40_id);
echo _PFre_DeleteFileAndStopId("dc41.tmp", $dc41_id);
echo ############################################
echo # Copy the $dbsid\_%1%2_tables.txt file 	#
echo ############################################
echo @record on;
echo `local dir $logsDirectoryPath\\getfiles\\*$dbsid\_%1%2_tables.txt*`;
echo @record off;
echo string $myfilename;
echo string $myfilepath;
echo GetCmdData("diritem::fileitem::name", $myfilename);
echo GetCmdData("diritem::path", $myfilepath);
echo if(! _PFre_RunCmd("local copy $myfilepath\\$myfilename $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt"))
echo {
echo 	`local delete -file $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt`;
echo 	if(! _PFre_RunCmd("local copy $myfilepath\\$myfilename $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt"))
echo 	{
echo 		_PFre_MyBanner("Copy failed: $myfilepath\\$myfilename --> $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt", "\n\n");
echo 	}
echo 	else
echo 	{
echo  		echo "Copy Successful: $myfilepath\\$myfilename --> $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt\n\n";
echo 		_PFre_RunCmd("local run -command \"cmd /C notepad $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt\"");
echo 	}
echo }
echo else
echo {
echo 	echo "Copy Successful: $myfilepath$myfilename --> $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt\n\n";
echo 	_PFre_RunCmd("local run -command \"cmd /C notepad $tempDownloadDirPath\\$dbsid\_%1%2_tables.txt\"");
echo }
echo `del dc411.tmp`;
echo echo "\n\n";
echo string $msg = "OPTIONAL - Edit the exp_$dbsid\_%1%2_user.tmp file to add the list of tables you want for";
echo $msg[1] = "           the export.  Your additions to the END of the file should look like this:";
echo string $tmp;
echo _PFre_MySeparator (StrLen($msg[0]), $tmp);
echo $msg[2] = $tmp;
echo $msg[3] = "				TABLES=(";
echo $msg[4] = "				table_a,";
echo $msg[5] = "				table_b,";
echo $msg[6] = "				table_c,";
echo $msg[7] = "				table_x";
echo $msg[8] = "				)";
echo _PFre_MyBannerMultiLine($msg, "\n\n");
echo return true;

