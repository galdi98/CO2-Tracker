//  LocationViewModel.swift
//  CO2 Tracker
//
//  Created by Francesco Galdiolo on 15/12/22.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

// Class used for managing all the location data
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var locations: [CLLocation] = []
    @Published var polylinePoints: [CLLocationCoordinate2D] = []
    @Published var lastSeenLocation: CLLocation?
    @Published var isRecording: Bool = false
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360))
    var locality: String = ""

    let dataController = DataController()
    var locationManager = CLLocationManager()
    
    @Published var polyline: MKPolyline?
    @Published var totalDistance: CLLocationDistance = 0.0
    var startTime: Date?
    var endTime: Date?
    var averageSpeed: CLLocationSpeed = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func startDriveTracking() {
        locations.removeAll()
        totalDistance = 0.0
        averageSpeed = 0.0
        startTime = Date()
        locationManager.startUpdatingLocation()
    }
    
    func stopDriveTracking(completion: @escaping () -> Void) {
        let context = dataController.container.viewContext
        locationManager.stopUpdatingLocation()
        endTime = Date()
        dataController.addDrive(date: endTime ?? Date(), distanceTraveled: totalDistance, averageSpeed: averageSpeed, coordinates: self.locations, context: context) { drive in
            DispatchQueue.main.async {
                if let drive = drive {
                    let coordinates = zip(drive.latitudeArray ?? [], drive.longitudeArray ?? []).map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }
                    self.polylinePoints = coordinates
                    self.objectWillChange.send() // Notify the UI that the data has changed
                    completion() // Call the completion handler
                } else {
                    print("Failed to save the drive")
                }
            }
        }
    }


    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Ensure that the location has an acceptable level of accuracy
        guard location.horizontalAccuracy <= 50 else { return }

        lastSeenLocation = location

        if self.locations.isEmpty {
            self.locations.append(location)
            return
        }

        // Set a minimum distance threshold for updating the distance and other parameters
        let distanceThreshold: CLLocationDistance = 10
        let distance = location.distance(from: self.locations.last!)

        if distance >= distanceThreshold {
            let previousLocation = self.locations.last!
            let timeElapsed = location.timestamp.timeIntervalSince(previousLocation.timestamp)

            // Check if timeElapsed is not zero to prevent division by zero
            if timeElapsed > 0 {
                let speed = (distance / 1000) / (timeElapsed / 3600) // Convert speed to km/h
                averageSpeed = (averageSpeed * Double(self.locations.count) + speed) / Double(max(self.locations.count + 1, 1)) // Prevent division by zero
            }
            
            totalDistance += distance / 1000
            self.polylinePoints.append(location.coordinate)
            self.locations.append(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func createPolyline() -> MKPolyline? {
        guard locations.count >= 2 else {
            return nil
        }
        let coordinates = locations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        return polyline
    }
    
    func getLastDrive(context: NSManagedObjectContext) -> Drive? {
        let drives: [Drive] = dataController.fetchDrives(context: context, sortBy: .date, sortAscending: false)
        if let lastDrive = drives.first {
            return lastDrive
        } else {
            return nil
        }
    }
    
    
    func fetchLocality(for coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error)")
                completion("Unknown Location")
                return
            }
            
            if let placemark = placemarks?.first {
                let locality = placemark.locality ?? "Unknown Location"
                print("Fetched locality: \(locality)")
                completion(locality)
            } else {
                print("No placemarks found")
                completion("Unknown Location")
            }
        }
    }
}
