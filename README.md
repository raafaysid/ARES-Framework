ARES Framework: Drone Telemetry & Self-Healing Pipeline
![Ares Safety CI](https://github.com/raafaysid/ARES-Framework/actions/workflows/python-tests.yml/badge.svg)
I built this framework to simulate how autonomous systems (like drones or rovers) handle sensor failures in the field. It’s a full-stack automation project that connects a Python backend, a Bash recovery engine, and a SwiftUI observability dashboard.

Core Components
Telemetry Engine (telemetry_gen.py): Streams JSON data representing altitude, battery, and system status. It includes a fault-injection loop that triggers a "CRITICAL_ERROR" every 10 cycles.

Health Monitor (monitor.py): Acts as the watchdog. It polls the telemetry stream and triggers the recovery playbook the moment a failure is detected.

Recovery Playbook (recovery_playbook.sh): A bash script that archives the faulty log for "post-mortem" analysis and resets the system state.

Mobile Dashboard (SwiftUI): A real-time iOS app that monitors the flight data and tracks "Auto-Recoveries" to measure system uptime.

Technical Challenges Solved
Process Synchronization: Solved a race condition between the Python monitor and the Bash script by implementing a "Handshake" protocol via the JSON state file.

Observability: Built a rising-edge trigger in Swift to ensure the recovery counter only increments once per failure event, preventing "counter-drift."

File I/O Safety: Handled JSONDecodeError exceptions to manage simultaneous read/write operations between the backend and the frontend.

How to Run It
Start Backend: Run python3 backend/telemetry_gen.py and python3 backend/monitor.py in separate terminals.

Launch Dashboard: Open ios-app/Ares_framework.xcodeproj in Xcode and run it on an iPhone 16 Pro simulator.

How I Ensure the System is Safe (QA & Automation)
Since ARES handles flight data, a single error could be critical. I built an automated "Safety Net" to catch bugs before they ever reach the user.

1- Automated Testing
The Backend: I use Python (Pytest) to make sure the drone data being sent is accurate and formatted correctly.

The Display (iOS): I use Swift Testing to ensure the iPhone app understands that data and doesn't crash if a sensor sends a "impossible" number (like a negative altitude).

2- (CI/CD)
I set up GitHub Actions to act as a 24/7 quality guard. Every time I update the code:

A Linux server automatically starts up to check the Python code.

A Mac server automatically starts up to run the iOS tests in a virtual iPhone.

If any test fails, the system blocks the update so the app stays stable.

3- Realistic Simulations
Error Handling: I wrote tests that purposely send "bad" data to the app to prove that it shows a clear warning message instead of just freezing.

Docker Reliability: I test the connection between the app and the server to make sure they can reconnect automatically if the signal is lost.
