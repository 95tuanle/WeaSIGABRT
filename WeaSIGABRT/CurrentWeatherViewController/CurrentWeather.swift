//
//  CurrentWeather.swift
//  Interface
//
//  Created by Mai Pham Quang Huy on 9/13/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import Foundation

class CurrentWeather {
    let time: Double?
    let temperature: Double?
    let summary: String?
    let icon: String?

    //Basic View
    let humidity: Int?
    let apparentTemperature: Double? //apparentTemperature
    
    //Details View
    let windSpeed: Double? //windSpeed
    let windGust: Double? //windGust
    
    //More Details View
    let rainChance: Double? //precipProbability
    let rainIntensity: Double? //precipIntensity
    let cloudCover: Double? //cloudCover
    let uvIndex: Int? //uvIndex
    let visibility: Double? //visibility
    let pressure: Double? //pressure
    
    struct WeatherKeys {
        static let time = "time"
        static let temperature = "temperature"
        static let humidity = "humidity"
        static let summary = "summary"
        static let icon = "icon"
        
        static let apparentTemperature = "apparentTemperature"
        static let windSpeed = "windSpeed"
        static let windGust = "windGust"
        static let rainChance = "precipProbability"
        static let rainIntensity = "precipIntensity"
        static let cloudCover = "cloudCover"
        static let uvIndex = "uvIndex"
        static let visibility = "visibility"
        static let pressure = "pressure"
    }
    
    init(weatherDictionary: [String:Any]) {
        time = weatherDictionary[WeatherKeys.time] as? Double
        temperature = weatherDictionary[WeatherKeys.temperature] as? Double
        if let humidityDouble = weatherDictionary[WeatherKeys.humidity] as? Double {
            humidity = Int(humidityDouble*100)
        } else {
            humidity = nil
        }
        summary = weatherDictionary[WeatherKeys.summary] as? String
        icon = weatherDictionary[WeatherKeys.icon] as? String
        apparentTemperature = weatherDictionary[WeatherKeys.apparentTemperature] as? Double
        windSpeed = weatherDictionary[WeatherKeys.windSpeed] as? Double
        windGust = weatherDictionary[WeatherKeys.windGust] as? Double
        rainChance = weatherDictionary[WeatherKeys.rainChance] as? Double
        rainIntensity = weatherDictionary[WeatherKeys.rainIntensity] as? Double
        cloudCover = weatherDictionary[WeatherKeys.cloudCover] as? Double
        uvIndex = weatherDictionary[WeatherKeys.uvIndex] as? Int
        visibility = weatherDictionary[WeatherKeys.visibility] as? Double
        pressure = weatherDictionary[WeatherKeys.pressure] as? Double
    }
}