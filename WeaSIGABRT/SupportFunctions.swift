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
 https://developer.apple.com/documentation/foundation/date
 https://developer.apple.com/documentation/foundation/dates_and_times
 https://developer.apple.com/documentation/uikit/uicollectionview
 https://developer.apple.com/documentation/foundation/timezone
 https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/ProgrammaticallyCreatingConstraints.html
 https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithConstraintsinInterfaceBuidler.html
 https://github.com/Alamofire/Alamofire
 https://github.com/loopwxservices/WXKDarkSky
 https://github.com/drtimcooper/LatLongToTimezone
 https://github.com/romansorochak/Blur
 https://medium.com/@brianclouser/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
 https://stackoverflow.com/questions/52460351/scrollview-in-xib-custom-view-to-fit-with-multiple-width
 https://stackoverflow.com/questions/52462744/swift-2-for-loop-with-asynchronous-network-request-continue-looping-after-the-re
 https://stackoverflow.com/questions/36419107/passing-data-between-uipageviewcontroller-child-views-with-swift
 https://stackoverflow.com/questions/47494222/getting-the-city-country-list-in-ios-time-zone
 https://stackoverflow.com/questions/46869394/reverse-geocoding-in-swift-4
 */

import Foundation
import CoreData
import UIKit
import WXKDarkSky

class SupportFunctions {
    
    static var isMetric: Bool = true
    static var isCelsius: Bool = true
    static let request = WXKDarkSkyRequest(key: "5528c7901c45cba63baa891e648c897e") //    feb9c547f52812c44c06e0de9983ba24
    static let emojiIcons = [
        //Dictionary for icons
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
        //Get 15 days weather
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
    
    static func getCurrentWeather(latitude: Double, longitude: Double) -> WXKDarkSkyResponse {
        //Get Current Weather
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
        //Conver F to C
        let celsiusTemperature = (temperature-32)*(5/9)
        return celsiusTemperature
    }
    
    static func localTimeAtThatLocationCustom(time: Double, identifier: String, format: String) -> String {
        //Convert date to name of date in a week
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: identifier)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date).replacingOccurrences(of: "-", with: "/")
    }
}

