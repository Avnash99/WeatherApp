//
//  CitySearchView.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import SwiftUI

struct CitySearchView: View {

    @Binding var searchText: String

    let searchState: CitySearchState
    let onSearch: () async -> Void
    let onSelect: (City) -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                TextField("Enter city name", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await onSearch()
                        }
                    }

                if !searchText.isEmpty {
                    Button {
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    Task {
                        await onSearch()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    searchText.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }

            switch searchState {
            case .idle:
                EmptyView()

            case .loading:
                ProgressView("Searching cities...")

            case .results(let cities):
                ForEach(cities) { city in
                    Button {
                        onSelect(city)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(city.name)
                                    .font(.headline)

                                Text(city.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                }

            case .empty:
                ContentUnavailableView(
                    "No Cities Found",
                    systemImage: "mappin.slash",
                    description: Text(
                        "Try another city or town name."
                    )
                )

            case .failed(let message):
                Text(message)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }
}
