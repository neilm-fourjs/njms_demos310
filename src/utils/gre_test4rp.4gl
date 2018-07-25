-- Program to run 4rp files with data from raw xml output from GRE
-- ie output from : fgl_report_createProcessLevelDataFile
--	LET l_handler = fgl_report_createProcessLevelDataFile(l_targetName) -- Debug output
--
-- Arg1: 	 l_inFile : XML data file produced by fgl_report_createProcessLevelDataFile
-- Arg2:	 l_4rp : The report designed file
-- Arg3:	 l_device : Output to - SVG / PDF etc
-- Arg4:	 l_targetName : File name for output if not using preview option. Setting this will default to not preview!

IMPORT os
	DEFINE m_fontdir, m_greserver,m_greserverPort, m_fglserver STRING
	DEFINE m_start DATETIME HOUR TO SECOND
	DEFINE m_gresrv BOOLEAN
	DEFINE m_filePath STRING
MAIN
	DEFINE l_myHandler om.SaxDocumentHandler
	DEFINE l_inFile, l_xmlFile, l_4rp, l_targetName, l_device STRING
	DEFINE l_preview, l_merge_cells, l_singleSheet BOOLEAN
	DEFINE c base.Channel
	DEFINE l_ver STRING

	LET c = base.Channel.create()
	DISPLAY "Getting GRE Version ..."
	CALL c.openPipe("greportwriter -V","r")
	LET l_ver = c.readLine()
	IF l_ver.getIndexOf("build",1) = 0 THEN
		LET l_ver = c.readLine()
	END IF
	CALL c.close()

	LET m_filePath = fgl_getEnv("GREFILEPATH")
	IF m_filePath.getLength() < 1 THEN LET m_filePath = "./customer_files/" END IF
	DISPLAY "PWD:",os.path.pwd()
	DISPLAY "ProgramDir:",base.Application.getProgramDir()," Ver:",l_ver
	DISPLAY "FGLLDPATH:",fgl_getEnv("FGLLDPATH")
	DISPLAY "PATH:",fgl_getEnv("PATH")
	DISPLAY "GREDIR:",fgl_getEnv("GREDIR")
	DISPLAY "GREVER:",l_ver
	DISPLAY "FilePath:",m_filePath
	RUN "id"
	RUN "java -version"
	RUN "type greportwriter"
	RUN "greportwriter -V"
	LET m_fontdir = fgl_getEnv("FONTDIR")

