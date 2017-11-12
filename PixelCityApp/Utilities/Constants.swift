//
//  Constants.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 09.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import Foundation


let apiKey = "99d49611dae51e03d887cadab1bbf8bb"

//https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7da00cd376b6179a7dc2034603a7d457&lat=22.3&lon=122.8&radius=1&radius_units=km&format=json&nojsoncallback=1&api_sig=7a290acca2cc47ead12440bf038e8cea


func flickrUrl(apiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
   return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    
 
}

func urlForPopVC(apiKey key: String, withAnnotation annotation: DroppablePin, numberPhotos number: Int,userId id: String ) -> String {
    return " https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7da00cd376b6179a7dc2034603a7d457&user_id=string&text=string&lat=22.3&lon=122.8&radius=1&radius_units=km&per_page=40&format=json&nojsoncallback=1&api_sig=0a2bb24cba6bdb67c9d6205c7fa8c610"
}

