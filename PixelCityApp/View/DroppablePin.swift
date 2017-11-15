//
//  DroppablePin.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 06.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}
