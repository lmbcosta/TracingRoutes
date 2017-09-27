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

class ViewController: UIViewController {
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinates: CLLocationCoordinate2D?
    // Steps tu upload the label
    var steps = [MKRouteStep]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // See extension: CLLocationManagerDelegate
        locationManager.delegate = self
        // See extension: UISearchBarDelegate
        searchBar.delegate = self
        mapView.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func getDirections(at destination: MKMapItem) {
        print("Im in!!!!!!!!!!!!")
        // Get source direction
        let sourcePlaceMark = MKPlacemark(coordinate: currentCoordinates!)
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        
        // Prepare directions with directon Request
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        directionsRequest.transportType = .automobile
        
        // Directions
        let directions = MKDirections(request: directionsRequest)
        directions.calculate(completionHandler: {response, _ in
            guard let response = response else {return}
            // Get the primary Route: General the best route because ir comes in first
            guard let firstRoute = response.routes.first else {return}
            // Draw the polyline
            self.mapView.add(firstRoute.polyline)
            // Get the steps
            let steps = firstRoute.steps
            self.steps = steps
            
            // Stop previous regions
            self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
            
            for i in 0 ..< steps.count {
                let step = steps[i]
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                
                // TODO: - Get steps for direction, get coordinate of steps and create a circular region
                //       - location manager will start monitorizing that regions
                // Any time we get directions we should stop monitorizing all the the previous rigions
            }
            
            
        })
    }
}

// MARK: - Extensions
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        // Get current coordinates
        guard let location = manager.location else {return}
        currentCoordinates = location.coordinate
        // Zoom into user's location
        mapView.userTrackingMode = .followWithHeading
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Close keyboard
        searchBar.endEditing(true)
        // Init a local search request
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        // location scale
        let span = MKCoordinateSpanMake(0.1, 0.1)
        localSearchRequest.region = MKCoordinateRegion(center: currentCoordinates!, span: span)
        
        // Create an actual localSearch
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start(completionHandler: {response, _ in
            guard let response = response else {return}
            guard let mapItem = response.mapItems.first else {return}
            
            // MapItem
            //print(response.mapItems)
            print(mapItem)
            self.getDirections(at: mapItem)
        })
    }
}

extension ViewController: MKMapViewDelegate {
    // Render polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 6
            return renderer
        }
        return MKOverlayRenderer()
    }
}




