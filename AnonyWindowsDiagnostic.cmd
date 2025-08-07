@echo off
:: ##############################################
:: # Anonymizer Universal Diagnostic Script      #
:: # Version 2                                   #
:: # By: Gabriel McGinn                          #
:: # Date: 2025-08-07                            #
:: ##############################################

mode con:cols=80 lines=24
title Anonymizer Universal Diagnostic Script
color 1F
cls

setlocal enabledelayedexpansion
set LOGFILE=%USERPROFILE%\Downloads\%USERNAME%_diag.txt
set VPN_STATUS_URL=http://greenlight.anonymizer.com/vpn_status

:: --- Check essential commands availability ---
set commandsMissing=0
for %%I in (ping tracert nslookup tasklist ipconfig route netsh powershell curl) do (
    where %%I >nul 2>&1
    if errorlevel 1 (
        echo WARNING: Command %%I NOT found or not accessible. Some tests may fail.
        set /a commandsMissing+=1
    )
)
if !commandsMissing! gtr 3 (
    echo Too many missing commands. Aborting script.
    pause
    exit /b 1
)

:: --- MAIN EXECUTION STARTS HERE ---

call :clearlogprompt
call :clearAndBanner
echo Starting Diagnostic Tests. Please ensure you are DISCONNECTED from Anonymizer client.
echo.

:: Add timestamp header to log for this run
echo ====================================================================== >> "%LOGFILE%"
echo New Diagnostic Run Started: >> "%LOGFILE%"
echo ====================================================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

call :clearAndBanner
call :showProgress 0 8 "Getting Date, Time, and Time Zone"
call :delay
call :clearAndBanner

call :showProgress 1 8 "Google DNS Reachability Test"
echo.
echo Ping Google DNS before connecting to VPN
echo.
call :pingTest "Ping Google DNS before VPN" 8.8.8.8
echo.
type "%LOGFILE%"
echo.
call :clearAndBanner

call :showProgress 1 8 "Google DNS Reachability Test"
echo.
echo Performing Traceroute to Google DNS
echo.
echo This may take a moment . . .
call :tracertTest "Traceroute to Google DNS before VPN" 8.8.8.8
call :clearAndBanner

call :showProgress 2 8 "Anonymizer Service Check"
echo.
echo DNS Lookup www.anonymizer.com
call :nslookupTest "DNS Lookup www.anonymizer.com before VPN" www.anonymizer.com
echo.
echo Performing Traceroute to Anonymizer
echo.
echo This may take a moment . . .
call :tracertTest "Traceroute to Anonymizer server before VPN" 147.203.99.3
call :clearAndBanner

call :showProgress 3 8 "Capturing System Details"
call :tasklistCapture "Tasklist before VPN"
call :delay
echo.
echo Gathering network configuration and routing tables
echo.
call :systemInfo
call :delay  
call :clearAndBanner

echo --------------------------------------------------------
echo Now PLEASE CONNECT the Anonymizer Universal client and press any key.
pause
call :clearAndBanner

call :showProgress 4 8 "VPN Connection Status Check"
echo.
call :vpnStatusCheck
call :delay
call :clearAndBanner

call :showProgress 5 8 "Google DNS Reachability Test"
echo.
echo Ping Google DNS with VPN
call :pingTest "Ping Google DNS after VPN" 8.8.8.8
echo.

echo Traceroute Google DNS with VPN
call :tracertTest "Traceroute Google DNS after VPN" 8.8.8.8
echo.
echo This may take a moment . . .
call :clearAndBanner

call :showProgress 6 8 "DNS lookup anonymizer.com with VPN connected..."
call :nslookupTest "DNS Lookup anonymizer.com after VPN" anonymizer.com
call :tasklistCapture "Tasklist after VPN"
echo.
call :clearAndBanner

call :showProgress 7 8 "Pulling Anonymizer Universal Logs..."
echo Checking log folder...
if exist "%APPDATA%\Anonymizer\Anonymizer Universal" (
    echo Folder exists.
    cd /d "%APPDATA%\Anonymizer\Anonymizer Universal" || echo Failed to cd into log folder
) else (
    echo Folder does not exist.
)
call :delay
call :clearAndBanner
call :showProgress 8 8
echo Simulated Speed Test:
call :speedTestSim

