//
//  TelemetryData.swift
//  Ares_framework
//
//  Created by Raafay Siddiqui on 1/22/26.
//
import Foundation
import Combine


//  translate JSON text into swift variables automatically
struct TelemetryData: Decodable {
    let timestamp: String?
    let battery_pct: Int?
    let status: String?
    let altitude_ft: Int?
}
class TelemetryViewModel: ObservableObject {
    // the "live" data that the UI will watch
    @Published var currentData: TelemetryData?
    
    //timer to keep fetching data every second
    private var timer: AnyCancellable?

    init() {
        startFetching()
    }

    func startFetching() {
        //tetch every 1 second to match Python generator
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.loadData()
            }
    }

    func loadData() {
        // pointing to the Docker container port
        guard let url = URL(string: "http://localhost:8000/telemetry") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                //use  struct to to decode the JSON
                if let decoded = try? decoder.decode(TelemetryData.self, from: data) {
                    DispatchQueue.main.async {
                        self.currentData = decoded
                    }
                }
            }
        }.resume()
    }
}
