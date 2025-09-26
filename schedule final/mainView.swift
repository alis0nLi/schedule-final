//
//  main.swift
//  schedule final
//
//  Created by Alison on 05/07/2025.
//

import SwiftUI

// MARK: - Main Schedule View
struct MainScheduleView: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @State private var selectedView: ScheduleViewType = .day
    @State private var showingAddItem = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                
                // Top bar
                HStack {
                    // Settings button
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Current time display
                    Text(getTimeString(from: currentTime))
                        .font(.system(size: 45, weight: .bold))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 5)
                        )
                    
                    Spacer()
                    
                    // Plus button → Add Item page
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // View switch buttons
                HStack(spacing: 20) {
                    ForEach(ScheduleViewType.allCases, id: \.self) { type in
                        viewSwitchButton(type)
                    }
                }
                
                Divider()
                
                // Display selected view
                Group {
                    switch selectedView {
                    case .day: DayView()
                    case .week: WeekView()
                    case .month: MonthView()
                    case .year: YearView()
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 24)
            }
            .onReceive(timer) { input in
                currentTime = input
            }
            .navigationDestination(isPresented: $showingAddItem) {
                AddItemView()
            }
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - View Switch Button
    private func viewSwitchButton(_ type: ScheduleViewType) -> some View {
        Button(action: { selectedView = type }) {
            Text(type.rawValue)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(selectedView == type ? Color.white : Color.black)
                .padding(.horizontal, 60)
                .padding(.vertical, 30)
                .background(selectedView == type ? Color.blue : Color.blue.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Helpers
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    func getTimeString(from date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
}

// MARK: - Enum for Views
enum ScheduleViewType: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// MARK: - Day View
struct DayView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("8:45 am")
                .font(.system(size: 36, weight: .bold))
            Spacer()
            Text("9:00 pm")
                .font(.system(size: 36, weight: .bold))
        }
        .padding()
    }
}

// MARK: - Week View
struct WeekView: View {
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 20) {
                ForEach(days, id: \.self) { day in
                    DayScheduleView(day: day)
                        .frame(width: 400)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.vertical)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DayScheduleView: View {
    let day: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(day)
                .font(.system(size: 40, weight: .bold))
                .padding(.top, 10)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sampleEvents(for: day), id: \.self) { event in
                    Text(event)
                        .font(.subheadline)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 10)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    func sampleEvents(for day: String) -> [String] {
        ["will co-ordinate with user's entered events"]
    }
}

// MARK: - Month View
struct MonthView: View {
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var days: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }
    
    private var startingWeekdayOffset: Int {
        let firstDay = daysInMonth.first ?? Date()
        let weekday = calendar.component(.weekday, from: firstDay)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            // Month navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 36, weight: .bold))
                        .padding(10)
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.system(size: 42, weight: .bold))
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 36, weight: .bold))
                        .padding(10)
                }
            }
            
            // Weekday headers
            let weekdays = dateFormatter.shortWeekdaySymbols ?? ["S","M","T","W","T","F","S"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 22, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                }
            }
            
            // Calendar grid fills available vertical space
            GeometryReader { geo in
                let totalRows = ((daysInMonth.count + startingWeekdayOffset) / 7) + 1
                let cellHeight = geo.size.height / CGFloat(totalRows)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                    ForEach(0..<startingWeekdayOffset, id: \.self) { _ in
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: cellHeight)
                            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                    }
                    ForEach(daysInMonth, id: \.self) { day in
                        let isSelected = selectedDate == day
                        let isToday = calendar.isDateInToday(day)
                        Text("\(calendar.component(.day, from: day))")
                            .font(.system(size: 30, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: cellHeight)
                            .background(
                                isSelected ? Color.blue :
                                    (isToday ? Color.blue.opacity(0.3) : Color.clear)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                            .onTapGesture { selectedDate = day }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            Divider().padding(.vertical, 5)
            
            if let selectedDate = selectedDate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Events for \(dayString(from: selectedDate))")
                        .font(.title2).bold()
                    ForEach(sampleEvents(for: selectedDate), id: \.self) { event in
                        Text("• \(event)")
                            .font(.system(size: 20))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.horizontal)
    }
    
    private func monthYearString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func dayString(from date: Date) -> String {
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    private func sampleEvents(for date: Date) -> [String] { ["No events"] }
    
    private func changeMonth(by value: Int) {
        currentMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) ?? Date()
    }
}

// MARK: - Year View
struct YearView: View {
    var body: some View {
        Text("Year View")
            .font(.largeTitle)
    }
}

// MARK: - Add Item View
struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("Add Items")
                .font(.system(size: 40, weight: .bold))
            
            // Example item
            HStack {
                Image(systemName: "alarm.fill") // Icon
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
                    .padding(.trailing, 10)
                Text("Wake Up")
                    .font(.title2).bold()
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("Settings")
                .font(.system(size: 40, weight: .bold))
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
struct MainScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        MainScheduleView()
    }
}
