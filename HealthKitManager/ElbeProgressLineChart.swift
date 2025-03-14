import SwiftUI
import Charts

struct ElbeProgressVerticalChartView: View {
    @Binding var yearlyDistance: Double
    
    let milestones: [(distance: Double, location: String)] = [
        (0, "Elbquelle"),
        (30, "Vrchlabi"),
        (103, "Hradec Králové"),
        (127, "Pardubice"),
        (263, "Prag"),
        (313, "Melník"),
        (385, "Ústí nad Labem"),
        (411, "Děčín"),
        (434, "Bad Schandau"),
        (478, "Dresden"),
        (504, "Meißen"),
        (646, "Lutherstadt Wittenberg"),
        (683, "Dessau"),
        (761, "Magdeburg"),
        (843, "Stendal"),
        (910, "Wittenberge"),
        (992, "Hitzacker"),
        (1046, "Lauenburg"),
        (1105, "Hamburg"),
        (1150, "Stade"),
        (1181, "Wischhafen/Glückstadt"),
        (1239, "Cuxhaven (Bahnhof)"),
        (1300, "Ziel")
    ]
    
    let yAxisValues: [Int] = Array(stride(from: 0, through: 1300, by: 100))
    
    fileprivate func getCompletePath() -> ForEach<[(distance: Double, location: String)], Double, some ChartContent> {
        return // Completed Path (Blue)
            ForEach(milestones.filter { $0.distance <= yearlyDistance }, id: \.distance) { milestone in
                LineMark(
                    x: .value("Meilenstein", 1),
                    y: .value("Distanz", milestone.distance)
                )
                .foregroundStyle(.green)
            }
    }
    
    fileprivate func getMilestonePoints() -> ForEach<[(distance: Double, location: String)], Double, some ChartContent> {
        return // Milestone Points
            ForEach(milestones, id: \.distance) { milestone in
                PointMark(
                    x: .value("Meilenstein", 1),
                    y: .value("Distanz", milestone.distance)
                )
                .foregroundStyle(.green)
                .annotation(position: .trailing, alignment: .leading) {
                    Text(milestone.location)
                        .font(.caption)
                }
            }
    }
    
    fileprivate func setDynamicProgressPoint() -> PointMark {
        return // 📍 Dynamic Progress Point
            PointMark(
                x: .value("Meilenstein", 1),
                y: .value("Distanz", yearlyDistance/1000)  // ✅ Now bound to HealthKit data
            )
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                GroupBox (label: Label("Dein Fortschritt entlang der Elbe", systemImage: "figure.walk").font(.headline)) {
                Chart {
                    getCompletePath()
                    getMilestonePoints()
                    setDynamicProgressPoint()
                    .symbolSize(60)
                    .annotation(position: .leading, alignment: .trailing) {
                        
                        Text("Du bist hier!")
                            .font(.caption)
                            .bold()
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: yAxisValues) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: 0...1300)
                .frame(height: 600)
                .padding(20)
                
                    Text("\(Double(yearlyDistance / 1000).formatted(.number.locale(Locale(identifier: "de_DE")).precision(.fractionLength(2)))) km von 1.300 km")
                    .font(.headline)
                    .padding()
                }
                            .groupBoxStyle(YellowGroupBoxStyle())
            }
            .padding(5)
        }
    }
}

struct YellowGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(30)
            .background(Color(.systemGray6).opacity(0.8))
            .cornerRadius(20)
            .overlay(
                configuration.label.padding(10),
                alignment: .topLeading
            )
    }
}







