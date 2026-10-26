//
//  WeatherViewModel.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import SwiftUI
import Observation

enum CitySearchState {
    case idle
    case loading
    case results([City])
    case empty
    case failed(String)
}

enum ForecastState {
    case idle
    case loading
    case loaded([DailyForecast])
    case failed(String)
}

@MainActor
@Observable
final class WeatherViewModel {
    
    private let apiClient: any WeatherAPIProtocol
    
    var searchState: CitySearchState = .idle
    var forecastState: ForecastState = .idle
    
    var selectedCity: City?
    var searchText = ""
    
    // Inside WeatherViewModel
    
    private let evaluator = SuitabilityEvaluator()
    
    var activityRankings: [Activity: [ActivityScore]] {
        guard case .loaded(let forecasts) = forecastState else {
            return [:]
        }
        
        return Dictionary(
            uniqueKeysWithValues: Activity.allCases.map { activity in
                (
                    activity,
                    evaluator.rankings(
                        for: activity,
                        forecasts: forecasts
                    )
                )
            }
        )
    }
    
    init(apiClient: any WeatherAPIProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Search Cities
    
    func searchCities() async {
        searchState = .loading
        
        do {
            let cities = try await apiClient.searchCities(
                query: searchText
            )
            
            try Task.checkCancellation()
            
            if cities.isEmpty {
                searchState = .empty
            } else {
                searchState = .results(cities)
            }
            
        } catch is CancellationError {
            return
            
        } catch let error as WeatherAPIError {
            if case .noCitiesFound = error {
                searchState = .empty
            } else {
                searchState = .failed(
                    error.localizedDescription
                )
            }
            
        } catch {
            searchState = .failed(
                error.localizedDescription
            )
        }
    }
    
    // MARK: - Load Forecast
    
    func loadForecast(for city: City) async {
        selectedCity = city
        forecastState = .loading
        
        do {
            let forecasts = try await apiClient.fetchForecast(
                for: city
            )
            
            try Task.checkCancellation()
            
            forecastState = .loaded(forecasts)
            
        } catch is CancellationError {
            return
        } catch {
            forecastState = .failed(
                error.localizedDescription
            )
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchState = .idle
    }
}
