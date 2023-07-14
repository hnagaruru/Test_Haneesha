@echo off
setLocal EnableDelayedExpansion

rem Adjust path for Java version 8 vs 11
call :verifyJava JAVA_VERSION
if errorlevel 1 goto :end

if not "%_DEBUG%" == "" (
    echo Using Java %JAVA_VERSION%
)

set _G_CLASSPATH=%_G_CLASSPATH%;%_G_ROOT_DIR%..\lib\java%JAVA_VERSION%\*
if "%JAVA_VERSION%" == "8" (
  set _G_CLASSPATH=%_G_CLASSPATH%;%JAVA_HOME%\lib\tools.jar
)

:runGosu
"%_JAVACMD%" %_DEBUG% %GOSU_OPTS% -classpath "%_G_CLASSPATH%" gw.lang.Gosu %_CMD_LINE_ARGS%

goto end

:verifyJava
  call checkjava

  if ERRORLEVEL 11 (
    set %~1=11
	exit /b 0
  ) else if ERRORLEVEL 9 (
    call :unsupported
  ) else if ERRORLEVEL 8 (
    set %~1=8
	exit /b 0
  ) else (
    call :unsupported
  )
  exit /b

:unsupported
  call :fail "Java 8 or Java 11 is required but not found.  Make sure JAVA_HOME refers to the correct Java version."
  exit /b 1

:fail
  echo %~1
  exit /b 1

:end

endlocal
