//
//  Artwork.swift
//  soda-swift
//
//  Created by Kevin Ke on 5/29/17.
//  Copyright © 2017 Socrata. All rights reserved.
//
//
//import Foundation
//import MapKit
//
//class Crime: NSObject, MKAnnotation {
//    let offenseType: String?
//    //let locationName: String
//    let dateRecorded: String
//    let coordinate: CLLocationCoordinate2D
//    
//    init(offenseType: String, coordinate: CLLocationCoordinate2D, dateRecorded: String) {
//        self.offenseType = offenseType
//        //self.locationName = locationName
//        self.coordinate = coordinate
//        self.dateRecorded = dateRecorded
//        
//        super.init()
//    }
//    
//    class func fromJson(_ json: [JSONValue]) -> Crime? {
//        //1
//        
//        let dateRecorded = json[17]
//        let offenseType = json[18].string!
//        let latitude = (json[12].string! as NSString).doubleValue
//        let longitude = (json[22].string! as NSString).doubleValue
//        
//        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        return Crime(offenseType: offenseType, coordinate: coordinate, dateRecorded: "test")
//    }
//    
//    var location: String {
//        return offenseType!
//    }
//}
