//
//  ContentView.swift
//  CO2 Tracker
//
//  Created by Francesco Galdiolo on 15/12/22.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct ContentView: View {
    
    @State private var colors: [Color] = []
    
    var body: some View {
        TabView() {
            HomeView()
                .tabItem {
                    Label("Home",systemImage: "square")
                }
            SettingsView()
                .tabItem {
                    Label("Settings",systemImage: "triangle")
                }
        }
        .ignoresSafeArea()
        .navigationTitle("CO2 Tracker")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

