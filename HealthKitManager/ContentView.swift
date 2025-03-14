import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedPeriod: TimePeriod = .today

    let fieldBackgroundColor: Color = Color(.systemGray6).opacity(0.8)

    var body: some View {
        TabView {
            VStack(spacing: 20) {
                Text("Health Data")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                // Picker für Zeiträume
                Picker(
                    LocalizedStringKey("time_period"),
                    selection: $selectedPeriod
                ) {
                    Text(LocalizedStringKey("today")).tag(TimePeriod.today)
                    Text(LocalizedStringKey("this_year"))
                        .tag(TimePeriod.thisYear)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(fieldBackgroundColor)
                )
                .foregroundColor(.white)

                // Anzeigen der Gesundheitsdaten
                if selectedPeriod == .today {
                    HealthDataView(
                        title: NSLocalizedString("steps", comment: ""),
                        value: "\(healthKitManager.dailySteps)"
                    )
                    HealthDataView(
                        title: NSLocalizedString("distance", comment: ""),
                        value: String(
                            format: "%.2f km",
                            healthKitManager.dailyDistance / 1000
                        )
                    )
                    SourceListView(
                        title: NSLocalizedString("step_sources", comment: ""),
                        sources: healthKitManager.stepSources
                    )
                    SourceListView(
                        title: NSLocalizedString(
                            "distance_sources",
                            comment: ""
                        ),
                        sources: healthKitManager.distanceSources
                    )
                } else {
                    HealthDataView(
                        title: NSLocalizedString("steps", comment: ""),
                        value: "\(healthKitManager.yearlySteps)"
                    )
                    HealthDataView(
                        title: NSLocalizedString("distance", comment: ""),
                        value: String(
                            format: "%.2f km",
                            healthKitManager.yearlyDistance / 1000
                        )
                    )
                    SourceListView(
                        title: NSLocalizedString("step_sources", comment: ""),
                        sources: healthKitManager.yearlyStepSources
                    )
                    SourceListView(
                        title: NSLocalizedString(
                            "distance_sources",
                            comment: ""
                        ),
                        sources: healthKitManager.yearlyDistanceSources
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // ✅ Fixes VStack to the top
            .padding()

            // 📊 Fortschrittsansicht (Elbe-Radweg)
            ElbeProgressVerticalChartView(
                yearlyDistance: $healthKitManager.yearlyDistance,
                yearlyCyclingDistance: $healthKitManager.yearlyCyclingDistance
            )
            .padding()
        }
        .tabViewStyle(.page)
        .background(
            Image("backgroundImage2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
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
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.8))
        )
    }
}

struct SourceListView: View {
    let title: String
    let sources: [String: Double]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            ForEach(
                sources.sorted(by: { $0.value > $1.value }),
                id: \.key
            ) { source, value in
                HStack {
                    Text(source)
                    Spacer()
                    Text(quantityFormat(for: value))
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.8))
        )
    }

    private func quantityFormat(for value: Double) -> String {
        return title
            .contains(NSLocalizedString("step", comment: "")) ? "\(Int(value))" : String(
                format: "%.2f km",
                value / 1000
            )
    }
}

// Enum for Time Period Selection
enum TimePeriod {
    case today, thisYear
}
