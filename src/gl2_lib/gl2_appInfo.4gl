PUBLIC TYPE appInfo RECORD
  appName,
          appBuild,
          progname,
          progDesc,
          progVersion,
          progAuth,
          splashImage,
          userName,
          fe_typ,
          fe_ver,
          os,
          cli_os,
          cli_osver,
          cli_res,
          cli_dir,
          cli_un
      STRING
END RECORD

FUNCTION (this appInfo)
    progInfo(
    l_progDesc STRING, l_progAuth STRING, l_progVer STRING, l_progImg STRING)
    RETURNS()
  LET this.progName = base.Application.getProgramName()
  LET this.progDesc = l_progDesc
  LET this.progAuth = l_progAuth
  LET this.progVersion = l_progVer
  LET this.splashImage = l_progImg
END FUNCTION
----------------------------------------------------------------------------------------------------
FUNCTION (this appInfo) appInfo(l_appName STRING, l_appBuild STRING) RETURNS()
  LET this.appName = l_appName
  LET this.appBuild = l_appBuild
END FUNCTION
----------------------------------------------------------------------------------------------------
FUNCTION (this appInfo) getClientInfo() RETURNS()
  LET this.fe_typ = UPSHIFT(ui.interface.getFrontEndName())
  LET this.fe_ver = ui.interface.getFrontEndVersion()
  CALL ui.interface.frontcall("standard", "feinfo", ["ostype"], [this.cli_os])
  CALL ui.interface.frontcall("standard", "feinfo", ["osversion"], [this.cli_osver])
  CALL ui.interface.frontCall("standard", "feinfo", ["screenresolution"], [this.cli_res])
  CALL ui.interface.frontCall("standard", "feinfo", ["fepath"], [this.cli_dir])
END FUNCTION
----------------------------------------------------------------------------------------------------
FUNCTION (this appInfo) getUserName() RETURNS()

END FUNCTION
