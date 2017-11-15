//
//  Constants.swift
//  PixelCityApp
//
//  Created by Boiko Artem on 09.11.17.
//  Copyright © 2017 Boiko Artem. All rights reserved.
//

import Foundation


let API_KEY = "99d49611dae51e03d887cadab1bbf8bb"

//https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7da00cd376b6179a7dc2034603a7d457&lat=22.3&lon=122.8&radius=1&radius_units=km&format=json&nojsoncallback=1&api_sig=7a290acca2cc47ead12440bf038e8cea


func FLICKR_URL(apiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
   return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    
 
}

func FLICKR_POST_URL(farm: AnyObject, server: AnyObject, id: AnyObject, secret: AnyObject) -> String {
    return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_h_d.jpg"
}


func FLICKR_GET_USER_ID(userId: String) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=\(API_KEY)&user_id=\(userId)&format=json&nojsoncallback=1"
}

