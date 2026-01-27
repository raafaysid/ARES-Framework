import json
import time
import random
import os

# Configuration
LOG_FILE = "logs/flight_data.json"


def generate_telemetry(counter):
    """Generates a dictionary representing drone flight data."""

    # normally, battery is 100-0, altitude is 0-500
    battery = random.randint(15, 100)
    altitude = random.randint(10, 400)
    status = "OK"

    # INJECTING FAILURES
    if counter % 10 == 0:
        status = "CRITICAL_ERROR"
        battery = -1  # Impossible value to trigger future scripts
        altitude = None  # Non numeric value to test data integrity

    return {
        "timestamp": time.ctime(),
        "id": "DRONE_001",
        "battery_pct": battery,
        "altitude_ft": altitude,
        "status": status
    }


def main():
    print("--- Ares Telemetry Simulator Started ---")
    print("Press Ctrl+C to stop.")

    counter = 1
    try:
        while True:
            try:
                if os.path.exists(LOG_FILE):
                    with open(LOG_FILE, "r") as f:
                        current_data = json.load(f)
                        if current_data.get("status") == "RESTARTING":
                            print(
                                f"[{counter}] System recovery in progress... holding.")
                            time.sleep(1)  # Wait and skip this loop iteration
                            continue
            except (json.JSONDecodeError, PermissionError):
                # if the file is busy being written by Bash, just wait a second
                time.sleep(1)
                continue
            data = generate_telemetry(counter)

            # write to the file (overwriting so we can read the 'latest' state)
            with open(LOG_FILE, "w") as f:
                json.dump(data, f, indent=4)

            print(f"[{counter}] Data Generated: Status {data['status']}")

            counter += 1
            time.sleep(1)  # Wait 1 second between logs
    except KeyboardInterrupt:
        print("\nSimulator stopped.")


if __name__ == "__main__":
    main()
