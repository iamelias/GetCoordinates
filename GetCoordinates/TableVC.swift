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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let retrievedString = tab.passedString
        print(retrievedString)
    }
}
