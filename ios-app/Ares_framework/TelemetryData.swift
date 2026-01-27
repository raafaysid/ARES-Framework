//
//  TelemetryData.swift
//  Ares_framework
//
//  Created by Raafay Siddiqui on 1/22/26.
//
import Foundation

//  translate JSON text into swift variables automatically.
struct TelemetryData: Decodable {
    let timestamp: String?
    let battery_pct: Int?
    let status: String?
    let altitude_ft: Int?
}
