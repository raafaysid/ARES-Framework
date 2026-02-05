import json
import time
import random
import os
from fastapi import FastAPI, HTTPException
from datetime import datetime
import uvicorn
import threading
app = FastAPI()
# configuration
LOG_DIR = "logs"
LOG_FILE = os.path.join(LOG_DIR, "flight_data.json")
REVIEW_DIR = os.path.join(LOG_DIR, "engineering_review")

# create the directories if they don't exist
os.makedirs(REVIEW_DIR, exist_ok=True)


def generate_telemetry(counter, override_bat=None, override_alt=None):
    # generating data
    # use override if provided, otherwise use random values for flight data
    battery = override_bat if override_bat is not None else random.randint(
        5, 100)
    altitude = override_alt if override_alt is not None else random.randint(
        10, 800)

    # safety calculation
    # rule: need 1% battery for every 15ft of altitude to land safely
    safe_battery_limit = (altitude / 15)

    status = "OK"

    # critical failure logic
    # If the random altitude is too high for the random battery, trigger the error
    if battery < safe_battery_limit:
        status = "CRITICAL_ERROR"
    elif battery < 20:
        status = "LOW_BATTERY"

    return {
        "timestamp": datetime.now().isoformat(),
        "id": "DRONE_001",
        "battery_pct": battery,
        "altitude_ft": altitude,
        "status": status,
        "monitor_threshold": round(safe_battery_limit, 1)
    }


def main():
    print("--- Ares Telemetry Simulator Started ---")
    print("Press Ctrl+C to stop.")

    counter = 1
    while True:
        try:
            # generating the data
            data = generate_telemetry(counter)

            # monitor logic with error handling
            if data["status"] == "CRITICAL_ERROR":
                print(
                    f"MONITOR ALERT: Alt {data['altitude_ft']} vs Bat {data['battery_pct']}")

                # instant write: tell the iPhone appCRITICAL state
                with open(LOG_FILE, "w") as f:
                    json.dump(data, f, indent=4)

                # keep the screen RED for 3 seconds so the user sees it
                time.sleep(3)

                # isolating the log for engineering
                try:
                    timestamp = datetime.now().strftime("%H%M%S")
                    with open(f"{REVIEW_DIR}/incident_{timestamp}.json", "w") as f:
                        json.dump(data, f, indent=4)
                except Exception as e:
                    print(f"Could not save review log: {e}")

                # SIGNAL RESTART: now move to the recovery phase
                with open(LOG_FILE, "w") as f:
                    json.dump({"status": "RESTARTING"}, f)

                time.sleep(2)
                continue

            # normal write
            with open(LOG_FILE, "w") as f:
                json.dump(data, f, indent=4)

            print(
                f"[{counter}] Alt: {data['altitude_ft']} | Bat: {data['battery_pct']}% | {data['status']}")
            counter += 1
            time.sleep(1)

        except (PermissionError, IOError) as e:
            # If the file is locked by the OS or another process, just skip and try again
            print(f"File busy, retrying... ({e})")
            time.sleep(0.1)
            continue

        except KeyboardInterrupt:
            print("\nSimulator stopped by user.")
            break

        except Exception as e:
            # catch all for any other issues to keep the drone "flying"
            print(f"Unexpected error: {e}")
            time.sleep(1)


@app.get("/telemetry")
def get_telemetry():
    try:
        # this calls the function mocked in the test
        data = generate_telemetry(1)
        return data
    except FileNotFoundError:
        # this turns a crash into an error message
        raise HTTPException(status_code=404, detail="Flight log not found")
    except Exception as e:
        # catch all for other unexpected flight errors
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":

    # start the data generator in a background thread
    #  keeping the telemetry loop running while the API listens
    data_thread = threading.Thread(target=main, daemon=True)
    data_thread.start()

    # start the API server
    # host="0.0.0.0" allows container to talk to Mac
    uvicorn.run(app, host="0.0.0.0", port=8000)