-- Distributed mode - ie GRE Server, reduces print times due to no additional setup time.
	LET m_greserver = fgl_getEnv("GRESERVER")
	LET m_greserverPort = fgl_getEnv("GRESRVPORT")
	LET m_gresrv = FALSE
	IF m_greserver.getLength() > 1 THEN
		LET m_gresrv = TRUE
	END IF
	--IF m_gresrv THEN
	--	CALL fgl_report_configureDistributedProcessing(m_greserver,m_greserverPort)
	--END IF

	LET m_fglserver = fgl_getEnv("FGLSERVER")
	LET l_inFile = fgl_report_findResourcePath("test.4rp") -- test for grelib

	LET l_inFile = ARG_VAL(1)
	LET l_4rp = ARG_VAL(2)
	LET l_device = ARG_VAL(3)
	LET l_targetName = ARG_VAL(4)
	LET l_preview = TRUE
	IF l_targetName.getLength() > 1 THEN LET l_preview = FALSE END IF

	IF l_device.getLength() < 1 THEN LET l_device = "SVG" END IF
	LET l_merge_cells = TRUE
	LET l_singleSheet = TRUE

	LET l_inFile = os.path.rootname(l_inFile)
	LET l_inFile = os.path.basename(l_inFile)
	LET l_4rp = os.path.rootname(l_4rp)
	LET l_4rp = os.path.basename(l_4rp)

	IF m_fglserver.getLength() > 1 THEN

		OPEN FORM f FROM "gre_test4rp"
		DISPLAY FORM f
		CALL fgl_setTitle( l_ver )
		DISPLAY BY NAME m_greserver, m_greserverPort, m_gresrv, m_fontdir
		WHILE NOT int_flag
			INPUT BY NAME l_inFile, l_4rp, l_device, l_targetName, l_preview, l_merge_cells, m_gresrv
				ATTRIBUTES(WITHOUT DEFAULTS, UNBUFFERED)
				ON ACTION browse INFIELD l_inFile CALL browse("xml",l_inFile) RETURNING l_inFile
					IF l_inFile IS NOT NULL AND l_4rp = "." THEN
						LET l_4rp = l_inFile
					END IF
				ON ACTION browse INFIELD l_4rp CALL browse("4rp",l_4rp) RETURNING l_4rp
				ON CHANGE l_preview
					IF NOT l_preview AND l_targetName.getLength() < 1 THEN
						LET l_targetName = l_inFile
					END IF
				ON ACTION open --TODO need to find a better more generic way to do this.
					RUN "acroread "||l_targetName
			END INPUT
			IF int_flag THEN EXIT WHILE END IF
			IF NOT l_preview AND l_targetName.getIndexOf(".",1) = 0 THEN
				LET l_targetName = l_targetName||"."||l_device.toLowerCase()
			END IF
			LET l_xmlFile = m_filePath||l_inFile||".xml"
			IF init_gre(l_xmlFile, l_4rp,l_device,l_preview,l_targetName, l_merge_cells, l_singleSheet) THEN
			ELSE
				CALL fgl_winMessage("Error","Failed to load '"||l_4rp||"'","exclamation")
				CONTINUE WHILE
			END IF
			MESSAGE "Processing..."
			CALL ui.Interface.refresh()

			LET l_myHandler = fgl_report_commitCurrentSettings()

			LET m_start = CURRENT
			DISPLAY "Started:",m_start
			IF NOT os.path.exists( l_xmlFile ) THEN
				CALL fgl_winMessage("Error",SFMT("XML File not found '%1'\n%2-%3",l_xmlFile),"exclamation")
			END IF

			IF NOT fgl_report_runReportFromProcessLevelDataFile(l_myHandler, l_xmlFile) THEN
				CALL fgl_winMessage("Error",SFMT("Failed to process '%1'\n%2-%3",l_xmlFile,STATUS,ERR_GET(STATUS)),"exclamation")
			END IF
			MESSAGE "Finished, duration:",CURRENT - m_start
			DISPLAY "Finished, duration:",CURRENT - m_start
		END WHILE

		IF fgl_winQuestion("Question","Confirm Exit?","yes","yes|no","question",0) = "Yes"
		THEN END IF
	ELSE
		LET l_xmlFile = m_filePath||l_inFile||".xml"
		IF init_gre(l_xmlFile, l_4rp,l_device,l_preview,l_targetName, l_merge_cells, l_singleSheet) THEN
		ELSE
			DISPLAY "Init GRE Failed!"
			EXIT PROGRAM
		END IF
		DISPLAY "fgl_report_commitCurrentSettings()"
		LET l_myHandler = fgl_report_commitCurrentSettings()
		LET m_start = CURRENT
		DISPLAY "Started:",m_start
		IF NOT fgl_report_runReportFromProcessLevelDataFile(l_myHandler, l_xmlFile) THEN
			DISPLAY "Failed to process '"||l_inFile||"'"
			EXIT PROGRAM 1
		END IF
		DISPLAY "Finished, duration:",CURRENT - m_start
	END IF
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_gre(l_inFile, l_4rp,l_device,l_preview,l_targetName, l_merge_cells, l_singleSheet)
	DEFINE l_inFile, l_4rp, l_device,l_preview,l_targetName STRING
	DEFINE
		l_fontDirectory STRING,
		l_antialiasFonts BOOLEAN,
		l_antialiasShapes BOOLEAN,
		l_monochrome, l_merge_cells, l_singleSheet BOOLEAN,
		l_fromPage INTEGER,
		l_toPage INTEGER,
		l_fontName 				STRING,
		l_fontSize 				STRING,
		l_fidelity  			BOOLEAN,
		l_reportTitle 		STRING,
		l_fieldNamePatterns STRING,
		l_systemId 				STRING

	LET l_4rp = m_filePath||l_4rp||".4rp"
	IF NOT fgl_report_loadCurrentSettings(l_4rp) THEN
		RETURN FALSE
	END IF

	IF m_gresrv THEN
		CALL fgl_report_configureDistributedProcessing(m_greserver,m_greserverPort)
	END IF
	CALL fgl_report_selectDevice(l_device)
	CALL fgl_report_selectPreview(l_preview)
	IF l_device = "Printer" THEN
		CALL fgl_report_setPrinterName( l_targetName )
	ELSE
		IF l_targetName IS NOT NULL THEN
			CALL fgl_report_setOutputFileName( l_targetName )
		END IF
	END IF
	IF l_device = "XLS" OR l_device = "XLSX" THEN
		CALL fgl_report_configureXLSDevice(NULL,					-- fromPage
																			NULL,						-- toPage
																			l_merge_cells,	-- removeWhiteSpace
																			NULL,						-- ignoreRowAlignment
																			NULL,						-- ignoreColumnAlignment
																			NULL,						-- removeBackgroundImages
																			l_singleSheet)	-- mergePages
	END IF

	IF l_device = "PDF" THEN
		LET l_fontDirectory = m_fontdir
		IF l_fontDirectory.getLength() > 1 THEN
			DISPLAY "Fonts from:",l_fontDirectory
	--"/usr/share/fonts/truetype/msttcorefonts"
			LET l_antialiasFonts = TRUE
			LET l_antialiasShapes = TRUE
			LET l_monochrome = FALSE
			LET l_fromPage = 1
			LET l_toPage = NULL
			CALL fgl_report_configurePDFDevice(l_fontDirectory ,l_antialiasFonts ,l_antialiasShapes ,l_monochrome ,l_fromPage ,l_toPage)
		ELSE
			DISPLAY "Using default fonts."
		END IF
	END IF

