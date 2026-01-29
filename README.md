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
