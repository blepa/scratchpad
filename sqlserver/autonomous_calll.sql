SET @Cmd = 'sqlcmd -E -S' + @@SERVERNAME + ' -Q "EXEC [' + DB_NAME() + '].[dbo].[ProcessLogAdd]' + 
		 '''' + CAST(@ProcessUid AS VARCHAR(36))  + ''',' + 
		CAST(@LoadId AS VARCHAR(10)) + ',' + 
		CAST(@ProcId AS VARCHAR(10)) + ',' + 
		'''' + REPLACE(REPLACE(ISNULL(@Message,''),'"','""'),'''','') + ''',' +
		'''' + @LogLevel + '''" -b';

	--PRINT '@Cmd: ' + @Cmd

	EXEC @CmdResult = xp_cmdshell @Cmd, no_output;
