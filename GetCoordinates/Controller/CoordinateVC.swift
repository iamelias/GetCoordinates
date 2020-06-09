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
    
    let locationManager = CLLocationManager()
    let context = DatabaseController.persistentStoreContainer().viewContext
    var nearbyLocation: [MKPlacemark] = []
    var tab: ShareController {
        return tabBarController as! ShareController
    }
    var searchNotification = Notification.Name(rawValue: locationNotificationKey)
    var locations: [CoreCoordinate] = [] //fetched locations
    var selectedLocationName: String? = nil //passed from tableVC when selecting cell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates() //making objects a delegate of CoordinateVC
        editView() //edits to the default view
        
        fetchCoreLocation() //fetching persisted Core Data
        tab.sharedContext = context
        tab.coreLocations = locations //for passing locations to TableVC
        createObservers() //creating observer needed for when selectecting location in TableVC
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //checkStatusLocationServices()
    }
    
    func setUpDelegates() {
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit called")
    }
    
    func createObservers() { //creating observer for when cell is tapped in TableVC
        NotificationCenter.default.addObserver(forName: searchNotification, object: nil, queue: nil, using: catchNotification)
    }
    
    func catchNotification(notification: Notification) {
        guard let coordinates = notification.userInfo!["location"] else { //storing location coordinates
            print("nil in catchLocation")
            return
        }
        
        if let name = notification.userInfo!["name"] { //storing location name associated with selected coordinates
            selectedLocationName = name as? String ?? ""
        }
        
        searchBar.text = coordinates as? String ?? "" //placing formatted coordinates into searchBar
        searchBarSearchButtonClicked(searchBar) //searching using coordinates
    }
    
    func createAlert(message: (title: String, alertMessage: String, alertActionMessage: String)) {
        
        let alert = UIAlertController(title: message.title, message: message.alertMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: message.alertActionMessage, style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
        
    }
    
    func createAnnotation(item: MKPlacemark) { //creates annotation for location display on mapview
        let stringCoordinates = convertDegreesToString(coordinates: (item.coordinate.latitude, item.coordinate.longitude))
        let annotation = MKPointAnnotation()
        if selectedLocationName == nil {
            annotation.title = item.name ?? "Nil"
        }
        else if selectedLocationName != nil {
            annotation.title = selectedLocationName
            selectedLocationName = nil
        }
        annotation.subtitle = "latitude: \(stringCoordinates.0), longitude: \(stringCoordinates.1)"
        annotation.coordinate = item.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func convertDegreesToString(coordinates: (lat: CLLocationDegrees, lon: CLLocationDegrees)) -> (String,String) {
        return("\(Float(coordinates.lat))","\(Float(coordinates.lon))") //converting Tuple of CLLocationDegrees to Tuple of String
    }
    
    //MARK: IBACTION METHODS
    @IBAction func centerButton(_ sender: Any) { //when the center button on the bottom right is tapped
        print("User Location Button Tapped")
        checkStatusLocationServices() //user checks location services permission
    }
    
    //MARK: CORE DATA METHODS
    
    func fetchCoreLocation() { //fetching saved locations from core data
        let locationRequest: NSFetchRequest<CoreCoordinate> = CoreCoordinate.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true) //fetching by creationDate from oldest(top) to newest(bottom)
        locationRequest.sortDescriptors = [sortDescriptor]
        
        do {
            locations = try context.fetch(locationRequest) //storing fetched results in locations array
        }
        catch {
            print("Unable to fetch")
        }
    }
    
    func saveCoreData(location: Coordinate) -> CoreCoordinate { //saving location to core data
        let coordinate = CoreCoordinate(context: context)
        coordinate.name = location.name
        coordinate.address = location.address
        //coordinate.creationDate = Date()
        coordinate.latitude = location.latitude
        coordinate.longitude = location.longitude
        
        DatabaseController.saveContext()
        
        return coordinate
    }
}

//MARK: MAP VIEW METHODS
extension CoordinateVC: MKMapViewDelegate {
    
