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
                        .font(.title)
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    
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
                    .padding(.horizontal, 60)
                    .padding(.vertical, 30)
                    .background(selectedView == title ? Color.blue.opacity(0.5) : Color.blue.opacity(0.2))
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
            Spacer()
            Text("9:00 pm")
        }
        .padding()
    }
}

struct WeekView: View {
    var body: some View {
        Text("Week View")
            .font(.largeTitle)
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



#Preview {
    MainScheduleView()
    
}
