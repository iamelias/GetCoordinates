//
//  Messages.swift
//  GetCoordinates
//
//  Created by Elias Hall on 6/8/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import Foundation

enum AuthMessages: String {
    case denied = "Please grant Get Coordinates permission to use your location in settings"
    case restricted = "User is restricted from using their location"
}
