//
//  WeatherView.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import SwiftUI

struct WeatherView: View {

    @State private var viewModel = WeatherViewModel(
        apiClient: WeatherAPIClient()
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                CitySearchView(
                    searchText: $viewModel.searchText,
                    searchState: viewModel.searchState,
                    onSearch: {
                        await viewModel.searchCities()
                    },
                    onSelect: { city in
                        Task {
                            await viewModel.loadForecast(for: city)
                        }
                    },
                    onClear: {
                        viewModel.clearSearch()
                    }
                )
                forecastContent

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Activity Weather")
        }
    }

    @ViewBuilder
    private var forecastContent: some View {
        switch viewModel.forecastState {
        case .idle:
            ContentUnavailableView(
                "Search for a City",
                systemImage: "location.magnifyingglass",
                description: Text(
                    "Choose a city to see its 7-day forecast."
                )
            )

        case .loading:
            ProgressView("Loading forecast...")

        case .loaded(let forecasts):

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let city = viewModel.selectedCity {
                            Text(city.displayName)
                                .font(.title2.bold())
                        }
                        
                        Text("Next 7 Days")
                            .font(.headline)
                        
                        ForEach(forecasts) { forecast in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(forecast.date)
                                    .font(.headline)
                                
                                Text(
                                    "High: \(forecast.temperatureMax.formatted())°"
                                    + "  Low: "
                                    + "\(forecast.temperatureMin.formatted())°"
                                )
                                
                                Text(
                                    "Wind: "
                                    + "\(forecast.windSpeedMax.formatted()) km/h"
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                Color.secondary.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        }
                        
                        ActivityRankingView(
                            rankings: viewModel.activityRankings
                        )
                    }
                }
        case .failed(let message):
            ContentUnavailableView(
                "Forecast Unavailable",
                systemImage: "cloud.slash",
                description: Text(message)
            )
        }
    }
}
