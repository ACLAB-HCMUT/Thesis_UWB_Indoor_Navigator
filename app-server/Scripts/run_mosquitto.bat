@echo off
REM
cd /d %1

REM Start Mosquitto with the specified configuration file in verbose mode
start "" "mosquitto.exe" -v -c "mosquitto.conf"