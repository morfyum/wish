ECHO OFF

REM netsh import wifi profie
netsh wlan add profile filename=".\wifi.xml"

REM netsh connect by wifi name
netsh wlan connect name="Your_wifi_ssid"