echo.
echo #######################################################
echo # Diagnostic tests complete.                          #
echo # File saved as: %LOGFILE% #
echo # Please attach this file to your support ticket.    #
echo #######################################################
pause
explorer "%USERPROFILE%\Downloads"
exit /b

:: === SUBROUTINES BELOW ===

:clearlogprompt
call :banner
echo ############################################################
echo #                                                          #
echo #  This script will generate detailed diagnostic logs at   #
echo #  %LOGFILE%.                                              #
echo #                                                          #
echo #  WARNING: The log contains running processes and VPN     #
echo #  logs which may include sensitive information.           #
echo #  Handle with care before sharing.                        #
echo #                                                          #
echo ############################################################

if not exist "%LOGFILE%" (
    pause
    cls
    goto :eof
)

set CLEARLOG=
set /p CLEARLOG=Do you want to CLEAR previous log file? (Y/N):
if /i "%CLEARLOG%"=="" set CLEARLOG=N
if /i "%CLEARLOG%"=="Y" (
    if exist "%LOGFILE%" del "%LOGFILE%"
    echo Log cleared at %date% %time% >> "%LOGFILE%"
    echo Cleanup done. Proceeding...
) else if /i "%CLEARLOG%"=="N" (
    echo Proceeding without clearing log...
) else (
    echo Invalid input, please enter Y or N.
    goto clearlogprompt
)
cls
goto :eof


:banner
cls
echo.
echo   .--.                                   _
echo  : .; :                                 :_;
echo  :    :,-.,-. .--. ,-.,-..-..-.,-.,-.,-..-..---.  .--. .--.
echo  : :: :: ,. :' .; :: ,. :: :; :: ,. ,. :: :`-'_.'' '_.': ..'
echo  :_;:_;:_;:_;`.__.':_;:_;`._. ;:_;:_;:_;:_;`.___;`.__.':_;
echo                          .-. :
echo                          `._.'
echo.
goto :eof

:clearAndBanner
cls
call :banner
goto :eof

:pauseAndClear
pause
cls
goto :eof

:showProgress
:: Usage: call :showProgress currentStep totalSteps "Message"
setlocal enabledelayedexpansion
set "current=%~1"
set "total=%~2"
set "message=%~3"

set /a percent=(!current!*100)/!total!
<nul set /p="Progress: !percent!%% - !message!"
endlocal
goto :eof

:recordTimestamp
echo --- Timestamp @ %date% %time% --- >> "%LOGFILE%"
tzutil /g >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:delay
ping 127.0.0.1 -n 3 >nul
goto :eof

:pingTest
echo %1 >> "%LOGFILE%"
ping -n 10 %2 >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:tracertTest
echo %1 >> "%LOGFILE%"
tracert %2 >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:nslookupTest
echo %1 >> "%LOGFILE%"
nslookup %2 >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:tasklistCapture
echo %1 >> "%LOGFILE%"
tasklist >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:systemInfo
echo --- System Network Configuration --- >> "%LOGFILE%"
ipconfig /all >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo --- Routing Table --- >> "%LOGFILE%"
route print >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo --- Firewall Status --- >> "%LOGFILE%"
netsh advfirewall show allprofiles >> "%LOGFILE%"
echo. >> "%LOGFILE%"
goto :eof

:vpnStatusCheck
echo Checking VPN connection status via HTTP...
echo VPN Status Check (%VPN_STATUS_URL%) >> "%LOGFILE%"
where powershell >nul 2>&1
if %errorlevel%==0 (
    powershell -command "(Invoke-WebRequest -Uri '%VPN_STATUS_URL%' -UseBasicParsing).Content" >> "%LOGFILE%" 2>&1
) else (
    where curl >nul 2>&1
    if %errorlevel%==0 (
        curl %VPN_STATUS_URL% >> "%LOGFILE%" 2>&1
    ) else (
        echo WARNING: Neither PowerShell nor curl available for VPN status check. Skipped. >> "%LOGFILE%"
    )
)
echo. >> "%LOGFILE%"
goto :eof

:speedTestSim
echo Simulated Speed Test via Ping to 8.8.8.8... >> "%LOGFILE%"
ping -n 15 8.8.8.8 > temp_ping_results.txt
type temp_ping_results.txt >> "%LOGFILE%"
del temp_ping_results.txt
echo. >> "%LOGFILE%"
goto :eof

