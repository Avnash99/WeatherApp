//
//  WeatherAPIClient.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import Foundation

protocol WeatherAPIProtocol {
    func searchCities(query: String) async throws -> [City]

    func fetchForecast(for city: City) async throws
        -> [DailyForecast]
}

enum WeatherAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case noCitiesFound
    case emptySearch

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Unable to create the API URL."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .noCitiesFound:
            return "No matching cities found."
        case .emptySearch:
            return "Please enter a city name."
        }
    }
}

final class WeatherAPIClient: WeatherAPIProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let evaluator = SuitabilityEvaluator()
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - City Search

    func searchCities(query: String) async throws -> [City] {
        let searchText = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !searchText.isEmpty else {
            throw WeatherAPIError.emptySearch
        }

        var components = URLComponents(
            string: "https://geocoding-api.open-meteo.com/v1/search"
        )

        components?.queryItems = [
            URLQueryItem(name: "name", value: searchText),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw WeatherAPIError.invalidURL
        }

        let response: GeocodingResponse =
            try await request(url: url)

        guard let cities = response.results, !cities.isEmpty else {
            throw WeatherAPIError.noCitiesFound
        }

        return cities
    }

    // MARK: - Weather Forecast

    func fetchForecast(
        for city: City
    ) async throws -> [DailyForecast] {

        var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(city.latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(city.longitude)
            ),
            URLQueryItem(
                name: "daily",
                value: [
                    "weather_code",
                    "temperature_2m_max",
                    "temperature_2m_min",
                    "precipitation_probability_max",
                    "wind_speed_10m_max",
                    "snowfall_sum"
                ].joined(separator: ",")
            ),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components?.url else {
            throw WeatherAPIError.invalidURL
        }

        let response: ForecastResponse =
            try await request(url: url)

        return response.daily.forecasts
    }

    // MARK: - Shared Networking

    private func request<T: Decodable>(
        url: URL
    ) async throws -> T {

        let (data, response) = try await session.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.httpError(
                httpResponse.statusCode
            )
        }

        return try decoder.decode(T.self, from: data)
    }
}
