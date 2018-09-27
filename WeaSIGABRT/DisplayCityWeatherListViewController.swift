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

import UIKit
import CoreData
import WXKDarkSky

class DisplayCityWeatherListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cities:[City] = []
    var selectedRow: Int!
    var oldButtons:[UIBarButtonItem] = []
    
    @IBOutlet weak var cityTable: UITableView!
    @IBOutlet weak var temperatureSwitchLabel: UIBarButtonItem!
    @IBAction func temperatureSwitch(_ sender: Any) {
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.title = "˚F"
            SupportFunctions.isCelsius = false
            cityTable.reloadData()
        case false:
            temperatureSwitchLabel.title = "˚C"
            SupportFunctions.isCelsius = true
            cityTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Config UI
        self.view.backgroundColor = UIColor.black
        self.title = "WeaSIGABRT"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController!.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        cityTable.separatorColor = .clear
        cityTable.tableFooterView = UIView()
        cityTable.dataSource = self
        cityTable.delegate = self
        cityTable.backgroundColor = UIColor.black
        oldButtons = self.navigationItem.rightBarButtonItems!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.title = "˚C"
            cityTable.reloadData()
        case false:
            temperatureSwitchLabel.title = "˚F"
            cityTable.reloadData()
        }
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
        let city = cities[indexPath.row]
        //Get current weather
        let current = SupportFunctions.getCurrentWeather(latitude: city.lat, longitude: city.long).currently
        let imageView = UIImageView(frame: cell.frame)
        imageView.center = cell.center
        imageView.frame.size = cell.frame.size
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        imageView.image = UIImage(named: (current?.icon)!)
        cell.backgroundView = imageView
        cell.placeName.text = city.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = city.timeZone
        cell.localTime.text = dateFormatter.string(from: Date())
        if SupportFunctions.isCelsius {
            cell.temperature.text = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: (current?.temperature)!))
        } else {
            cell.temperature.text = String(format: "%.0f˚", (current?.temperature)!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "Detail City", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //Pass data from table view to View/Edit through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail City" {
            let detailCity: ViewWeatherViewController = segue.destination as! ViewWeatherViewController
            let city = cities[selectedRow!]
            detailCity.city = city
            detailCity.response = SupportFunctions.getCurrentWeather(latitude: city.lat, longitude: city.long)
        }
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
            self.navigationItem.rightBarButtonItems = nil
        } else {
            self.navigationItem.rightBarButtonItems = oldButtons
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
