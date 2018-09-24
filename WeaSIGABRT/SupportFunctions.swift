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

class SupportFunctions {
    
    static var isMetric: Bool = true
    static var isCelsius: Bool = true
    
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

