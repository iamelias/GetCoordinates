//
//  ViewController.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/19/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

var nearbyLocation: [MKAnnotation] = []
var savedCoordinates: [Coordinate] = []

class CoordinateVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var selectedAnnotation: MKAnnotation?
    var nearbyLocation: [MKPlacemark] = []
    var tab: ShareController {
        return tabBarController as! ShareController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
       
    }
    override func viewDidAppear(_ animated: Bool) {
        print("Made it")
        tab.passedString = "Elias"
    }
    func setUpDelegates() {
        mapView.delegate = self
        searchBar.delegate = self
    }
    
    func makeRegion(span: (lat: CLLocationDegrees, lon: CLLocationDegrees), coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion { //This is to zoom into user's current location.
        var region = MKCoordinateRegion()
        if region.span.latitudeDelta > 0.2 && region.span.longitudeDelta > 0.2 {
            region.center = mapView.userLocation.coordinate
        }
        else {
        region.center = coordinate
        }
        region.span.latitudeDelta = span.lat
        region.span.longitudeDelta = span.lon
        
        return region
    }
    
    func zoomRegion() {
        
    }
    
    func locationSearch() {
        let locationRequest = MKLocalSearch.Request()
        locationRequest.naturalLanguageQuery = searchBar.text
        
        let request = MKLocalSearch(request: locationRequest)
        request.start {response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            for item in response.mapItems {
                self.nearbyLocation.append(item.placemark)
                self.createAnnotation(item: item.placemark)
                self.saveCoordinate(item: item.placemark)
            }
        }
    }
    
    func createAnnotation(item: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.title = item.title
        annotation.coordinate = item.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func saveCoordinate(item: MKPlacemark) {
        var coordinate = Coordinate()
        coordinate.latitude = item.coordinate.latitude
        coordinate.longitude = item.coordinate.longitude
        coordinate.name = item.title ?? "No Name"
        coordinate.address = item.subtitle ?? "No Address"
        appendCoordinate(coordinate: coordinate)
        
    }
    
    func appendCoordinate(coordinate: Coordinate) {
        savedCoordinates.append(coordinate)
}
}

extension CoordinateVC: MKMapViewDelegate {

}

extension CoordinateVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        locationSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
        
}

extension CoordinateVC: CLLocationManagerDelegate {
    
}

