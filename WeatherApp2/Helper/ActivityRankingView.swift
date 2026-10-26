//
//  ActivityRankingView.swift
//  WeatherApp2
//
//  Created by Avinash Shirsath on 23/10/26.
//

import SwiftUI

struct ActivityRankingView: View {

    let rankings: [Activity: [ActivityScore]]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Rankings")
                .font(.title2.bold())

            ForEach(Activity.allCases) { activity in
                activitySection(for: activity)
            }
        }
    }

    @ViewBuilder
    private func activitySection(
        for activity: Activity
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.rawValue)
                .font(.headline)

            if let scores = rankings[activity], !scores.isEmpty {
                ForEach(
                    Array(scores.enumerated()),
                    id: \.element.id
                ) { index, item in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.forecast.date)
                                .font(.subheadline)

                            Text(item.rating)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(item.score)/100")
                            .font(.subheadline.bold())
                            .monospacedDigit()
                    }
                    .padding(10)
                    .background(
                        Color.secondary.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
            } else {
                Text("No forecast available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
