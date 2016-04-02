//
//  CityModel.swift
//  WeatherPovio
//
//  Created by Ljupco Gorgiev on 4/2/16.
//  Copyright © 2016 Developers. All rights reserved.
//

import Foundation

class CityModel {
    var cityId : Int
    var cityName : String
    var cityTemperature : Int
    var cityHumidity : Int
    var cityDescription : String
    
    init(dictionary:[String : String]) {
        cityId = Int(dictionary[kCityId]!)!
        self.cityName = dictionary[kCityName]!
        self.cityTemperature = Int(dictionary[kCityTemperature]!)!
        self.cityHumidity = Int(dictionary[kCityHumidity]!)!
        self.cityDescription = dictionary[kCityDescription]!
    }
    
    
    func updateWithDictionary(dict:Dictionary<String,AnyObject>) {
        
    }
    
    func returnCityInfoDictionary() -> [String : String] {
        let cityDictionary : [String: String] = [kCityId : String(cityId), kCityName : cityName, kCityTemperature : String(cityTemperature), kCityHumidity : String(cityHumidity), kCityDescription : cityDescription]
        return cityDictionary
    }
}
