//
//  ShareController.swift
//  GetCoordinates
//
//  Created by Elias Hall on 5/27/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

let locationNotificationKey = "selected.location.key"

class ShareController: UITabBarController {
    var sharedContext: NSManagedObjectContext?
    var coreLocations: [CoreCoordinate] = []
}
