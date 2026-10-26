//
//  City.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import Foundation

struct City: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case country
        case admin1
    }

    var displayName: String {
        if let admin1, !admin1.isEmpty {
            return "\(name), \(admin1), \(country)"
        }

        return "\(name), \(country)"
    }
}

struct GeocodingResponse: Decodable {
    let results: [City]?
}
