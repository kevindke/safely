
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation

struct GeoKey {
  static let latitude = "latitude"
  static let longitude = "longitude"
  static let radius = "radius"
  static let identifier = "identifier"
  static let note = "note"
  static let eventType = "eventTYpe"
  static let type = "type"
}

enum EventType: String {
  case onEntry = "On Entry"
  case onExit = "On Exit"
}

class Geotification: NSObject, NSCoding, MKAnnotation {
  
  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var note: String
  var eventType: EventType
  var type: String
  
  var title: String? {
    if note.isEmpty {
      return "No Note"
    }
    print(String(describing: type))
    return String(describing: type)
  }
    
  let currentDate = Date()
    
  
  var subtitle: String? {
    let eventTypeString = eventType.rawValue
    return currentDate.localDateString() + "\n-" + note
  }
  
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType, type: String) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.note = note
    self.eventType = eventType
        self.type = type
  }
  
  // MARK: NSCoding
  required init?(coder decoder: NSCoder) {
    let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
    let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDouble(forKey: GeoKey.radius)
    identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
    note = decoder.decodeObject(forKey: GeoKey.note) as! String
    eventType = EventType(rawValue: decoder.decodeObject(forKey: GeoKey.eventType) as! String)!
    type = decoder.decodeObject(forKey: GeoKey.type) as! String
  }
  
  func encode(with coder: NSCoder) {
    coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
    coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
    coder.encode(radius, forKey: GeoKey.radius)
    coder.encode(identifier, forKey: GeoKey.identifier)
    coder.encode(note, forKey: GeoKey.note)
    coder.encode(eventType.rawValue, forKey: GeoKey.eventType)
    coder.encode(note, forKey: GeoKey.type)
  }
  
}

extension Date {
    @nonobjc static var localFormatter: DateFormatter = {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateStyle = .medium
        dateStringFormatter.timeStyle = .medium
        return dateStringFormatter
    }()
    
    func localDateString() -> String
    {
        return Date.localFormatter.string(from: self)
    }
}
