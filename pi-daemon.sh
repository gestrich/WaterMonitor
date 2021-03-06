#!/bin/bash

set -eu
set -o errexit
set -o pipefail
set -o nounset

generate_post_data()
{
  cat <<EOF
{
  "systemTime": "$1",
  "value": $2
}
EOF
}

METERID=1820447667
if [ -z "$METERID" ]; then
  echo "METERID not set, launching in debug mode"
  echo "If you don't know your Meter's ID, you'll need to figure it out manually"
  echo "Easiest way is to go outside and read your meter, then match it to a meter id in the logs"
  echo "Note: It may take a several minutes to read all the nearby meters"

  rtl_tcp &> /dev/null &
  sleep 10 #Let rtl_tcp startup and open a port

  sudo ./rtlamr -msgtype=r900
  exit 0
fi

# Setup for Metric/CCF
UNIT_DIVISOR=10000
UNIT="CCF" # Hundred cubic feet

lastConsumption=0
while true; do
  # Suppress the very verbose output of rtl_tcp and background the process
  rtl_tcp &> /dev/null &
  rtl_tcp_pid=$! # Save the pid for murder later
       
  sleep 10 #Let rtl_tcp startup and open a port

  json="$(sudo /home/pi/go/bin/rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json -unique=true)"

  echo "Meter info: $json"

  timeStamp="$(echo "$json" | jq -r .Time)"
  consumption="$(echo "$json" | jq .Message.Consumption)"

  if [ "$consumption" = "$lastConsumption" ]; then
    echo "Consumption Didn't Change."
  else
    echo "Logging to API"
    echo  "$(generate_post_data $timeStamp $consumption)"
    #In your bashrc, put something like export WATER_MONITOR_URL=<URL to your lambda service>
    WATER_MONITOR_URL="https://1im6bysrn8.execute-api.us-east-1.amazonaws.com/Prod/waterReading"
    curl -X POST -H "Content-Type: application/json" "${WATER_MONITOR_URL}" \
    --data "$(generate_post_data $timeStamp $consumption)"
  fi

  lastConsumption="$consumption"

  #kill $rtl_tcp_pid || true # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49
  pkill -9 rtl_tcp || true # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49

done
