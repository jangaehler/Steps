//
//  HealthKitManager.swift
//  HealthKitManager
//
//  Created by Jan Gähler on 22.02.25.
//

import Combine
import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var dailySteps: Int = 0
    @Published var dailyDistance: Double = 0.0
    @Published var yearlySteps: Int = 0
    @Published var yearlyDistance: Double = 0.0
    @Published var stepSources: [String: Double] = [:]
    @Published var distanceSources: [String: Double] = [:]
    @Published var yearlyStepSources: [String: Double] = [:]
    @Published var yearlyDistanceSources: [String: Double] = [:]
    @Published var dailyCyclingDistance: Double = 0.0
    @Published var yearlyCyclingDistance: Double = 0.0
    @Published var dailyCyclingTime: Double = 0.0
    @Published var yearlyCyclingTime: Double = 0.0
    @Published var dailyCyclingSources: [String: Double] = [:]
    @Published var yearlyCyclingSources: [String: Double] = [:]
    
    // Year-specific data for 2025 (Elbe) and 2026 (Rhein)
    @Published var year2025Distance: Double = 0.0
    @Published var year2025CyclingDistance: Double = 0.0
    @Published var year2026Distance: Double = 0.0
    @Published var year2026CyclingDistance: Double = 0.0

    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let cyclingDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!

    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let typesToRead: Set = [
            stepType,
            distanceType,
            cyclingDistanceType
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.fetchDailyData()
                self.fetchYearlyData()
                self.observeStepChanges()
                self.fetchDailyCyclingData()
                self.fetchYearlyCyclingData()
                self.observeCyclingChanges()
                self.fetchYear2025Data()
                self.fetchYear2026Data()

            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func fetchDailyData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        fetchHealthData(for: stepType, startDate: startOfDay) { steps in
            DispatchQueue.main.async {
                self.dailySteps = Int(steps)
            }
        }
        
        fetchHealthData(for: distanceType, startDate: startOfDay) { distance in
            DispatchQueue.main.async {
                self.dailyDistance = distance
            }
        }
        
        fetchDataSources(for: stepType, timePeriod: .today) { sources in
            DispatchQueue.main.async {
                self.stepSources = sources
            }
        }
        
        fetchDataSources(for: distanceType, timePeriod: .today) { sources in
            DispatchQueue.main.async {
                self.distanceSources = sources
            }
        }
    }
    
    private func fetchYearlyData() {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        
        // Fetch yearly steps
        fetchHealthData(for: stepType, startDate: startOfYear) { steps in
            DispatchQueue.main.async {
                self.yearlySteps = Int(steps)
            }
        }
        
        // Fetch yearly distance
        fetchHealthData(for: distanceType, startDate: startOfYear) { distance in
            DispatchQueue.main.async {
                self.yearlyDistance = distance
            }
        }
        
        // Fetch yearly step sources
        fetchDataSources(for: stepType, timePeriod: .thisYear) { sources in
            DispatchQueue.main.async {
                self.yearlyStepSources = sources
            }
        }
        
        // Fetch yearly distance sources
        fetchDataSources(for: distanceType, timePeriod: .thisYear) { sources in
            DispatchQueue.main.async {
                self.yearlyDistanceSources = sources
            }
        }
    }
    
    private func fetchHealthData(for quantityType: HKQuantityType, startDate: Date, completion: @escaping (Double) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let value = sum.doubleValue(for: quantityType == self.stepType ? HKUnit.count() : HKUnit.meter())
            completion(value)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchDataSources(for quantityType: HKQuantityType, timePeriod: TimePeriod, completion: @escaping ([String: Double]) -> Void) {
        let calendar = Calendar.current
        let startDate: Date
        
        switch timePeriod {
        case .today:
            startDate = calendar.startOfDay(for: Date())
        case .thisYear:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSourceQuery(sampleType: quantityType, samplePredicate: predicate) { _, sources, error in
            guard let sources = sources, error == nil else {
                completion([:])
                return
            }
            
            var sourceData: [String: Double] = [:] // Ensuring Double for consistency
            let dispatchGroup = DispatchGroup()
            
            for source in sources {
                dispatchGroup.enter()
                self.fetchHealthDataFromSource(for: quantityType, source: source, startDate: startDate) { value in
                    if value > 0 {
                        sourceData[source.name] = value // Ensuring Double storage
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                print("Final \(quantityType.identifier) Sources (\(timePeriod)): \(sourceData)") // Debugging output
                print("Datatype: \(type(of: sourceData))") // Type checking
                completion(sourceData)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHealthDataFromSource(for quantityType: HKQuantityType, source: HKSource, startDate: Date, completion: @escaping (Double) -> Void) {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate),
            HKQuery.predicateForObjects(from: source)
        ])
        
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let value = sum.doubleValue(for: quantityType == self.stepType ? HKUnit.count() : HKUnit.meter())
            completion(value)
        }
        
        healthStore.execute(query)
    }
    
    // Neue Methoden für Fahrraddaten
    private func fetchDailyCyclingData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
           
        // Fahrradstrecke
        fetchHealthData(for: cyclingDistanceType, startDate: startOfDay) { distance in
            DispatchQueue.main.async {
                self.dailyCyclingDistance = distance
            }
        }
           
        // Quellen für Fahrraddaten
        fetchDataSources(for: cyclingDistanceType, timePeriod: .today) { sources in
            DispatchQueue.main.async {
                self.dailyCyclingSources = sources
            }
        }
    }
       
    private func fetchYearlyCyclingData() {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
           
        // Jährliche Fahrradstrecke
        fetchHealthData(for: cyclingDistanceType, startDate: startOfYear) { distance in
            DispatchQueue.main.async {
                self.yearlyCyclingDistance = distance
            }
        }
           
        // Quellen für jährliche Fahrraddaten
        fetchDataSources(for: cyclingDistanceType, timePeriod: .thisYear) { sources in
            DispatchQueue.main.async {
                self.yearlyCyclingSources = sources
            }
        }
    }
       
    private func observeCyclingChanges() {
        let cyclingQuery = HKObserverQuery(sampleType: cyclingDistanceType, predicate: nil) { _, _, _ in
            self.fetchDailyCyclingData()
            self.fetchYearlyCyclingData()
        }
           
        healthStore.execute(cyclingQuery)
    }

    private func observeStepChanges() {
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, _, _ in
            self.fetchDailyData()
            self.fetchYearlyData()
        }
        
        healthStore.execute(query)
    }
    
    enum TimePeriod {
        case today
        case thisYear
    }
    
    // Fetch data for year 2025 (Elbe)
    private func fetchYear2025Data() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        
        guard let startOf2025 = calendar.date(from: components) else { return }
        
        components.year = 2026
        guard let endOf2025 = calendar.date(from: components) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOf2025, end: endOf2025, options: .strictStartDate)
        
        // Fetch walking/running distance for 2025
        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.year2025Distance = 0 }
                return
            }
            let value = sum.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async { self.year2025Distance = value }
        }
        
        // Fetch cycling distance for 2025
        let cyclingQuery = HKStatisticsQuery(quantityType: cyclingDistanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.year2025CyclingDistance = 0 }
                return
            }
            let value = sum.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async { self.year2025CyclingDistance = value }
        }
        
        healthStore.execute(distanceQuery)
        healthStore.execute(cyclingQuery)
    }
    
    // Fetch data for year 2026 (Rhein)
    private func fetchYear2026Data() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        
        guard let startOf2026 = calendar.date(from: components) else { return }
        
        components.year = 2027
        guard let endOf2026 = calendar.date(from: components) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOf2026, end: endOf2026, options: .strictStartDate)
        
        // Fetch walking/running distance for 2026
        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.year2026Distance = 0 }
                return
            }
            let value = sum.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async { self.year2026Distance = value }
        }
        
        // Fetch cycling distance for 2026
        let cyclingQuery = HKStatisticsQuery(quantityType: cyclingDistanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.year2026CyclingDistance = 0 }
                return
            }
            let value = sum.doubleValue(for: HKUnit.meter())
            DispatchQueue.main.async { self.year2026CyclingDistance = value }
        }
        
        healthStore.execute(distanceQuery)
        healthStore.execute(cyclingQuery)
    }
}
