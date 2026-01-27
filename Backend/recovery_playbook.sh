#!/bin/bash
LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "--- [RECOVERY INITIATED] ---"

# 1. Isolate the bad data
mkdir -p $ARCHIVE_DIR
cp $LOG_DIR/flight_data.json $ARCHIVE_DIR/fault_report_$TIMESTAMP.json

# 2. Reset the file status to RESTARTING
echo "{ \"timestamp\": \"$(date)\", \"battery_pct\": 100, \"altitude_ft\": 0, \"status\": \"RESTARTING\" }" > $LOG_DIR/flight_data.json

# 3. Hold this state long enough for the iPhone to see it
sleep 5 
echo "Action: Clearing recovery flag..."
echo "{ \"timestamp\": \"$(date)\", \"battery_pct\": 100, \"altitude_ft\": 0, \"status\": \"OK\" }" > $LOG_DIR/flight_data.json
echo "--- [RECOVERY COMPLETE] ---"