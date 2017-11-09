//
//  Constants.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 09.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import Foundation


let apiKey = "99d49611dae51e03d887cadab1bbf8bb"
let BASE_URL = ""


func flickrUrl(apiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"

 
}

