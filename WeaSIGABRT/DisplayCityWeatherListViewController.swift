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

class DisplayCityWeatherListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var cities:[City] = []
    @IBOutlet weak var cityTable: UITableView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTable.tableFooterView = UIView()
        cityTable.dataSource = self
        cityTable.delegate = self
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.placeName.text = cities[indexPath.row].name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = cities[indexPath.row].timeZone
        cell.localTime.text = dateFormatter.string(from: Date())
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "Detail City", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            SupportFunctions.deleteCity(city: cities[indexPath.row])
            cities.remove(at: indexPath.row)
            cityTable.deleteRows(at: [indexPath], with: .automatic)
            fetchData()
        }
    }
    
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
    @IBOutlet weak var localTime: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var temperature: UILabel!
}
