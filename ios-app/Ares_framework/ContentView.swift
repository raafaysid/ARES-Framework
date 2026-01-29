//
//  ContentView.swift
//  Ares_framework
//
//  Created by Raafay Siddiqui on 1/22/26.
//
import SwiftUI

struct ContentView: View {
    // initializing the viewmodel that was created
    @StateObject var viewModel = TelemetryViewModel()
    var backgroundColor: Color {
        // only turning the whole screen red if the status is critical_error
        if viewModel.currentData?.status == "CRITICAL_ERROR" {
            return Color.red.opacity(0.9)
        }
        return .black
    }
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("ARES FLIGHT TELEMETRY")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                //display the data if it exists
                if let data = viewModel.currentData {
                    VStack(spacing: 20) {
                        TelemetryRow(label: "ALTITUDE", value: "\(data.altitude_ft ?? 0) FT")
                        TelemetryRow(label: "BATTERY", value: "\(data.battery_pct ?? 0)%", batteryValue: data.battery_pct)
                        TelemetryRow(label: "STATUS", value: data.status ?? "UNKNOWN")
                    }
                } else {
                    // show a loading state if the API isnt reached yet
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Connecting to ARES Container...")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}

// A simple helper view for the rows
struct TelemetryRow: View {
    var label: String
    var value: String
    var batteryValue: Int? = nil // optional battery level to determine color
    
    var body: some View {
        HStack {
            Text(label)
                .bold()
            Spacer()
            Text(value)
                .font(.system(.title2, design: .monospaced))
                // DYNAMIC COLOR: green if high battery, red if low
                .foregroundColor(determineColor())
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .foregroundColor(.white)
    }
    
    //logic to decide the color
    func determineColor() -> Color {
        if label == "BATTERY", let pct = batteryValue {
            return pct < 10 ? .white : .green
        }
        if label == "STATUS" {
            return value == "CRITICAL_ERROR" ? .white : .green
        }
        return .cyan //default color for Altitude
    }
}
