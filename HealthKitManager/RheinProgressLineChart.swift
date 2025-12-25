import Charts
import SwiftUI

struct RheinProgressVerticalChartView: View {
    @Binding var yearlyDistance: Double
    @Binding var yearlyCyclingDistance: Double
    
    let theme = ChartTheme.rhein

    let milestones: [(distance: Double, location: String)] = [
        (0, "Rheinquelle (Tomasee)"),
        (120, "Chur (Bündner Herrschaft)"),
        (200, "Bodensee (Konstanz)"),
        (260, "Schaffhausen (Rheinfall)"),
        (360, "Basel"),
        (430, "Breisach am Rhein (Kaiserstuhl)"),
        (510, "Straßburg"),
        (690, "Worms"),
        (730, "Mainz (Rheinhessen)"),
        (760, "Rüdesheim (Rheingau)"),
        (770, "Bingen"),
        (830, "Lorelei (St. Goarshausen)"),
        (870, "Koblenz (Deutsches Eck)"),
        (950, "Bonn"),
        (980, "Köln"),
        (1020, "Düsseldorf"),
        (1120, "Arnhem"),
        (1190, "Rotterdam"),
        (1230, "Hoek van Holland (Nordsee)")
    ]

    let yAxisValues: [Int] = Array(stride(from: 0, through: 1500, by: 100))

    fileprivate func getCompletePath() -> ForEach<[(distance: Double, location: String)], Double, some ChartContent> {
        return // Completed Path
            ForEach(milestones.filter { $0.distance <= yearlyDistance }, id: \.distance) { milestone in
                LineMark(
                    x: .value("Meilenstein", 1),
                    y: .value("Distanz", milestone.distance)
                )
                .foregroundStyle(theme.pathColor)
            }
    }
    
    fileprivate func getRemainingPath() -> ForEach<[(distance: Double, location: String)], Double, some ChartContent> {
        return // Remaining Path
            ForEach(milestones.filter { $0.distance > yearlyDistance }, id: \.distance) { milestone in
                LineMark(
                    x: .value("Meilenstein", 1),
                    y: .value("Distanz", milestone.distance)
                )
                .foregroundStyle(theme.remainingPathColor)
            }
    }

    fileprivate func getMilestonePoints() -> ForEach<[(distance: Double, location: String)], Double, some ChartContent> {
        return // Milestone Points
            ForEach(milestones, id: \.distance) { milestone in
                PointMark(
                    x: .value("Meilenstein", 1),
                    y: .value("Distanz", milestone.distance)
                )
                .foregroundStyle(theme.milestoneColor)
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
                y: .value("Distanz", yearlyDistance / 1000)
            )
    }

    fileprivate func setCyclingProgressPoint() -> PointMark {
        return PointMark(
            x: .value("Meilenstein", 1),
            y: .value("Distanz", yearlyCyclingDistance / 1000) // In km umrechnen
        )
    }

    fileprivate func setFigureColor() -> Color {
        return theme.figureColor
    }

    fileprivate func setBicycleColor() -> Color {
        return theme.bicycleColor
    }

    var body: some View {
        ZStack {
            VStack {
                GroupBox(
                    label: HStack {
                        Spacer()
                        Text("Dein Fortschritt am Rhein 2026")
                        Spacer()
                    }.font(.headline)
                ) {
                    Chart {
                        getRemainingPath()
                        getCompletePath()
                        getMilestonePoints()
                        setDynamicProgressPoint()
                            .symbolSize(60)
                            .foregroundStyle(setFigureColor())
                            .annotation(position: .leading, alignment: .trailing) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 20)) // Größe ändern
                                    .foregroundColor(setFigureColor())
                                    .padding(5)
                            }

                        setCyclingProgressPoint()
                            .symbolSize(40)
                            .foregroundStyle(setBicycleColor())
                            .annotation(position: .leading, alignment: .trailing) {
                                Image(systemName: "bicycle")
                                    .font(.system(size: 20)) // Größe ändern
                                    .foregroundColor(setBicycleColor())
                                    .padding(5)
                            }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: yAxisValues) {
                            AxisGridLine().foregroundStyle(theme.axisColor)
                            AxisTick().foregroundStyle(theme.axisColor)
                            AxisValueLabel().foregroundStyle(theme.axisColor)
                        }
                    }
                    .chartYScale(domain: 0 ... 1500)
                    .frame(height: 600)
                    .padding(20)

                    VStack {
                        Text("\(Double(yearlyDistance / 1000).formatted(.number.locale(Locale(identifier: "de_DE")).precision(.fractionLength(2)))) km von 1.230 km")
                            .font(.headline)

                        Text("\(Double(yearlyCyclingDistance / 1000).formatted(.number.locale(Locale(identifier: "de_DE")).precision(.fractionLength(2)))) km Fahrrad")
                            .font(.subheadline)
                    }
                }
                .groupBoxStyle(BlueGroupBoxStyle())
            }
            .padding(5)
        }
    }
}

struct BlueGroupBoxStyle: GroupBoxStyle {
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
