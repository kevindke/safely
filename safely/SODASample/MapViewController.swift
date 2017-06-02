//
//  MapViewController.swift
//  Safely
//
//  Created by Justine Edrozo on 5/19/2017.
//  Copyright © 2017 Safely. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var selectedPin: MKPlacemark? = nil
    
    var locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var oldAnnotation = MKPointAnnotation()
    
    var geotifications: [Geotification] = []
    
    @IBOutlet weak var mapView: MKMapView!

    let client = SODAClient(domain: "data.seattle.gov", token: "CGxaHQoQlgQSev4zyUh5aR5J3")
    
    let cellId = "DetailCell"
    
    var dataQuery: [[String: Any]]! = []
    
    var data: [[String: Any]]! = []
    var dataHistorical: [[String: Any]]! = []
    
    // HUB
    let lat = 47.6553893
    let long = -122.3050844
    
    
//    let currentDate = Date()
    

    
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
        refresh(self)
        print(Date().localDateString())
        
        
        // Set the initial map region
        let coord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(coord, span)
        self.mapView.setRegion(region, animated: true)
        
        mapView.delegate = self as! MKMapViewDelegate
        mapView.showsCompass = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
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
        locationSearchTable.handleMapSearchDelegate = self
        
        loadAllGeotifications()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGeotification" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeotificationViewController
            vc.delegate = self as! AddGeotificationsViewControllerDelegate
        }
    }
  
    @IBAction func zoom(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        // 2
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your safely alert is saved but will only be activated once you grant Safely permission to access the device location.")
        }
        // 3
        let region = self.region(withGeotification: geotification)
        // 4
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }

    
    // directions for search
