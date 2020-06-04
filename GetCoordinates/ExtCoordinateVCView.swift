//
//  ExtCoordinateVCView.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/20/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

extension CoordinateVC {
    
    func editView() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func createLocationButton() {
        var locationButton = UIButton(type: .custom)
        locationButton.backgroundColor = .white
        
    }
    
}
