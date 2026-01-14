@echo off

Echo Swicthing Output Audio Stream to Lin 1

start C:\Scripts\Tools\nircmd.exe setdefaultsounddevice "Line 1" 1

echo.
echo Shutting down any active audio repeaters...
echo.
taskkill /fi "WindowTitle eq Game_Audio_Repeater" > nul

Echo Starting Audio Repeater
"C:\Program Files\Virtual Audio Cable\audiorepeater.exe" /Config:"C:\scripts\audioconfig.cfg" /AutoStart /WindowName:"Game_Audio_Repeater"

echo.
taskkill /fi "WindowTitle eq AudioSwitch" > nul

Echo Swicthing Output Audio Stream to Switch Back to HMDI

start C:\Scripts\Tools\nircmd.exe setdefaultsounddevice "SONY TV" 1

timeout -t 05

exit