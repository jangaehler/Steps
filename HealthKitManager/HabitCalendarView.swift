//
//  HabitCalendarView.swift
//  HealthKitManager
//
//  Created by Jan Gähler on 15.07.25.
//

import SwiftUI

struct HabitCalendarView: View {
    @AppStorage("completedDaysRaw") private var completedDaysRaw: String = "{}"
    
    private let calendar = Calendar.current
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 8) {
                // Month labels
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 12), spacing: 4) {
                    ForEach(1...12, id: \.self) { month in
                        Text(monthAbbreviation(month))
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 2)
                    }
                }
                // Day buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 12), spacing: 4) {
                    ForEach(1...maxDaysInAnyMonth, id: \.self) { day in
                        ForEach(1...12, id: \.self) { month in
                            let days = generateMonthDays(for: currentYear, month: month)
                            if day <= days.count {
                                let date = days[day - 1]
                                Button(action: {
                                    toggleCompletion(for: date)
                                }) {
                                    Circle()
                                        .fill(isCompleted(date) ? Color.yellow : Color.gray.opacity(0.75))
                                        .frame(width: 28, height: 28)
                                }
                            } else {
                                // Empty cell for months with fewer days
                                Color.clear
                                    .frame(width: 28, height: 28)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func generateYearDays(for year: Int) -> [Date] {
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let range = calendar.range(of: .day, in: .year, for: startOfYear)!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfYear) }
    }
    
    private func toggleCompletion(for date: Date) {
        let key = dateKey(for: date)
        var updated = (try? JSONDecoder().decode([String: Bool].self, from: Data(completedDaysRaw.utf8))) ?? [:]
        updated[key] = !(updated[key] ?? false)
        if let data = try? JSONEncoder().encode(updated),
           let string = String(data: data, encoding: .utf8) {
            completedDaysRaw = string
        }
    }
    
    private func isCompleted(_ date: Date) -> Bool {
        completedDays[dateKey(for: date)] ?? false
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private var completedDays: [String: Bool] {
        get {
            (try? JSONDecoder().decode([String: Bool].self, from: Data(completedDaysRaw.utf8))) ?? [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                completedDaysRaw = string
            }
        }
    }

    private var maxDaysInAnyMonth: Int {
        (1...12).map { month in
            calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: currentYear, month: month, day: 1))!)!.count
        }.max() ?? 31
    }

    private func generateMonthDays(for year: Int, month: Int) -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        return range.compactMap { day in
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
    }

    private func monthAbbreviation(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1))!
        return formatter.string(from: date)
    }
}

#Preview {
    HabitCalendarView()
}
