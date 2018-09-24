//
//  DisplayTableViewController.swift
//  Interface
//
//  Created by Mai Pham Quang Huy on 9/13/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit
import CoreLocation
import LatLongToTimezone

class DisplayTableViewController: UITableViewController, UISearchBarDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item] = []
    var selectedIndex: Int!
    
    var filteredData: [Item] = []
    
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()
    
    @IBOutlet weak var metricSwitchLabel: UIBarButtonItem!
    @IBAction func metricSwitch(_ sender: Any) {
        switch SupportFunctions.isMetric {
        case true:
            metricSwitchLabel.title = "Imperial"
            SupportFunctions.isMetric = false
            print("Switching to Imperial System")
        case false:
            metricSwitchLabel.title = "Metric"
            SupportFunctions.isMetric = true
            print("Switching to Metric System")
        }
    }
    
    @IBOutlet weak var temperatureSwitchLabel: UIButton!
    @IBAction func temperatureSwitch(_ sender: UIButton) {
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.setTitle("˚F", for: .normal)
            SupportFunctions.isCelsius = false
            print("Switching to F")
            tableView.reloadData()
        case false:
            temperatureSwitchLabel.setTitle("˚C", for: .normal)
            SupportFunctions.isCelsius = true
            print("Switching to C")
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    func fetchData() {
        do {
            items = try context.fetch(Item.fetchRequest())
            filteredData = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Couldn't Fetch Data")
        }
    }
    
}

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellLocalTime: UILabel!
    @IBOutlet weak var cellPlaceName: UILabel!
    @IBOutlet weak var cellTemperature: UILabel!
}

extension DisplayTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        //Pull the city name saved from Core Data
        cell.cellPlaceName.text = filteredData[indexPath.row].name
        
        let location = CLLocationCoordinate2D(latitude: self.filteredData[indexPath.row].lat, longitude: self.filteredData[indexPath.row].long)
        let timeZone = TimezoneMapper.latLngToTimezoneString(location)
        
        //Populate cellLocalTime and cellTemperature labels with data fetched from forecast API
        ForecastService(APIKey: "9b43add4303def8ddb395cc7fec44be7").getCurrentWeather(latitude: filteredData[indexPath.row].lat, longitude: filteredData[indexPath.row].long, completion: { (currentWeather) in
            if let currentWeather = currentWeather {
                if let temperature = currentWeather.temperature {
                    if SupportFunctions.isCelsius == true {
                        cell.cellTemperature.text = String(format: "%.0f", SupportFunctions.fahrenheitToCelsius(temperature: temperature)) + "˚"
                    } else {
                        cell.cellTemperature.text = String(format: "%.0f", temperature) + "˚"
                    }
                } else {
                    cell.cellTemperature.text = "--"
                }
                if let time = currentWeather.time {
                    cell.cellLocalTime.text = SupportFunctions.localTimeAtThatLocationCustom(time: time, identifier: timeZone, format: "EEE dd-MM-yyyy hh:mm")
                } else {
                    cell.cellLocalTime.text = "--:--"
                }
            }
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    //Get the indexPath and perform a pass to another View Controller through segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "viewWeatherVC", sender: self)
//        performSegue(withIdentifier: "basicVC", sender: self)
//        performSegue(withIdentifier: "detailsVC", sender: self)
//        performSegue(withIdentifier: "moreDetailsVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        print(selectedIndex)
    }
    
    
//    func parseSegue(for segue: UIStoryboardSegue, sender: Any?, completion: @escaping () -> Void) -> Void{
//        if segue.identifier == "viewWeatherVC" {
//            let viewWeatherVC = segue.destination as! ViewWeatherViewController
//            viewWeatherVC.item = filteredData[selectedIndex!]
//        }
//        else if segue.identifier == "basicVC" {
//            let basicVC = segue.destination as! SBBasicViewController
//            basicVC.item = filteredData[selectedIndex!]
//        }
//        else if segue.identifier == "detailsVC" {
//            let detailsVC = segue.destination as! SBDetailsViewController
//            detailsVC.item = filteredData[selectedIndex!]
//        }
//        else if segue.identifier == "moreDetailsVC" {
//            let moreDetailsVC = segue.destination as! SBMoreDetailsViewController
//            moreDetailsVC.item = filteredData[selectedIndex!]
//        }
//        completion()
//    }
    
    //Prepare to pass index to another View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewWeatherVC" {
            let viewWeatherVC = segue.destination as! ViewWeatherViewController
            viewWeatherVC.item = filteredData[selectedIndex!]
        }
//        if segue.identifier == "basicVC" {
//            let basicVC = segue.destination as! SBBasicViewController
//            basicVC.item = filteredData[selectedIndex!]
//        }
//        if segue.identifier == "detailsVC" {
//            let detailsVC = segue.destination as! SBDetailsViewController
//            detailsVC.item = filteredData[selectedIndex!]
//        }
//        if segue.identifier == "moreDetailsVC" {
//            let moreDetailsVC = segue.destination as! SBMoreDetailsViewController
//            moreDetailsVC.item = filteredData[selectedIndex!]
//        }
//        parseSegue(for: segue, sender: sender, completion: {
//            print("done")
//        })
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Remove") { (action, indexPath) in
            // delete item at indexPath
            let item = self.filteredData[indexPath.row]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.filteredData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        delete.backgroundColor = UIColor(red: 240/255, green: 52/255, blue: 52/255, alpha: 1.0)
        return [delete]
    }
}

//Tried to sort CoreData with this but failed - Deprecated
//filteredData = items.removeDuplicates()
extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}
