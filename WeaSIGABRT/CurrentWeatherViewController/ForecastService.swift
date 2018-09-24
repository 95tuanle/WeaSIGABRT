//
//  ForecastService.swift
//  Interface
//
//  Created by Mai Pham Quang Huy on 9/13/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import Foundation
import Alamofire

class ForecastService {
    // Sample url: https://api.darksky.net/forecast/33c371344898311931ea3058dcc4730f/37.8267,-122.4233
    let forecastAPIKey: String
    let forecastBaseURL: URL?
    
    init(APIKey: String) {
        self.forecastAPIKey = APIKey
        forecastBaseURL = URL(string: "https://api.darksky.net/forecast/\(APIKey)")
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double,completion: @escaping (CurrentWeather?) -> Void) {
        if let forecastURL = URL(string: "\(forecastBaseURL!)/\(latitude),\(longitude)?exclude=minutely,hourly,daily,alerts,flags#&units=us") {
            
            Alamofire.request(forecastURL).responseJSON(completionHandler: { (response) in
                if let jsonDictionary = response.result.value as? [String : Any] {
                    if let currentWeatherDictionary = jsonDictionary["currently"] as? [String : Any] {
                        let currentWeather = CurrentWeather(weatherDictionary: currentWeatherDictionary)
                        completion(currentWeather)
                    } else {
                        completion(nil)
                    }
                }
            })
        }
    }
}
