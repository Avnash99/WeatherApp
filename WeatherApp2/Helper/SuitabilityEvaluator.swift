//
//  SuitabilityEvaluator.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import Foundation

enum Activity: String, CaseIterable, Identifiable {
    case skiing = "Skiing"
    case surfing = "Surfing"
    case outdoorSightseeing = "Outdoor Sightseeing"
    case indoorSightseeing = "Indoor Sightseeing"

    var id: String { rawValue }
}

struct ActivityScore: Identifiable {
    let activity: Activity
    let forecast: DailyForecast
    let score: Int

    var id: String {
        "\(activity.id)-\(forecast.date)"
    }

    var rating: String {
        switch score {
        case 80...100: "Excellent"
        case 60..<80: "Good"
        case 40..<60: "Fair"
        default: "Poor"
        }
    }
}


struct SuitabilityEvaluator {

    func score(
        for activity: Activity,
        on forecast: DailyForecast
    ) -> ActivityScore {

        let value: Int

        switch activity {
        case .skiing:
            value = skiingScore(forecast)

        case .surfing:
            value = surfingProxyScore(forecast)

        case .outdoorSightseeing:
            value = outdoorScore(forecast)

        case .indoorSightseeing:
            value = indoorScore(forecast)
        }

        return ActivityScore(
            activity: activity,
            forecast: forecast,
            score: value
        )
    }

    func rankings(
        for activity: Activity,
        forecasts: [DailyForecast]
    ) -> [ActivityScore] {

        forecasts
            .map { score(for: activity, on: $0) }
            .sorted { $0.score > $1.score }
    }

    // MARK: - Skiing

    private func skiingScore(
        _ forecast: DailyForecast
    ) -> Int {

        let temperatureScore: Double

        if (-5.0...2.0).contains(forecast.temperatureMax) {
            temperatureScore = 70
        } else if forecast.temperatureMax < -5.0 {
            temperatureScore = 55
        } else {
            temperatureScore = 25
        }

        let snowScore: Double

        if let snowfall = forecast.snowfall {
            snowScore = min(snowfall * 20, 100)
        } else {
            snowScore = 50
        }

        return weightedScore([
            (temperatureScore, 0.4),
            (snowScore, 0.6)
        ])
    }

    // MARK: - Surfing

    // Weather proxy only: this does NOT measure wave quality.
    private func surfingProxyScore(
        _ forecast: DailyForecast
    ) -> Int {

        let windScore = linearScore(
            value: forecast.windSpeedMax,
            ideal: 10,
            worst: 50
        )

        let weatherScore = weatherConditionScore(
            forecast.weatherCode
        )

        return weightedScore([
            (windScore, 0.6),
            (weatherScore, 0.4)
        ])
    }

    // MARK: - Outdoor Sightseeing

    private func outdoorScore(
        _ forecast: DailyForecast
    ) -> Int {

        let temperature = (forecast.temperatureMax
            + forecast.temperatureMin) / 2

        let temperatureScore = linearScore(
            value: abs(temperature - 21),
            ideal: 0,
            worst: 25
        )

        let rainScore: Double

        if let probability = forecast.precipitationProbability {
            rainScore = 100 - Double(probability)
        } else {
            rainScore = 50
        }

        let windScore = linearScore(
            value: forecast.windSpeedMax,
            ideal: 5,
            worst: 50
        )

        let weatherScore = weatherConditionScore(
            forecast.weatherCode
        )

        return weightedScore([
            (temperatureScore, 0.35),
            (rainScore, 0.30),
            (windScore, 0.15),
            (weatherScore, 0.20)
        ])
    }

    // MARK: - Indoor Sightseeing

    private func indoorScore(
        _ forecast: DailyForecast
    ) -> Int {

        let rainScore: Double

        if let probability = forecast.precipitationProbability {
            rainScore = Double(probability)
        } else {
            rainScore = 50
        }

        let weatherScore = 100.0
            - weatherConditionScore(forecast.weatherCode)

        let temperature = (forecast.temperatureMax
            + forecast.temperatureMin) / 2

        let temperatureScore = linearScore(
            value: abs(temperature - 21),
            ideal: 0,
            worst: 25
        )

        return weightedScore([
            (rainScore, 0.45),
            (weatherScore, 0.35),
            (temperatureScore, 0.20)
        ])
    }

    // MARK: - Shared Helpers

    private func weatherConditionScore(
        _ code: Int
    ) -> Double {

        switch code {
        case 0:
            return 100
        case 1, 2:
            return 85
        case 3:
            return 65
        case 45, 48:
            return 45
        case 51...67, 80...82:
            return 30
        case 71...77, 85...86:
            return 35
        case 95...99:
            return 5
        default:
            return 50
        }
    }

    private func linearScore(
        value: Double,
        ideal: Double,
        worst: Double
    ) -> Double {

        guard worst > ideal else { return 50 }

        let normalized = (value - ideal) / (worst - ideal)

        return min(max(100 * (1 - normalized), 0), 100)
    }

    private func weightedScore(
        _ components: [(score: Double, weight: Double)]
    ) -> Int {

        let totalWeight = components.reduce(0.0) {
            $0 + $1.weight
        }

        guard totalWeight > 0 else { return 0 }

        let result = components.reduce(0.0) {
            $0 + ($1.score * $1.weight)
        } / totalWeight

        return min(max(Int(result.rounded()), 0), 100)
    }
}
