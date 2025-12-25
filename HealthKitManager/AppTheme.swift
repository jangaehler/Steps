//
//  AppTheme.swift
//  HealthKitManager
//
//  Theme colors and styles for the app
//

import SwiftUI

extension Color {
    // MARK: - Elbe Chart Colors (2025)
    static let elbePathCompleted = Color.yellow
    static let elbeMilestone = Color.orange
    static let elbeFigure = Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .orange })
    static let elbeBicycle = Color(UIColor { $0.userInterfaceStyle == .dark ? .yellow : .black })
    
    // MARK: - Rhein Chart Colors (2026)
    static let rheinPathCompleted = Color(red: 0.2, green: 0.5, blue: 0.8)
    static let rheinMilestone = Color(red: 0.4, green: 0.7, blue: 0.95)
    static let rheinFigure = Color(UIColor { $0.userInterfaceStyle == .dark ? .white : UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0) })
    static let rheinBicycle = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0) : UIColor(red: 0.15, green: 0.4, blue: 0.7, alpha: 1.0) })
    
    // MARK: - UI Background Colors
    static let fieldBackground = Color(.systemGray6).opacity(0.8)
}

// MARK: - Chart Theme Configuration
struct ChartTheme {
    let pathColor: Color
    let milestoneColor: Color
    let figureColor: Color
    let bicycleColor: Color
    let axisColor: Color
    let remainingPathColor: Color
    
    static let elbe = ChartTheme(
        pathColor: .elbePathCompleted,
        milestoneColor: .elbeMilestone,
        figureColor: .elbeFigure,
        bicycleColor: .elbeBicycle,
        axisColor: .orange.opacity(0.6),
        remainingPathColor: .gray.opacity(0.3)
    )
    
    static let rhein = ChartTheme(
        pathColor: .rheinPathCompleted,
        milestoneColor: .rheinMilestone,
        figureColor: .rheinFigure,
        bicycleColor: .rheinBicycle,
        axisColor: Color(red: 0.4, green: 0.7, blue: 0.95).opacity(0.6),
        remainingPathColor: .gray.opacity(0.8)
    )
}
