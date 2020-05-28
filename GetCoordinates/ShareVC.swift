//
//  ShareVC.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/26/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import UIKit

class ShareVC: UIViewController {
    
    var allCoordinates: [Coordinate] = []
    //var selectedCoordinate: Coordinate!
    var testString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
extension ShareVC: UITabBarControllerDelegate {
    
}
