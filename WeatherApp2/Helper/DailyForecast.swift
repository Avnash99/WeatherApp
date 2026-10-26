//
//  DailyForecast.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import Foundation

struct DailyForecast: Identifiable, Decodable {
    var id: String { date }

    let date: String
    let weatherCode: Int
    let temperatureMax: Double
    let temperatureMin: Double
    let precipitationProbability: Int?
    let windSpeedMax: Double
    let snowfall: Double?

    enum CodingKeys: String, CodingKey {
        case date = "time"
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationProbability =
            "precipitation_probability_max"
        case windSpeedMax = "wind_speed_10m_max"
        case snowfall = "snowfall_sum"
    }
}

struct ForecastResponse: Decodable {
    let daily: DailyData

    struct DailyData: Decodable {
        let time: [String]
        let weatherCode: [Int]
        let temperatureMax: [Double]
        let temperatureMin: [Double]
        let precipitationProbability: [Int]?
        let windSpeedMax: [Double]
        let snowfall: [Double]?

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case precipitationProbability =
                "precipitation_probability_max"
            case windSpeedMax = "wind_speed_10m_max"
            case snowfall = "snowfall_sum"
        }

        var forecasts: [DailyForecast] {
            time.indices.compactMap { index in
                guard weatherCode.indices.contains(index),
                      temperatureMax.indices.contains(index),
                      temperatureMin.indices.contains(index),
                      windSpeedMax.indices.contains(index)
                else {
                    return nil
                }

                return DailyForecast(
                    date: time[index],
                    weatherCode: weatherCode[index],
                    temperatureMax: temperatureMax[index],
                    temperatureMin: temperatureMin[index],
                    precipitationProbability:
                        precipitationProbability.flatMap {
                            $0.indices.contains(index)
                                ? $0[index] : nil
                        },
                    windSpeedMax: windSpeedMax[index],
                    snowfall: snowfall.flatMap {
                        $0.indices.contains(index)
                            ? $0[index] : nil
                    }
                )
            }
        }
    }
}
