//
//  ExtCoordinateVCView.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/20/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension CoordinateVC {
    
    func editView() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func locationBalloonView(view: MKMarkerAnnotationView?) {
        view?.canShowCallout = true //shows white box when tapped
        view?.markerTintColor = .red //balloon color is tred
        view?.rightCalloutAccessoryView = UIButton(type: .contactAdd) //white box will have a add button
    }
}
