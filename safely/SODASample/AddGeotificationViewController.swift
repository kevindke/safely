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

protocol AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
                                      radius: Double, identifier: String, note: String, eventType: EventType, type: String)
}

class AddGeotificationViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!
  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
//    @IBOutlet weak var drop: DropMenuButton!

    
    var lat = 47.6591
    var long = -122.3086
    
    var pickerData:[String] = [String]()
    


  var delegate: AddGeotificationsViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.isEnabled = false
    //navigationController?.navigationBar.barTintColor = UIColor.black
    
    picker.isHidden = true;
    pickerTextField.text = "";
    
    self.pickerTextField.delegate = self
    self.picker.delegate = self
    self.picker.dataSource = self
    
        pickerData = ["Disturbances", "Liquor Violations", "Theft", "Robbery", "Burglary", "Suspicious Circumstance", "Assaults", "Lewd Conduct", "Sex Offense (No Rape)", "Threats & Harassment", "Casualties", "Person Down/Injury"]
    
    let coord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
    let span = MKCoordinateSpanMake(0.02, 0.02)
    let region = MKCoordinateRegionMake(coord, span)
    self.mapView.setRegion(region, animated: true)
  }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerTextField.isHidden = false;
        self.picker.isHidden = true;
        self.pickerTextField.text = pickerData[row];
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.pickerTextField.isHidden = true
        self.picker.isHidden = false;
        return false
    }

  @IBAction func textFieldEditingChanged(sender: UITextField) {
    addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
  }

  @IBAction func onCancel(sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction private func onAdd(sender: AnyObject) {
    let coordinate = mapView.centerCoordinate
    let radius = Double(radiusTextField.text!) ?? 0
    let identifier = NSUUID().uuidString
    let note = noteTextField.text
    let type = String(describing: pickerTextField.text!)
    let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
    delegate?.addGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType, type: type)
  }

  @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
}
