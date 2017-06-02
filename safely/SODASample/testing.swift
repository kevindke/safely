//
//  testing.swift
//  soda-swift
//
//  Created by Justine Edrozo on 5/15/17.
//  Copyright © 2017 Socrata. All rights reserved.
//

import UIKit

class QueryViewController: UITableViewController {
    
    // Register for access tokens here: http://dev.socrata.com/register
    
    let client = SODAClient(domain: "data.seattle.gov", token: "CGxaHQoQlgQSev4zyUh5aR5J3")
    
    let cellId = "DetailCell"
    let cellIdHistorical = "DetailCellHistorical"
    
    var data: [[String: Any]]! = []
    var dataHistorical: [[String: Any]]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a pull-to-refresh control
        refreshControl = UIRefreshControl ()
        refreshControl?.addTarget(self, action: #selector(QueryViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        // Auto-refresh
        refresh(self)
    }
    
    /// Asynchronous performs the data query then updates the UI
    func refresh (_ sender: Any) {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        //        let crimes = client.queryDataset("seattle-police-department-911-incident-response")
        //
        //        crimes.orderDescending("count (*)")
        
        let crimes = client.query(dataset: "6yex-fe3g").limit(100)
        let crimesHistorical = client.query(dataset: "7ais-f98f").limit(1000)
        
        crimesHistorical.orderDescending("occured_date_or_date_range_start").get { res in
            switch res {
            case .dataset (let dataHistorical):
                // update Data
                self.dataHistorical = dataHistorical
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alert = UIAlertView(title: "Error Refreshing", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            //update UI
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.updateHeatMap(animated: true)
        
        }
        
        crimes.orderDescending("event_clearance_date").get { res in
            switch res {
            case .dataset (let data):
                // Update our data
                self.data = data
            case .error (let err):
                let errorMessage = (err as NSError).userInfo.debugDescription
                let alert = UIAlertView(title: "Error Refreshing", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            // Update the UI
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.updateMap(animated: true)
        }
        
        // updates firebase data
        
        
    }
    
    /// Finds the map controller and updates its data
    fileprivate func updateMap(animated: Bool) {
        if let tabs = (self.parent?.parent as? UITabBarController) {
            if let mapNav = tabs.viewControllers![1] as? UINavigationController {
                if let map = mapNav.viewControllers[0] as? MapViewController {
                    map.update(withData: data, animated: animated)
                }
            }
        }
    }
    
    // update map w historical data
    fileprivate func updateHeatMap(animated: Bool) {
        if let tabs = (self.parent?.parent as? UITabBarController) {
            if let mapNav = tabs.viewControllers![1] as? UINavigationController {
                if let map = mapNav.viewControllers[0] as? MapViewController {
                    map.update(withData: dataHistorical, animated: animated)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show the map
        if let tabs = (self.parent?.parent as? UITabBarController) {
            tabs.selectedIndex = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: cellId) as UITableViewCell!
        
        let item = data[indexPath.row]
        
        let name = item["event_clearance_description"]! as! String
        c?.textLabel?.text = name
        
        let street = item["hundred_block_location"]! as! String
        let city = "Seattle"
        let state = "WA"
        c?.detailTextLabel?.text = "\(street), \(city), \(state)"
        
        return c!
    }
}
