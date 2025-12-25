# HealthKitManager - AI Agent Instructions

## Project Overview
SwiftUI-based iOS app that tracks and visualizes walking/running steps, distances, and cycling activities from Apple HealthKit. Features include a gamified Elbe river route progress tracker and a yearly habit calendar.

## Architecture

### Core Components
- **HealthKitManager.swift**: Central `ObservableObject` managing all HealthKit queries and data aggregation
  - Publishes separate states for daily/yearly metrics (`dailySteps`, `yearlySteps`, etc.)
  - Uses `HKObserverQuery` for real-time updates via `observeStepChanges()` and `observeCyclingChanges()`
  - Data source attribution tracked in dictionaries: `stepSources`, `distanceSources`, `cyclingSources`
  
- **ContentView.swift**: Main tabbed interface with 3 views
  - Tab 1: Health data dashboard with today/thisYear picker
  - Tab 2: Elbe river progress chart (`ElbeProgressVerticalChartView`)
  - Tab 3: Habit calendar (`HabitCalendarView`)

- **ElbeProgressLineChart.swift**: Visual journey along 1300km Elbe river route
  - Milestone-based progress from Elbquelle to Cuxhaven
  - Combines `yearlyDistance` and `yearlyCyclingDistance` for total progress
  - Uses SwiftUI Charts with dynamic annotations

- **HabitCalendarView.swift**: Year-at-a-glance habit tracker
  - Persistent storage via `@AppStorage("completedDaysRaw")` as JSON string
  - 12-month grid with toggleable completion status per day

## Key Patterns

### Data Fetching
- Always use `HKQuery.predicateForSamples(withStart:end:options:)` with `.strictStartDate`
- Fetch data via `HKStatisticsQuery` with `.cumulativeSum` option
- Update UI on `DispatchQueue.main.async` after queries complete

### Localization
- All user-facing strings use `NSLocalizedString()` or `LocalizedStringKey`
- String keys defined in `Localizable.xcstrings` (e.g., "steps", "distance", "time_period")

### State Management
- Health data flows: HealthKit → HealthKitManager (ObservableObject) → Views
- UI uses `@StateObject` for HealthKitManager, `@Binding` for child view data passing
- Habit calendar persists to UserDefaults via `@AppStorage`

### HealthKit Authorization
Required entitlements in `HealthKitManager.entitlements`:
- `com.apple.developer.healthkit`
- `com.apple.developer.healthkit.access`
- `com.apple.developer.healthkit.background-delivery`

## Development Workflow

### Building & Running
- Open `HealthKitManager.xcodeproj` in Xcode
- Requires physical iOS device or simulator with HealthKit support
- Test HealthKit integration requires sample health data or actual device data

### Adding Health Metrics
1. Add quantity type to `HealthKitManager.init()` (e.g., `HKQuantityType.quantityType(forIdentifier: .heartRate)`)
2. Request in `requestAuthorization()` typesToRead set
3. Create fetch method following `fetchDailyCyclingData()` pattern
4. Add `@Published` properties for new metric
5. Update UI in ContentView with conditional display based on `selectedPeriod`

### Styling Conventions
- Use `.opacity(0.8)` for field backgrounds
- Background images set via `Image("backgroundImage2").resizable().scaledToFill().ignoresSafeArea()`
- Color scheme adapts to dark mode using `UIColor { $0.userInterfaceStyle == .dark ? ... }`

## Important Notes
- Distance values stored in meters in HealthKit, displayed as km (divide by 1000)
- Time periods enum duplicated in ContentView.swift and HealthKitManager.swift - keep synchronized
- Elbe milestones array hardcoded - modify in `ElbeProgressVerticalChartView` if route changes
- Calendar view always shows current year only (`currentYear` computed at view creation)
- **Widget Extension**: Framework configured but not implemented - `HealthManagerWidgetExtension.entitlements` exists as placeholder

## Testing
- Uses standard XCTest framework via `HealthKitManagerTests` and `HealthKitManagerUITests` targets
- HealthKit queries should be tested with mock data or actual device samples
- No HealthKit mocking infrastructure currently in place
