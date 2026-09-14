ECHO OFF
REM STARTNET.CMD

ECHO CONNECTING TO WIFI NETWORK
netsh wlan add profile filename=".\wifi.xml"
netsh wlan connect name="Your_wifi_SSID"

:: timeout 5

SET "ip=<Your_samba_server_IP>"

:AGAIN
ping -n 5 %ip% | find "TTL"
if errorlevel 1 (
    echo "Waiting for connection..."
    GOTO AGAIN
) else (
    echo "Connection success"
    goto START_SCRIPT
)

:START_SCRIPT
ECHO "*** START-SCRIPT ***"


ECHO SET LMCOMPATIBILITYLEVEL
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v LmCompatibilityLevel /t REG_DWORD /d 5 /f

ECHO MOUNT SAMBA SHARE
net use N: \\<Your_samba_server_IP>\share SambaTest2026 /user:samba

ECHO START WISH...
::N:
::startWish.cmd