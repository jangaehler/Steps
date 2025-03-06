import SwiftUI
import Charts

struct ElbeProgressVerticalChartView: View {
    @Binding var yearlyDistance: Double  // ✅ Binding to healthKitManager.yearlyDistance
    
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
    
    var body: some View {
        ZStack {
            VStack {
                Text("Dein Fortschritt entlang der Elbe")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.white)
                
                Chart {
                    // Completed Path (Blue)
                    ForEach(milestones.filter { $0.distance <= yearlyDistance }, id: \.distance) { milestone in
                        LineMark(
                            x: .value("Meilenstein", 1),
                            y: .value("Distanz", milestone.distance)
                        )
                        .foregroundStyle(.green)
                    }
                    
                    // Milestone Points
                    ForEach(milestones, id: \.distance) { milestone in
                        PointMark(
                            x: .value("Meilenstein", 1),
                            y: .value("Distanz", milestone.distance)
                        )
                        .foregroundStyle(.green)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text(milestone.location)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    
                    // 📍 Dynamic Progress Point
                    PointMark(
                        x: .value("Meilenstein", 1),
                        y: .value("Distanz", yearlyDistance/1000)  // ✅ Now bound to HealthKit data
                    )
                    .foregroundStyle(.black)
                    .symbolSize(60)
                    .annotation(position: .leading, alignment: .trailing) {
                        
                        Label("Du bist hier!", systemImage: "figure.walk")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.black)
                    }
                }
                .chartXAxis(.hidden)
                .chartYScale(domain: 0...1300)
                .chartPlotStyle { plotContent in
                            plotContent
                                .padding(20) // ✅ Innerer Abstand für den Chart-Bereich
                                .background(Color.white.opacity(0.8)) // Sichtbarer Bereich für Kontrolle
                                .cornerRadius(10)
                        }
                .frame(height: 600)
                .padding(10)
                
                Text("\(Int(yearlyDistance)) km von 1.300 km")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(5)
        }
    }
}

