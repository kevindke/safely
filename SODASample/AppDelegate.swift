//
//  AppDelegate.swift
//  SODASample
//
//  Created by Frank A. Krueger on 8/10/14.
//  Copyright (c) 2014 Socrata, Inc. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    let locationManager = CLLocationManager()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        return true
    }
    
//    func handleEvent(forRegion region: CLRegion!) {
//        // Show an alert if application is active
//        if UIApplication.shared.applicationState == .active {
//            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
//        } else {
//            // Otherwise present a local notification
//            let notification = UILocalNotification()
//            notification.alertBody = note(fromRegionIdentifier: region.identifier)
//            notification.soundName = "Default"
//            UIApplication.shared.presentLocalNotificationNow(notification)
//        }
//    }
    
//    func note(fromRegionIdentifier identifier: String) -> String? {
//        //let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
//        //let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
//        //let index = geotifications?.index { $0?.identifier == identifier }
//        return index != nil ? geotifications?[index!]?.note : nil
//    }
    
}


extension AppDelegate: CLLocationManagerDelegate {
    
}

