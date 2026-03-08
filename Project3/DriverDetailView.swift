//
//  DriverDetailView.swift
//  Project3
//
//  Created by Anushka R on 3/8/26.
//

import SwiftUI

//Setting up the view for when a specific driver is selected to replicate the P2 format
struct DriverDetailView: View {
    let driver: Driver

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Headshot of driver
                AsyncImage(url: URL(string: driver.headshot_url ?? "")) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(height: 300)
                .cornerRadius(15)
                
                // Listing out driver details from driver file variables and constants created earlier
                VStack(alignment: .leading, spacing: 10) {
                    Text(driver.full_name)
                        .font(.system(size: 34, weight: .bold))
                    
                    HStack {
                        Text("Number: \(driver.driver_number)")
                        Spacer()
                        Text(driver.name_acronym)
                            .font(.title2)
                            .fontWeight(.black)
                            .padding(8)
                            .background(Color(hex: driver.team_colour))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    // Adding and formatting team name
                    Text("Team")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(driver.team_name)
                        .font(.title3)
                }
                .padding()
            }
        }
        .navigationTitle(driver.name_acronym)
        .navigationBarTitleDisplayMode(.inline)
    }
}
