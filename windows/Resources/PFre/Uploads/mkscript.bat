@echo off
echo @include "_PFreIncludes.dsi";
echo @include "_Commands.dsi";
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
echo bool $bSchemaExportWasDone = false;
echo string $schema_file;
echo string $export_file;
echo if (prompt ("Do you want to export the schema for %1%2?"))
echo {
echo 	$bSchemaExportWasDone = true;
echo 	_PFre_MyBanner("Uploading the survey scripts");
echo 	int $dc3_id;
echo 	int $dc31_id;
echo 	_StartCommand("put $uploadDirPath\\dc3.bat -name dc3.bat", $dc3_id);
echo 	_StartCommand("put $tempDownloadDirPath\\exp_$dbsid\_%1%2_sch.tmp -name dc31.tmp", $dc31_id);
echo 	_PFre_MyBanner( "Exporting the schema ... This could take a while");
echo 	@echo on;
echo 	_PFre_RunCmdAndWaitUntilFinished("run -command $myHomebase\\dc3.bat -redirect");
echo 	@echo off;
echo 	echo "\n\n";
echo 	$schema_file = "$dbsid\_%1%2_schema.dmp";
echo 	_PFre_MyBanner("Renaming resulting file.", "\n");
echo 	if ( ! _PFre_RunCmdAndWaitUntilFinished("move dc32.tmp $schema_file"))
echo 	{
echo 		_PFre_MyBanner("Renaming failed.  Using original file name.", "\n");
echo 		$schema_file = "dc32.tmp";
echo 	}
echo 	if ( ! _PFre_GetAndNameFileInTheBackground( $schema_file, "$dbsid\_%1%2_schema.dmp_" ))
echo 	{
echo 		$bSchemaExportWasDone = false;
echo 		if ( prompt ("Do you want to delete $schema_file?"))
echo 		{
echo 			`del $schema_file`;
echo 		}
echo 	}
echo 	_PFre_DeleteFileAndStopId("dc31.tmp", $dc31_id);
echo 	_PFre_DeleteFileAndStopId("dc3.bat", $dc3_id);
echo }
echo echo "\n";
echo string $msg = "";
echo $msg[1] = "Run the next command if you want to get a list of tables for %1%2";
echo $msg[2] = "to tailor the export of the table data.";
echo _PFre_MyBannerMultiLine($msg);
echo if ( PromptCommand ("script $tempDownloadDirPath\\get_$dbsid\_%1_tables_script.dss"))
echo {
echo 	_PFre_MyBanner("Continue only after you are done editing the $tempDownloadDirPath\\exp_$dbsid\_%1%2_user.tmp file.");
echo 	if (PromptCommand ("local run -command \"cmd /C notepad $tempDownloadDirPath\\exp_$dbsid\_%1%2_user.tmp\"") )
echo 	{
echo 		pause;
echo 	}
echo }
echo echo "\n";
echo bool $bDataExportWasDone = false;
echo if (prompt ("Do you want to export the data for %1%2?"))
echo {
echo 	$bDataExportWasDone = true;
echo 	int $dc3_id;
echo 	int $dc31_id;
echo 	_StartCommand("put $uploadDirPath\\dc3.bat -name dc3.bat", $dc3_id);
echo 	_StartCommand("put $tempDownloadDirPath\\exp_$dbsid\_%1%2_user.tmp -name dc31.tmp", $dc31_id);
echo 	_PFre_MyBanner("Exporting the table data ...  This could take a while");
echo 	@echo on;
echo 	_PFre_RunCmdAndWaitUntilFinished("run -command $myHomebase\\dc3.bat -redirect");
echo 	@echo off;
echo 	echo "\n";
echo 	$export_file = "$dbsid\_%1%2.dmp";
echo 	_PFre_MyBanner("Renaming resulting file.", "\n");
echo 	if ( ! _PFre_RunCmdAndWaitUntilFinished("move dc33.tmp $export_file"))
echo 	{
echo 		_PFre_MyBanner("Renaming failed.  Using original file name.", "\n");
echo 		$export_file = "dc33.tmp";
echo 	}
echo 	@echo on;
echo 	`dir`;
echo 	@echo off;
echo 	_PFre_MyBanner("Downloading resulting file.", "\n");
echo 	if ( ! _PFre_GetAndNameFileInTheBackground( $export_file, "$dbsid\_%1%2.dmp_" ))
echo 	{
echo 		$bDataExportWasDone = false;
echo 		if ( prompt ("Do you want to delete $export_file?"))
echo 		{
echo 			`del $export_file`;
echo 		}
echo 	}
echo 	_PFre_DeleteFileAndStopId("dc31.tmp", $dc31_id);
echo 	_PFre_DeleteFileAndStopId("dc3.bat", $dc3_id);
echo }
echo if ( $bSchemaExportWasDone == true )
echo {
echo 	echo "Waiting for the schema to finish downloading.";
echo 	_PFre_WaitUntilCmdFinished("get", $schema_file, true);
echo 	_PFre_MyBanner("Schema download complete.", "\n");
echo 	if ( prompt ("Do you want to delete $schema_file?"))
echo 	{
echo 		`del $schema_file`;
echo 	}
echo }
echo if ( $bDataExportWasDone == true )
echo {
echo 	echo "Waiting for the export to finish downloading.";
echo 	_PFre_WaitUntilCmdFinished("get", $export_file, true);
echo 	_PFre_MyBanner("Export download complete.", "\n");
echo 	if ( prompt ("Do you want to delete $export_file?"))
echo 	{
echo 		`del $export_file`;
echo 	}
echo }
echo return true;
