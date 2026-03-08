//
//  ContentView.swift
//  Project3
//
//  Created by Anushka R on 3/7/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = F1ViewModel()
    @State private var isAddSheetPresented = false

    
    var body: some View {
            NavigationView {
                Group {
                    if viewModel.isLoading && viewModel.drivers.isEmpty {
                        ProgressView("Fuelling up...")
                    } else {
                        driverList
                    }
                }
                .navigationTitle("F1 Drivers 2026")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isAddSheetPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(viewModel.allDrivers.isEmpty)
                    }
                }
                .sheet(isPresented: $isAddSheetPresented) {
                    addDriverSheet
                }
                .task {
                    await viewModel.loadDrivers()
                }
            }
        }

        // Extracted list for cleaner code
        var driverList: some View {
            List {
                ForEach(viewModel.drivers) { driver in
                    // This creates the clickable 'chevron' row
                    NavigationLink(destination: DriverDetailView(driver: driver)) {
                        DriverRow(driver: driver)
                            .contentShape(Rectangle())
                    }
                }
                .onDelete(perform: viewModel.removeDrivers)
            }
        }

        var addDriverSheet: some View {
            NavigationView {
                List(viewModel.allDrivers) { driver in
                    Button {
                        viewModel.addDriver(driver)
                        isAddSheetPresented = false
                    } label: {
                        HStack {
                            DriverRow(driver: driver)
                            Spacer()
                            if viewModel.isDriverSelected(driver) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(viewModel.isDriverSelected(driver))
                }
                .navigationTitle("Add Driver")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isAddSheetPresented = false
                        }
                    }
                }
            }
        }
    }

    // Adding hex code to translate API info to be compatible with Swift
    extension Color {
        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let r, g, b: UInt64
            switch hex.count {
            case 6: // RGB (24-bit)
                (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
            default:
                (r, g, b) = (1, 1, 1)
            }
            self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
        }
    }
    
    // A reusable sub-view for the list row
    struct DriverRow: View {
        let driver: Driver
        
        var body: some View {
            HStack(spacing: 15) {
                AsyncImage(url: URL(string: driver.headshot_url ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(hex: driver.team_colour), lineWidth: 2))

                VStack(alignment: .leading) {
                    Text(driver.full_name)
                        .font(.headline)
                    Text(driver.team_name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }


#Preview {
    ContentView()
}
