#!/bin/bash

cd /home/pi/WaterMonitor;
sudo WATER_MONITOR_URL="https://eo2gdd7nhj.execute-api.us-east-1.amazonaws.com/Prod/waterReading" ./pi-daemon.sh
