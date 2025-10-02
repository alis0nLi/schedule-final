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
    @State private var showingAddMode = false
    @State private var showingSettings = false
    @State private var showingAddBigEventPage = false
    
    // Shared events across views (day/week/month only)
    @State private var events: [Date: [String: (icon: String, title: String)]] = [:]
    
    // Special events for Events tab
    @State private var specialEvents: [(date: Date, icon: String, title: String)] = []
    
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
                    
                    // Plus / X button
                    Button(action: {
                        if selectedView == .day {
                            showingAddMode.toggle()
                        } else if selectedView == .events {
                            showingAddBigEventPage = true
                        }
                    }) {
                        Image(systemName: showingAddMode && selectedView == .day ? "xmark" : "plus")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .disabled(selectedView == .week || selectedView == .month)
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
                    case .day:
                        DayView(showingAddMode: $showingAddMode,
                                events: $events)
                    case .week:
                        WeekView(events: $events)
                    case .month:
                        MonthView(events: $events)
                    case .events:
                        EventsFullPageView(specialEvents: $specialEvents)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 24)
            }
            .onReceive(timer) { input in
                currentTime = input
            }
            // Pushes full screen pages
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showingAddBigEventPage) {
                AddBigEventView(specialEvents: $specialEvents)
            }
        }
    }
    
    // MARK: - View Switch Button
    private func viewSwitchButton(_ type: ScheduleViewType) -> some View {
        Button(action: { selectedView = type }) {
            Text(type.rawValue)
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(selectedView == type ? Color.white : Color.black)
                .padding(.horizontal, 50)
                .padding(.vertical, 25)
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
    case events = "Events"
}

// MARK: - Day View
struct DayView: View {
    @Binding var showingAddMode: Bool
    @Binding var events: [Date: [String: (icon: String, title: String)]]
    
    @State private var selectedIcon: (icon: String, title: String)? = nil
    @State private var currentDate: Date = Date()
    
    let times = ["8:00 am", "9:00 am", "10:00 am", "11:00 am", "12:00 pm",
                 "1:00 pm", "2:00 pm", "3:00 pm", "4:00 pm", "5:00 pm"]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        return df
    }()
    
    var dateLabel: String {
        if calendar.isDateInToday(currentDate) {
            return "Today, " + dateFormatter.string(from: currentDate)
        } else if calendar.isDateInTomorrow(currentDate) {
            return "Tomorrow, " + dateFormatter.string(from: currentDate)
        } else {
            return dateFormatter.string(from: currentDate)
        }
    }
    
    var body: some View {
        VStack {
            // Date navigation
            HStack {
                Button(action: { changeDay(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 28, weight: .bold))
                        .padding(10)
                }
                Spacer()
                Text(dateLabel)
                    .font(.system(size: 32, weight: .bold))
                Spacer()
                Button(action: { changeDay(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 28, weight: .bold))
                        .padding(10)
                }
            }
            .padding(.bottom, 10)
            
            HStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(times, id: \.self) { time in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(time).font(.headline)
                                HStack {
                                    if let dayEvents = events[startOfDay(for: currentDate)],
                                       let event = dayEvents[time] {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.icon).font(.largeTitle)
                                            Text(event.title).font(.subheadline)
                                        }
                                    }
                                }
                                .frame(height: 60)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .onTapGesture {
                                    if showingAddMode, let selected = selectedIcon {
                                        var dayEvents = events[startOfDay(for: currentDate)] ?? [:]
                                        if dayEvents[time] == nil {
                                            dayEvents[time] = selected
                                            events[startOfDay(for: currentDate)] = dayEvents
                                        }
                                        selectedIcon = nil
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if showingAddMode {
                    Divider()
                    IconPaletteClickView(selectedIcon: $selectedIcon)
                        .frame(width: 200)
                        .background(Color.gray.opacity(0.1))
                }
            }
        }
    }
    
    private func changeDay(by value: Int) {
        currentDate = calendar.date(byAdding: .day, value: value, to: currentDate) ?? currentDate
    }
    
    private func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}

// MARK: - Week View
struct WeekView: View {
    @Binding var events: [Date: [String: (icon: String, title: String)]]
    
