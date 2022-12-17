//
//  MapView.swift
//  CO2 Tracker
//
//  Created by Francesco Galdiolo on 15/12/22.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                    .padding(.horizontal, -25.0)
                    .ignoresSafeArea()
                LocationButton(.currentLocation){
                    viewModel.requestAllowWhenInUseLocaitonPermission()
                }
                .foregroundColor(.white)
                .cornerRadius(8)
                .labelStyle(.iconOnly)
                .symbolVariant(.fill)
                .padding(.trailing, 40.0)
            }
            .navigationBarTitle("Map")
        }
        .grayscale(/*@START_MENU_TOKEN@*/0.50/*@END_MENU_TOKEN@*/)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
