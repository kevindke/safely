//
//  MapViewController.swift
//  SODASample
//
//  Created by Frank A. Krueger on 8/10/14.
//  Copyright (c) 2014 Socrata, Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    
    
    @IBOutlet weak var mapView: MKMapView!

    
    var data: [[String: Any]]! = []
    var lat = 47.6591
    var long = -122.3086
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let coordinations = CLLocationCoordinate2D(latitude: lat,longitude: long)
        let span = MKCoordinateSpanMake(0.2,0.2)
        let region = MKCoordinateRegion(center: coordinations, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegionMake(coord, span)
        self.mapView.setRegion(region, animated:true)
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        mapView.showsUserLocation = true
//        mapView.zoomToUserLocation()
//        print(lat)
        
        
        update(withData: data, animated: false)
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        locationSearchTable.mapView = mapView
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
    }
    
    
    @IBAction func zoomToCurrentLocation(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    
    func update(withData data: [[String: Any]]!, animated: Bool) {
        
        
        // Remember the data because we may not be able to display it yet
        self.data = data
        
        if (!isViewLoaded) {
            return
        }
        
        // Clear old annotations
        if mapView.annotations.count > 0 {
            let ex = mapView.annotations
            mapView.removeAnnotations(ex)
        }
        
        // Longitude and latitude accumulators so we can find the center
        var lata : CLLocationDegrees = 0.0
        var lona : CLLocationDegrees = 0.0
        
        // Create annotations for the data
        var anns : [MKAnnotation] = []
        for item in data {
            
            // item["incident_location"] != nil
            guard let lat = (item["latitude"] as? NSString)?.doubleValue,
                let lon = (item["longitude"] as? NSString)?.doubleValue else { continue }
            
            lata += lat
            lona += lon
            let a = MKPointAnnotation()
            a.title = item["event_clearance_description"] as? String ?? ""
            a.coordinate = CLLocationCoordinate2D (latitude: lat, longitude: lon)
            anns.append(a)
        }
        
        // Set the annotations and center the map
        if (anns.count > 0) {
            mapView.addAnnotations(anns)
//            let w = 1.0 / Double(anns.count)
//            let r = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: lata*w, longitude: lona*w), 300, 300)
//            mapView.setRegion(r, animated: animated)
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            print("location:: (location)")
//            
//        }
//    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
}