    @State private var currentWeekStart: Date = {
        let today = Date()
        let comps = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        return Calendar.current.date(from: comps) ?? today
    }()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE d"
        return df
    }()
    
    private var weekDates: [Date] {
        var week: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: currentWeekStart) {
                week.append(date)
            }
        }
        return week
    }
    
    var body: some View {
        VStack {
            // Week navigation
            HStack {
                Button(action: { changeWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 28, weight: .bold))
                        .padding(10)
                }
                Spacer()
                Text("Week of \(dateFormatter.string(from: weekDates.first ?? Date()))")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
                Button(action: { changeWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 28, weight: .bold))
                        .padding(10)
                }
            }
            .padding(.bottom, 10)
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    ForEach(weekDates, id: \.self) { date in
                        DayScheduleView(dayDate: date,
                                        events: $events)
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
    
    private func changeWeek(by value: Int) {
        currentWeekStart = calendar.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) ?? currentWeekStart
    }
}

// MARK: - Day Schedule View for Week
struct DayScheduleView: View {
    let dayDate: Date
    @Binding var events: [Date: [String: (icon: String, title: String)]]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        return df
    }()
    
    let times = ["8:00 am", "9:00 am", "10:00 am", "11:00 am", "12:00 pm",
                 "1:00 pm", "2:00 pm", "3:00 pm", "4:00 pm", "5:00 pm"]
    
    var body: some View {
        VStack(spacing: 10) {
            Text(dateLabel)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 10)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(times, id: \.self) { time in
                    HStack {
                        if let dayEvents = events[startOfDay(for: dayDate)],
                           let event = dayEvents[time] {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.icon).font(.largeTitle)
                                Text(event.title).font(.subheadline)
                            }
                        } else {
                            Text(time).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 10)
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    var dateLabel: String {
        if calendar.isDateInToday(dayDate) {
            return "Today, " + dateFormatter.string(from: dayDate)
        } else if calendar.isDateInTomorrow(dayDate) {
            return "Tomorrow, " + dateFormatter.string(from: dayDate)
        } else {
            return dateFormatter.string(from: dayDate)
        }
    }
    
    private func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}

// MARK: - Month View
struct MonthView: View {
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()
    @Binding var events: [Date: [String: (icon: String, title: String)]]
    
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
            
            // Calendar grid
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
                        VStack {
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 30, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: cellHeight)
                                .background(
                                    isSelected ? Color.blue :
                                        (isToday ? Color.gray.opacity(0.2) : Color.clear)
                                )
                                .cornerRadius(12)
                        }
                        .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func changeMonth(by value: Int) {
        currentMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) ?? currentMonth
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Events Full Page
struct EventsFullPageView: View {
    @Binding var specialEvents: [(date: Date, icon: String, title: String)]
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d h:mm a"
        return df
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(specialEvents.indices, id: \.self) { idx in
                    HStack {
                        Text(specialEvents[idx].icon)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(specialEvents[idx].title)
                                .font(.headline)
                            Text(dateFormatter.string(from: specialEvents[idx].date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

// MARK: - Add Big Event View
struct AddBigEventView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var specialEvents: [(date: Date, icon: String, title: String)]
    
    @State private var title = ""
    @State private var startDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Special Event")
                .font(.largeTitle)
            
            TextField("Event Title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            DatePicker("Date", selection: $startDate)
                .padding()
            
            Button("Save") {
                if !title.isEmpty {
                    specialEvents.append((date: startDate, icon: "⭐️", title: title))
                    dismiss()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Page")
                .font(.largeTitle)
                .padding()
            Text("Coming soon...")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Icon Palette Click View (fixed to use Binding)
struct IconPaletteClickView: View {
    @Binding var selectedIcon: (icon: String, title: String)?
    
    private let options: [(String, String)] = [
        ("🎂", "Birthday"),
        ("🎉", "Party"),
        ("🎓", "Graduation"),
        ("🏖️", "Holiday"),
        ("🛫", "Trip"),
        ("❤️", "Anniversary")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(options, id: \.0) { option in
                    VStack {
                        Text(option.0)
                            .font(.largeTitle)
                            .onTapGesture {
                                selectedIcon = (option.0, option.1)
                            }
                        Text(option.1)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}