    func makeRegion(span: (lat: CLLocationDegrees, lon: CLLocationDegrees), coordinate: CLLocationCoordinate2D? = nil) -> MKCoordinateRegion? { //This is creating a region using a center coordinate and a span
        var region = MKCoordinateRegion()
        
        if let coordinate = coordinate {
            region.center = coordinate
        }
        
        region.span.latitudeDelta = span.lat
        region.span.longitudeDelta = span.lon
        
        return region
    }
    
    func locationSearch(region: MKCoordinateRegion, userLocation: Bool? = nil) { //using MKLocalSearch, region, and naturalLanguageQuery to return location results
        let locationRequest = MKLocalSearch.Request()
        if userLocation == nil {
            locationRequest.naturalLanguageQuery = searchBar.text
        }
        if userLocation == true { //if using user's location, naturalLanguageQuery will search user's location instead... This is for when the centerButton is tapped
            locationRequest.naturalLanguageQuery = "\(locationManager.location!.description)"
        }
        locationRequest.region = region
        
        let request = MKLocalSearch(request: locationRequest)
        request.start {response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            for item in response.mapItems { // for each returned item
                self.nearbyLocation.append(item.placemark) //adding to nearbyLocations array
                self.createAnnotation(item: item.placemark) //creating an annotation to place on map
            }
            let mapRegion = self.makeRegion(span: (0.2, 0.2), coordinate: self.nearbyLocation[0].coordinate) //creating new region where center will be the first returned location
            guard let region = mapRegion else{return}
            self.mapView.setRegion(region, animated: true) //changing the region on the map
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) { //when annotation is selected
        view.endEditing(true) //dismiss keyboard
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //creating annotation visual
        
        let reuseIdentifier = "mapPin" // declaring reuse identifier
        
        var view: MKMarkerAnnotationView? = nil
        
        view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier) //using balloon visual
            
            locationBalloonView(view: view)
        }
        else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { //action when blue add button in callout box is tapped... saves it to core data
        
        var coordinate = Coordinate()
        let convertedTuple = convertDegreesToString(coordinates: (view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude))
        
        coordinate.name = (view.annotation?.title ?? "Nil") ?? "Nil"
        coordinate.latitude = convertedTuple.0
        coordinate.longitude = convertedTuple.1
        let coreCoordinate = saveCoreData(location: coordinate) //saving location to core data
        tab.coreLocations.append(coreCoordinate) //adds to tab shared coreLocations array
    }
}

//MARK: SEARCH BAR METHODS
extension CoordinateVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //when search is initiated
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        nearbyLocation.removeAll() //clear nearbyLocations array
        locationSearch(region: mapView.region.self) //do the search
        mapView.showsUserLocation = false
        view.endEditing(true) //dismiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
        searchBar.text = ""
    }
}

//MARK: CORE LOCATION METHODS
extension CoordinateVC: CLLocationManagerDelegate {
    
    func checkStatusLocationServices() { //deterimining if location services is enabled
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() { //determining user's location type authorization
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            print("Authorization denied")
            createAlert(message: ("Denied", AuthMessages.denied.rawValue, "Ok"))
            break
        case .authorizedWhenInUse:
            print("Authorized when in use")
            showSetUserRegion()
            break
        case .authorizedAlways:
            print("Always authorized")
            break
        case .notDetermined:
            print("Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("Authroization restricted")
            createAlert(message: ("Restricted", AuthMessages.restricted.rawValue, "Ok"))
            break
        @unknown default: break
        }
    }
    
    func showSetUserRegion() { //showing user's location on map, when centerButton is tapped
        nearbyLocation.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.showsUserLocation = false
        if let userLocation = locationManager.location?.coordinate {
            let region = makeRegion(span: (lat: 1, lon: 1), coordinate: userLocation)
            guard let checkedRegion = region else {
                print("user region is nil")
                return
            }
            locationSearch(region: checkedRegion, userLocation: true)
        }
        searchBar.text = ""
    }
}


