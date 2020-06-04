//
//  TableVC.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/26/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import UIKit

class TableVC: UIViewController {
    var newString = ""
    var tab: ShareController {
        return tabBarController as! ShareController
    }
    var locations: [CoreCoordinate] = []
    var context = DatabaseController.persistentStoreContainer().viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locations = tab.coreLocations
        tableView.reloadData()
    }
}

//MARK: TABLE VIEW
extension TableVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !locations.isEmpty else {
            return 0
        }
        
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = locations[indexPath.row].name
        cell?.detailTextLabel?.text = "lat: \(locations[indexPath.row].latitude!), lon: \(locations[indexPath.row].longitude!)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteCoreData(location: locations[indexPath.row])
        locations.remove(at: indexPath.row)
         tableView.deleteRows(at: [indexPath], with: .fade)
        tab.coreLocations = locations
    }
    
    //MARK: CORE DATA
    func deleteCoreData(location: CoreCoordinate) { //deleting location, during swipe
        context.delete(location)
        DatabaseController.saveContext()
    }
}
