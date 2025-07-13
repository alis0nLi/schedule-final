//
//  main.swift
//  schedule final
//
//  Created by Alison on 05/07/2025.
//

import SwiftUI

struct MainScheduleView: View {
    @State private var currentTime = Date()
    
    var body: some View {
        VStack(spacing: 10) {
            // Top bar with settings, time, and add buttons
            HStack {
                Button(action: {
                    // Settings action
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
                    // Add new task
                }) {
                    Image(systemName: "plus")
                        .padding(.horizontal, 50)
                        .padding(.vertical, 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            TabView{
                // stuff in tab 1
                VStack(alignment: .leading) {
                    HStack {
                        Text("8:45 am")
                    }
                    .padding(.top, 30)

                    Spacer()

                    HStack {
                        Text("9:00 pm")
                    }
                    .padding(.bottom, 30)
                }
                
                //tab 1 title
                    .tabItem{
                        Text("Day")
                        
                        
                    }
                
                Text("Week")
                    .tabItem{
                        Text("Week")
                    }
                
                Text("Month")
                    .tabItem{
                        Text("Month")
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

    // Function to format the current time
    func getTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}


#Preview {
    MainScheduleView()
    
}
