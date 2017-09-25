//
//  ViewController.swift
//  TracingRoutes
//
//  Created by Luis  Costa on 25/09/17.
//  Copyright © 2017 Luis  Costa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        searchBar.delegate = self
    }
    
    func getDirections(at destination: MKMapItem) {
        // Get source direction
        let sourcePlaceMark = MKPlacemark(coordinate: currentCoordinates)
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        
        // Prepare directions with directon Request
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        directionsRequest.transportType = .automobile
        
        // Directions
        let directions = MKDirections(request: directionsRequest)
        // TODO: - Calulate directions
        
    }
}

// Extensions
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = manager.location else {return}
        currentCoordinates = location.coordinate
        // Zoom into user's location
        mapView.userTrackingMode = .followWithHeading
    }
}

// MARK: - Search Bar Extensions
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Close keyboard
        searchBar.endEditing(true)
        // Init a local search request
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let span = MKCoordinateSpanMake(0.1, 0.1)
        localSearchRequest.region = MKCoordinateRegion(center: currentCoordinates, span: span)
        
        // Create an actual localSearch
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start(completionHandler: {response, error in
            guard let response = response else {
                print(error.debugDescription)
                return
            }
            
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            guard let mapItem = response.mapItems.first else {
                return
            }
            
            // MapItem
            print(response.mapItems)
            self.getDirections(at: mapItem)
        })
    }
}




