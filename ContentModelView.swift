//
//  ContentModelView.swift
//  CO2 Tracker
//
//  Created by Francesco Galdiolo on 15/12/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocationUI

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.47, longitude: 10.85 ), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAllowWhenInUseLocaitonPermission(){
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            return
        }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
