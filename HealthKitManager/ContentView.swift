//
//  ContentView.swift
//  HealthKitManager
//
//  Created by Jan Gähler on 22.02.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedPeriod: TimePeriod = .today  // State for period selection
    let fieldBackgroundColor: Color = Color(.systemGray6).opacity(0.8)

    var body: some View {
        ZStack {
            // Background Image
            Image("backgroundImage2")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20)
            {
                Text("Health Data")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                // Picker for Today / This Year
                Picker("Time Period", selection: $selectedPeriod) {
                    Text("Today").tag(TimePeriod.today)
                    Text("This Year").tag(TimePeriod.thisYear)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(fieldBackgroundColor))
                .foregroundColor(.white)

                // Display Health Data Based on Selection
                if selectedPeriod == .today {
                    HealthDataView(title: "Steps", value: "\(healthKitManager.dailySteps)")
                    HealthDataView(title: "Distance", value: String(format: "%.2f km", healthKitManager.dailyDistance / 1000))
                    SourceListView(title: "Step Sources", sources: healthKitManager.stepSources)
                    SourceListView(title: "Distance Sources", sources: healthKitManager.distanceSources)
                } else {
                    HealthDataView(title: "Steps (This Year)", value: "\(healthKitManager.yearlySteps)")
                    HealthDataView(title: "Distance (This Year)", value: String(format: "%.2f km", healthKitManager.yearlyDistance / 1000))
                    SourceListView(title: "Step Sources (This Year)", sources: healthKitManager.yearlyStepSources)
                    SourceListView(title: "Distance Sources (This Year)", sources: healthKitManager.yearlyDistanceSources)
                }

                Spacer()
            }
            .padding(40)
        }
    }
}

// Enum for Time Period Selection
enum TimePeriod {
    case today, thisYear
}

struct HealthDataView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6).opacity(0.8)))
    }
}

struct SourceListView: View {
    let title: String
    let sources: [String: Double]  // Ensuring Double for consistency
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            ForEach(sources.sorted(by: { $0.value > $1.value }), id: \.key) { source, value in
                HStack {
                    Text(source)
                    Spacer()
                    Text(quantityFormat(for: value))  // Correct format for Steps/Distance
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6).opacity(0.8)))
    }
    
    private func quantityFormat(for value: Double) -> String {
        return title.contains("Step") ? "\(Int(value))" : String(format: "%.2f km", value / 1000)
    }
}

// A SwiftUI preview.
#Preview {
    ContentView()
}
