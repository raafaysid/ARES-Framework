import json
import time
import subprocess
import os

LOG_FILE = "logs/flight_data.json"


def check_system_health():
    if not os.path.exists(LOG_FILE):
        return

    with open(LOG_FILE, "r") as f:
        try:
            data = json.load(f)

            # DATA VALIDATION LOGIC
            status = data.get("status")
            battery = data.get("battery_pct")

            if status == "CRITICAL_ERROR" or battery == -1:
                print(
                    f"!!! ALERT !!! Health Monitor detected system failure: {status}")
                # trigger the Bash Recovery Playbook
                subprocess.run(["./recovery_playbook.sh"])
            elif status == "RESTARTING":
                print("Health Monitor: System is RESTARTING...standing by.")
            else:
                print(f"Health Monitor: System {status} (Battery: {battery}%)")

        except json.JSONDecodeError:
            # this handles cases where we read while the other script is writing
            pass


def main():
    print("--- Ares Health Monitor Active ---")
    while True:
        check_system_health()
        time.sleep(1)  # Check every second


if __name__ == "__main__":
    main()
