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

import UIKit
import CoreData
import LatLongToTimezone
import CoreLocation

class DisplayCityWeatherListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var temperatureSwitchLabel: UIBarButtonItem!
    @IBAction func temperatureSwitch(_ sender: Any) {
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.title = "˚F"
            SupportFunctions.isCelsius = false
            print("Switching to F")
            cityTable.reloadData()
        case false:
            temperatureSwitchLabel.title = "˚C"
            SupportFunctions.isCelsius = true
            print("Switching to C")
            cityTable.reloadData()
        }
    }
    
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
    
    @IBOutlet weak var cityTable: UITableView!
    
    var cities:[City] = []
    var selectedIndex: Int!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTable.tableFooterView = UIView()
        cityTable.dataSource = self
        cityTable.delegate = self
        cityTable.rowHeight = 100
        self.title = "WeaSIGABRT"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    @objc func addCity() {
        
        self.performSegue(withIdentifier: "Add City", sender: nil)
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return cities.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = cities[indexPath.row].name
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
//        dateFormatter.timeZone = cities[indexPath.row].timeZone as! TimeZone
//        cell.detailTextLabel?.text = dateFormatter.string(from: Date())
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "", sender: nil)
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            cityTable.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        cityTable.setEditing(editing, animated: animated)
        if editing {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        }
    }
    
    func fetchData() {
        do {
            cities = try SupportFunctions.createContext().fetch(City.fetchRequest())
            DispatchQueue.main.async {
                self.cityTable.reloadData()
            }
        } catch {
            print(error)
        }
    }
}

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellPlaceName: UILabel!
    @IBOutlet weak var cellLocalTime: UILabel!
    @IBOutlet weak var cellTemperature: UILabel!
}

extension DisplayCityWeatherListViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        //Pull the city name saved from Core Data
        cell.cellPlaceName.text = cities[indexPath.row].name
        
        let location = CLLocationCoordinate2D(latitude: self.cities[indexPath.row].lat, longitude: self.cities[indexPath.row].long)
        let timeZone = TimezoneMapper.latLngToTimezoneString(location)
        
        //Populate cellLocalTime and cellTemperature labels with data fetched from forecast API
        ForecastService(APIKey: "9b43add4303def8ddb395cc7fec44be7").getCurrentWeather(latitude: cities[indexPath.row].lat, longitude: cities[indexPath.row].long, completion: { (currentWeather) in
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Remove") { (action, indexPath) in
            // delete item at indexPath
            let item = self.cities[indexPath.row]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        delete.backgroundColor = UIColor(red: 240/255, green: 52/255, blue: 52/255, alpha: 1.0)
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsVC" {
            let detailsVC = segue.destination as! ViewWeatherViewController
            detailsVC.cities = cities[selectedIndex!]
        }
    }
}
