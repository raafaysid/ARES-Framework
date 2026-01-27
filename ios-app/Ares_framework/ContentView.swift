//
//  ContentView.swift
//  Ares_framework
//
//  Created by Raafay Siddiqui on 1/22/26.
//
import SwiftUI

struct ContentView: View {
    @State private var battery: Int = 0
    @State private var altitude: String = "0"
    @State private var status: String = "WAITING"
    @State private var statusColor: Color = .gray
    @State private var recoveryCount: Int = 0
    
    // This timer will trigger every 1 second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            statusColor.opacity(0.2).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("ARES DRONE MONITOR")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                
                VStack(spacing: 20) {
                    HStack {
                        Text("SYSTEM STATUS:")
                        Spacer()
                        Text(status)
                            .bold()
                            .foregroundColor(statusColor)
                    }
                    
                    HStack {
                        Text("BATTERY:")
                        Spacer()
                        Text("\(battery)%")
                    }
                    
                    HStack {
                        Text("ALTITUDE:")
                        Spacer()
                        Text("\(altitude) FT")
                    }
                    HStack {
                        Text("AUTO-RECOVERIES:")
                        Spacer()
                        Text("\(recoveryCount)")
                            .bold()
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                
                Button("REFRESH MANUAL") {
                    loadData()
                    // Manually trigger the function
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        // Every time the timer ticks, run loadData
        .onReceive(timer) { _ in
            loadData()
        }
    }
    
    
    func loadData() {
        let path = "/Users/raafaysiddiqui/Ares_framework/Backend/logs/flight_data.json"
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(TelemetryData.self, from: data)
            
            // 1. Store the CURRENT status before we update it
            let oldStatus = self.status
            let newStatus = decodedData.status ?? "UNKNOWN"
            
            // 2. COUNTER LOGIC:
            // If the status JUST changed to RESTARTING, add 1.
            if newStatus == "RESTARTING" && oldStatus != "RESTARTING" {
                self.recoveryCount += 1
                print(">>> RECOVERY DETECTED! Total: \(self.recoveryCount)")
            }
            
            // 3. Update the UI variables
            self.status = newStatus
            self.battery = decodedData.battery_pct ?? 0
            
            if let alt = decodedData.altitude_ft {
                self.altitude = "\(alt)"
            } else {
                self.altitude = "---"
            }
            
            // Color update
            if newStatus == "OK" {
                self.statusColor = .green
            } else if newStatus == "RESTARTING" {
                self.statusColor = .blue
            } else {
                self.statusColor = .red
            }
            
        } catch {
            print("File is busy or empty... waiting for next second.")
        }
    }
}
    #Preview
    {
        ContentView()
    }

