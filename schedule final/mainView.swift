//
//  main.swift
//  schedule final
//
//  Created by Alison on 05/07/2025.
//

import SwiftUI

struct MainScheduleView: View {
    @State private var currentTime = Date()
    @State private var selectedView: String = "Day"
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 10) {
                //top bar
                HStack {
                    Button(action: {
                        //settings action
                    }) {
                        Image(systemName: "gearshape.fill")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Text(getTimeString(from: currentTime))
                        .font(.system(size: 45))
                        .fontWeight(.bold)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 5)
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        //add task
                    }) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                
    //buttons
                HStack(spacing: 20) {
                    viewSwitchButton("Day")
                    viewSwitchButton("Week")
                    viewSwitchButton("Month")
                    viewSwitchButton("Year")
                }

                Divider()

                //hanges depending on the selected view
                Group {
                    if selectedView == "Day" {
                        DayView()
                    } else if selectedView == "Week" {
                        WeekView()
                    } else if selectedView == "Month" {
                        MonthView()
                    } else if selectedView == "Year" {
                        YearView()
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 24)
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    self.currentTime = Date()
                }
            }
        }
    }
    
    // button function
        private func viewSwitchButton(_ title: String) -> some View {
            Button(action: {
                selectedView = title
            }) {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(selectedView == title ? Color.white : Color.black)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 30)
                    .background(selectedView == title ? Color.blue : Color.blue.opacity(0.2))
                    .cornerRadius(12)
            }
        }

    //format the current time
    func getTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}


//bottom views
struct DayView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("8:45 am")
                .font(.system(size: 36, weight: .bold, design: .default))
            Spacer()
            Text("9:00 pm")
                .font(.system(size: 36, weight: .bold, design: .default))
        }
        .padding()
    }
}

struct WeekView: View {
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 20) {
                ForEach(days, id: \.self) { day in
                    DayScheduleView(day: day)
                        .frame(width: 400) // Width of each day's column
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
                .font(.system(size:40, weight: .bold))
                .padding(.top, 10)

            Divider()

            // Example timeline events
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

    // Sample events (just for demo)
    func sampleEvents(for day: String) -> [String] {
        return [
            "will co-ordinate with user's entered events"
        ]
    }
}


struct MonthView: View {
    var body: some View {
        Text("Month View")
            .font(.largeTitle)
    }
}

struct YearView: View {
    var body: some View {
        Text("Year View")
            .font(.largeTitle)
    }
}



struct MainScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        MainScheduleView()
    }
}

