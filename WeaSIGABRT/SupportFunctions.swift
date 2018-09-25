/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Project
 Author:
 -   Ngo Vu Nguyen (s3480522)
 -   Le Pham Ngoc Hoai (s3636085)
 -   Le Nguyen Anh Tuan (s3574983)
 -   Mai Pham Quang Huy (s3618861)
 ID: s3480522,s3636085, s3574983, s3618861
 Created date: 18/9/2018
 Acknowledgment:
 */

import Foundation
import CoreData
import UIKit
import WXKDarkSky

class SupportFunctions {
    
    static var isMetric: Bool = true
    static var isCelsius: Bool = true
    static let request = WXKDarkSkyRequest(key: "feb9c547f52812c44c06e0de9983ba24")
//    static let request = WXKDarkSkyRequest(key: "9b43add4303def8ddb395cc7fec44be7")

    static let apiKey: String = "9b43add4303def8ddb395cc7fec44be7"
    static let emojiIcons = [
        "clear-day" : "☀️",
        "clear-night" : "🌙",
        "rain" : "☔️",
        "snow" : "❄️",
        "sleet" : "🌨",
        "wind" : "🌬",
        "fog" : "🌫",
        "cloudy" : "☁️",
        "partly-cloudy-day" : "🌤",
        "partly-cloudy-night" : "🌥"
    ]
    
    static func forecastAndTimeMachineQuery(city:City) -> [WXKDarkSkyDataPoint] {
        let point = WXKDarkSkyRequest.Point(latitude: city.lat, longitude: city.long)
        var responses:[WXKDarkSkyDataPoint] = []
        var dates:[Date] = []
        let today = Date()
        for i in (1...7).reversed() {
            let yesterday = Calendar.current.date(byAdding: .day, value: -i, to: today)
            dates.append(yesterday!)
        }
        let options = WXKDarkSkyRequest.Options(exclude: [.flags, .alerts, .hourly, .currently, .minutely])

        for date in dates {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global().async {
                request.loadData(point: point, time: date, options: options) { (data, error) in
                    if let error = error {
                        print(error)
                    } else if let data = data {
                         responses = responses + data.daily!.data
                        group.leave()
                    }
                }
            }
            group.wait()
        }
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            request.loadData(point: point, options: options) { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    responses = responses + data.daily!.data
                    group.leave()
                }
            }
        }
        group.wait()
        return responses
    }
    
    static func getCurrentTemperature(latitude: Double, longitude: Double) -> Double {
        let group = DispatchGroup()
        group.enter()
        let point = WXKDarkSkyRequest.Point(latitude: latitude, longitude: longitude)
        var temp:Double?
        DispatchQueue.global().async {
            request.loadData(point: point) { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    temp = (data.currently!.temperature)!
                    group.leave()
                }
            }
        }
        
        group.wait()
        return temp!
    }
    
    static func getCurrentWeather(latitude: Double, longitude: Double) -> WXKDarkSkyResponse {
        let group = DispatchGroup()
        group.enter()
        let point = WXKDarkSkyRequest.Point(latitude: latitude, longitude: longitude)
        var temp:WXKDarkSkyResponse?
        DispatchQueue.global().async {
            request.loadData(point: point) { (data, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    temp = data
                    group.leave()
                }
            }
        }
        
        group.wait()
        return temp!
    }
    
    static func createContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    static func createNewCity() -> City {
        return City(context: createContext())
    }
    
    static func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    static func deleteCity(city:City) {
        createContext().delete(city)
        saveContext()
    }
    
    static func fahrenheitToCelsius(temperature: Double) -> Double {
        let celsiusTemperature = (temperature-32)*(5/9)
        return celsiusTemperature
    }
    
    static func localTimeAtThatLocationCustom(time: Double, identifier: String, format: String) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: identifier)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date).replacingOccurrences(of: "-", with: "/")
    }
}

