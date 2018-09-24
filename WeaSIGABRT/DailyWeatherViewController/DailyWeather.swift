//
//  DailyWeather.swift
//  JSON
//
//  Created by Mai Pham Quang Huy on 9/9/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import Foundation

struct DailyWeather {
    let summary:String
    let icon:String
    let temperature:Double
    let time: Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        guard let time = json["time"] as? Double else {throw SerializationError.missing("time is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.time = time
    }
    
    static var forecastArray:[DailyWeather] = []
    static let basePath = "https://api.darksky.net/forecast/"
    
    static func forecast (withKey key:String,withLocation location:String, completion: @escaping ([DailyWeather]) -> ()) {
        let url = "\(basePath)\(key)/\(location)?exclude=currently,minutely,hourly,alerts,flags#&units=us"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? DailyWeather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
}

