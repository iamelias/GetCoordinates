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
import CoreData

class CoordinateVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let context = DatabaseController.persistentStoreContainer().viewContext
    var selectedAnnotation: MKAnnotation?
    var nearbyLocation: [MKPlacemark] = []
    var savedCoordinates: [Coordinate] = []
    var newRegion: MKCoordinateRegion?
    var tab: ShareController {
        return tabBarController as! ShareController
    }
    var passingCoordinates: [Coordinate] = []
    //var annotationsArray: [MKAnnotations] = []
    
    var locations: [CoreCoordinate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
        editView()
        
        fetchCoreLocation()
        tab.sharedContext = context
        tab.coreLocations = locations
    }
    
    func setUpDelegates() {
        mapView.delegate = self
        searchBar.delegate = self
    }
    
    func makeRegion(span: (lat: CLLocationDegrees, lon: CLLocationDegrees), coordinate: CLLocationCoordinate2D? = nil) -> MKCoordinateRegion? { //This is to zoom into user's current location.
        var region = MKCoordinateRegion()
        
        if let coordinate = coordinate {
            region.center = coordinate
        }

        region.span.latitudeDelta = span.lat
        region.span.longitudeDelta = span.lon
        
        return region
    }
    
    func locationSearch() {
        let locationRequest = MKLocalSearch.Request()
        locationRequest.naturalLanguageQuery = searchBar.text
        locationRequest.region = mapView.region.self

            if let checkRegion = makeRegion(span: (0.2, 0.2), coordinate: locationRequest.region.center) {
            locationRequest.region = checkRegion
        }
        
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
            let mapRegion = self.makeRegion(span: (0.2, 0.2), coordinate: self.nearbyLocation[0].coordinate)
            guard let region = mapRegion else{return}
            self.mapView.setRegion(region, animated: true)
        }
    }
    @IBAction func centerButton(_ sender: Any) {
        print("Center Button Tapped")
    }
    
    func createAnnotation(item: MKPlacemark) {
        let stringCoordinates = convertDegreesToString(coordinates: (item.coordinate.latitude, item.coordinate.longitude))
        let annotation = MKPointAnnotation()
        annotation.title = item.name ?? "Nil"
        annotation.subtitle = "latitude: \(stringCoordinates.0), longitude: \(stringCoordinates.1)"
        annotation.coordinate = item.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func convertDegreesToString(coordinates: (lat: CLLocationDegrees, lon: CLLocationDegrees)) -> (String,String) {
        return("\(Float(coordinates.lat))","\(Float(coordinates.lon))") //converting Tuple of CLLocationDegrees to Tuple of String
    }
    
    func saveCoordinate(item: MKPlacemark) {
        var coordinate = Coordinate()
        coordinate.latitude = "\(item.coordinate.latitude)"
        coordinate.longitude = "\(item.coordinate.longitude)"
        coordinate.name = item.name ?? "No Name"
        coordinate.address = item.title ?? "No Address"
        appendCoordinate(coordinate: coordinate)
    }
    
    func appendCoordinate(coordinate: Coordinate) {
        savedCoordinates.append(coordinate)
}
    
    //MARK: CORE DATA

    func fetchCoreLocation() {
        let locationRequest: NSFetchRequest<CoreCoordinate> = CoreCoordinate.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        locationRequest.sortDescriptors = [sortDescriptor]
        
        do {
            locations = try context.fetch(locationRequest)
        }
        catch {
            print("Unable to fetch")
        }
    }
    
    func saveCoreData(location: Coordinate) -> CoreCoordinate {
        let coordinate = CoreCoordinate(context: context)
        coordinate.name = location.name
        coordinate.address = location.address
        coordinate.creationDate = Date()
        coordinate.latitude = location.latitude
        coordinate.longitude = location.longitude
        
        DatabaseController.saveContext()
        
        return coordinate
    }
    
}

extension CoordinateVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.endEditing(true)
    }
    
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "mapPin" // declaring reuse identifier
        var view: MKMarkerAnnotationView? = nil
        
        view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view?.canShowCallout = true
            view?.markerTintColor = .blue
            view?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        }
        else {
            view?.annotation = annotation
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        var coordinate = Coordinate()
        let convertedTuple = convertDegreesToString(coordinates: (view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude))
                
        coordinate.name = (view.annotation?.title ?? "Nil") ?? "Nil"
        coordinate.latitude = convertedTuple.0
        coordinate.longitude = convertedTuple.1
        passingCoordinates.append(coordinate)
        let coreCoordinate = saveCoreData(location: coordinate)
        tab.coreLocations.append(coreCoordinate)
    }
}

extension CoordinateVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mapView.removeAnnotations(mapView.annotations)
        nearbyLocation.removeAll()
        locationSearch()
        view.endEditing(true)
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