{
	LET l_fontName = NULL
	LET l_fontSize = NULL		
	LET l_fidelity = TRUE	
	LET l_reportTitle = NULL
	LET l_fieldNamePatterns = NULL
	LET l_systemId = NULL

	CALL fgl_report_configureAutoformatOutput(
		l_fontName,
		l_fontSize,
		l_fidelity,
		l_reportTitle,
		l_fieldNamePatterns,
		l_systemId )
}

	DISPLAY "Fonts......:",l_fontDirectory
	DISPLAY "Server.....:",m_greserver,":",m_greserverPort," Use:",m_gresrv
	DISPLAY "inFile.....:",l_inFile
	DISPLAY "Report.....:",l_4rp
	DISPLAY "Device.....:",l_device
	DISPLAY "Preview....:",l_preview
	DISPLAY "Target.....:",l_targetName
	DISPLAY "MergeCells.:",l_merge_cells
	DISPLAY "SingleSheet:",l_singleSheet
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION browse(l_what,l_cur)
	DEFINE l_what, l_cur STRING
	DEFINE child STRING
	DEFINE h INTEGER
	DEFINE l_result DYNAMIC ARRAY OF STRING

	CALL os.Path.dirsort("name", 1)
	LET h = os.Path.diropen(m_filePath)
	WHILE h > 0
		LET child = os.Path.dirnext(h)
		IF child IS NULL THEN EXIT WHILE END IF
		IF child == "." OR child == ".." THEN CONTINUE WHILE END IF
		IF os.Path.extension( child ) = l_what THEN
			LET l_result[ l_result.getLength() + 1] = os.Path.rootname( child )
		END IF
	END WHILE
	CALL os.Path.dirclose(h)

	IF l_result.getLength() = 0 THEN
		CALL fgl_winMessage("Error","No matching files found!","exclamation")
		RETURN l_cur
	END IF

	OPEN WINDOW w WITH FORM "filelist"
	DISPLAY ARRAY l_result TO arr.*
	CLOSE WINDOW w
	IF int_flag THEN RETURN l_cur END IF
	RETURN l_result[ arr_curr() ]

END FUNCTION