//    func getDirections(){
//        guard let selectedPin = selectedPin else { return }
//        let mapItem = MKMapItem(placemark: selectedPin)
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        mapItem.openInMaps(launchOptions: launchOptions)
//    }
    
    /// Asynchronous performs the data query then updates the UI
    func refresh (_ sender: Any) {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        let crimes = client.query(dataset: "5v3i-icz3")
        let crimes2 = client.query(dataset: "6yex-fe3g").limit(800)
        
        crimes.orderDescending("occurred_date_or_date_range_start").get { res in
            switch res {
            case .dataset (let dataQuery):
                // Update our data
                self.dataQuery = dataQuery
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alert = UIAlertView(title: "Error Refreshing", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            // Update the UI
            self.update(withData: self.dataQuery, animated: false)
        }
        
        crimes2.orderDescending("event_clearance_date").get { res in
            switch res {
            case .dataset (let dataQuery):
                // Update our data
                self.dataQuery = dataQuery
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alert = UIAlertView(title: "Error Refreshing", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            // Update the UI
            self.update2(withData: self.dataQuery, animated: false)
        }
        
        
        
        // updates firebase data
        
        
    }
    
    // HISTORICAL DATA
    func update(withData data: [[String: Any]]!, animated: Bool) {
        
        
        // Remember the data because we may not be able to display it yet
        self.data = data
        //print(data)
        
        if (!isViewLoaded) {
            return
        }
        
//        // Clear old annotations
//        if mapView.annotations.count > 0 {
//            let ex = mapView.annotations
//            mapView.removeAnnotations(ex)
//        }
        
        // Longitude and latitude accumulators so we can find the center
        var lata : CLLocationDegrees = 0.0
        var lona : CLLocationDegrees = 0.0
        
        // Create annotations for the data
        var anns : [MKAnnotation] = []
        for item in data {
            
            guard let lat = (item["latitude"] as? NSString)?.doubleValue,
                let lon = (item["longitude"] as? NSString)?.doubleValue else { continue }
            
            lata += lat
            lona += lon
            
            // create the annottation
            let a = MKPointAnnotation()
            guard let event = item["summarized_offense_description"] as? String else {continue}
            a.title = event.capitalized
            
            // date and time formatting
            var convertedDate: String = ""
            var convertedTime: String = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM d, yyyy"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH-mm-ss"
            let newTimeFormatter = DateFormatter()
            newTimeFormatter.dateFormat = "h:mm a"
            
            // grab the date and time
            guard let dateTime = item["occurred_date_or_date_range_start"] as? String else {continue}
            let dateComponents = dateTime.components(separatedBy: "T")
            
            let splitDate = dateComponents[0]
            let splitTime = dateComponents[1]
            
            if let date = dateFormatter.date(from: splitDate) {
                convertedDate = newDateFormatter.string(from: date)
            }
            if let time = timeFormatter.date(from: splitTime) {
                convertedTime = newTimeFormatter.string(from: time)
            }
            
            a.subtitle = convertedDate + " " + convertedTime + "*"
            
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
    
    
    // 911 CALL DATA
    func update2(withData data: [[String: Any]], animated: Bool) {
        
        
        // Remember the data because we may not be able to display it yet
        self.data = data
        
        if (!isViewLoaded) {
            return
        }
        
        //        // Clear old annotations
        //        if mapView.annotations.count > 0 {
        //            let ex = mapView.annotations
        //            mapView.removeAnnotations(ex)
        //        }
        
        // Longitude and latitude accumulators so we can find the center
        var lata : CLLocationDegrees = 0.0
        var lona : CLLocationDegrees = 0.0
        
        // Create annotations for the data
        var anns : [MKAnnotation] = []
        for item in data {
            
            guard let lat = (item["latitude"] as? NSString)?.doubleValue,
                let lon = (item["longitude"] as? NSString)?.doubleValue else { continue }
            
            lata += lat
            lona += lon
            
            // create the annotation
            let a = MKPointAnnotation()
            guard let event = item["event_clearance_group"] as? String else {continue}
            a.title = event.capitalized

            // date and time formatting
            var convertedDate: String = ""
            var convertedTime: String = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM d"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH-mm-ss"
            let newTimeFormatter = DateFormatter()
            newTimeFormatter.dateFormat = "h:mm a"
            
            // grab the date and time
            guard let dateTime = item["event_clearance_date"] as? String else {continue}
            let dateComponents = dateTime.components(separatedBy: "T")
            
            let splitDate = dateComponents[0]
            let splitTime = dateComponents[1]
            
            if let date = dateFormatter.date(from: splitDate) {
                convertedDate = newDateFormatter.string(from: date)
            }
            if let time = timeFormatter.date(from: splitTime) {
                convertedTime = newTimeFormatter.string(from: time)
            }
            
            // grab event clearance description
            guard let description = item["event_clearance_description"] as? String else {continue}
            
            a.subtitle = convertedDate + " " + convertedTime + "\n-" + description.capitalized
            
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
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        print("please")
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
//        if annotationView == nil {
            let actualSubtitle = String(describing: annotation.subtitle!!)
            let offenseType = String(describing: annotation.title!!)
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //print(offenseType)
            
            print(actualSubtitle)
            if (actualSubtitle.range(of: "*") != nil) { // HISTORICAL (date includes year)
                print("whytho")
                annotationView?.image = UIImage(named: "historical-data.png")
                annotationView?.canShowCallout = false
            } else { // 911 CALL
                annotationView?.canShowCallout = true
                let detailButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = detailButton
                print(offenseType)
                if (offenseType == "Disturbances" || offenseType == "Liquor Violations") {
                    print("caution)")
                    annotationView?.image = UIImage(named: "caution.png")
                } else if (offenseType == "Theft" || offenseType == "Robbery" || offenseType == "Burglary") {
                    annotationView?.image = UIImage(named: "burglar.png")
                } else if (offenseType == "Suspicious Circumstance" || offenseType == "Lewd Conduct") {
                    annotationView?.image = UIImage(named: "suspicious.png")
                } else if (offenseType == "Assaults" || offenseType == "Sex Offense (No Rape)" || offenseType == "Threats & Harassment") {
                    annotationView?.image = UIImage(named: "assault.png")
                } else if (offenseType == "Casualties" || offenseType == "Person Down/Injury") {
                    annotationView?.image = UIImage(named: "casualty.png")
                } else { // gun calls or weapon calls
                    annotationView?.image = UIImage(named: "gun.png")
                }
//            }
            
            if (String(describing: annotation.subtitle!!) == "Seattle WA") {
                annotationView?.image = UIImage(named: "facebook-placeholder-for-locate-places-on-maps.png")
                annotationView?.canShowCallout = true
                // Differentiate what images to use for crime categories
            }
//            
//        } else {
            annotationView?.annotation = annotation
        }
        print("thatpart")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let offenseType = String(describing: view.annotation!.title!!)
            let subtitle = String(describing:view.annotation!.subtitle!!)
//            print(subtitle)
            //            print(offenseType)
            
            let subtitleSplit = subtitle.components(separatedBy: "-")
            
            let date = subtitleSplit[0]
            let description = subtitleSplit[1]
            
            let alert = UIAlertController(title: "\(offenseType)", message: "\(date)" + "\n\(description)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //performSegue(withIdentifier: "moreDetail", sender: self)
        }
        
    }

    
    func loadAllGeotifications() {
        geotifications = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
            add(geotification: geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        print("look here")
        print(geotification.title)
        print("test")
        print(geotification.subtitle)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(geotification: Geotification) {
        if let indexInArray = geotifications.index(of: geotification) {
            geotifications.remove(at: indexInArray)
        }
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        title = "Safely Alerts (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        //mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.remove(circleOverlay)
                break
            }
        }
    }
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotation(oldAnnotation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        print(String(describing: annotation.subtitle!))
        mapView.addAnnotation(annotation)
        oldAnnotation = annotation
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }

}

extension MapViewController : CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

// MARK: AddGeotificationViewControllerDelegate
extension MapViewController: AddGeotificationsViewControllerDelegate {
    
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType, type: String) {
        controller.dismiss(animated: true, completion: nil)
        // 1
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType, type: type)
        add(geotification: geotification)
        // 2
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    
}

//extension MapViewController: MKMapViewDelegate {
//    
//    func mapView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        print("plz work")
//        let identifier = "myGeotification"
//        if annotation is Geotification {
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//                let removeButton = UIButton(type: .custom)
//                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
//                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
//                annotationView?.leftCalloutAccessoryView = removeButton
//            } else {
//                annotationView?.annotation = annotation
//            }
//            return annotationView
//        }
//        return nil
//    }
//}
