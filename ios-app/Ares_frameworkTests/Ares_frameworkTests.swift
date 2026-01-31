//
//  Ares_frameworkTests.swift
//  Ares_frameworkTests
//
//  Created by Raafay Siddiqui on 1/22/26.
//

import Testing
import Foundation
@testable import Ares_framework

struct Ares_frameworkTests {

    // test that the model correctly decodes valid JSON from the backend
    @Test("Verify Telemetry Decoding")
    func testTelemetryDecoding() throws {
        let json = """
        {
            "status": "flying",
            "altitude_ft": 150
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let data = try decoder.decode(TelemetryData.self, from: json)
        
        #expect(data.status == "flying")
        #expect(data.altitude_ft == 150)
    }

    // what if the altitude is missing or negative? / testing bad data
    @Test("Handle Invalid Altitude Data")
    func testInvalidAltitude() {
        let isSafe = validateFlightSafety(status: "flying", altitude: -50)
                
                //expect this to be false because -50 is impossible
                #expect(isSafe == false)
    }
}
