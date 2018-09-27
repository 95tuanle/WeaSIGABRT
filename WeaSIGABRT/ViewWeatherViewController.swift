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
import CoreLocation
import LatLongToTimezone
import WXKDarkSky

class ViewWeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var city: City!
    var response:WXKDarkSkyResponse!
    var timeMachineAndForecastWeatherData = [WXKDarkSkyDataPoint]()
    var featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var currentScrollView: UIScrollView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyTableView: UITableView!
    
    @IBOutlet weak var metricSwitchLabel: UIBarButtonItem!
    @IBAction func metricSwitch(_ sender: Any) {
        switch SupportFunctions.isMetric {
        case true:
            metricSwitchLabel.title = "Imperial"
            SupportFunctions.isMetric = false
            updateCurrentWeather(response: response)
        case false:
            metricSwitchLabel.title = "Metric"
            SupportFunctions.isMetric = true
            updateCurrentWeather(response: response)
        }
    }
    @IBOutlet weak var temperatureSwitchLabel: UIBarButtonItem!
    @IBAction func temperatureSwitch(_ sender: Any) {
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.title = "˚F"
            SupportFunctions.isCelsius = false
            updateCurrentWeather(response: response)
            dailyTableView.reloadData()
            hourlyCollectionView.reloadData()
            featureView?.reloadInputViews()
            
        case false:
            temperatureSwitchLabel.title = "˚C"
            SupportFunctions.isCelsius = true
            updateCurrentWeather(response: response)
            dailyTableView.reloadData()
            hourlyCollectionView.reloadData()
            featureView?.reloadInputViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup a blur screen to wait for loading forecast data
        loadingView.alpha = 1.0
        loadingLabel.alpha = 1.0
        loadingView.blurView.setup(style: UIBlurEffect.Style.light, alpha: 0.9).enable()
        
        switch SupportFunctions.isMetric {
        case true:
            metricSwitchLabel.title = "Metric"
            updateCurrentWeather(response: response)
        case false:
            metricSwitchLabel.title = "Imperial"
            updateCurrentWeather(response: response)
        }
        switch SupportFunctions.isCelsius {
        case true:
            temperatureSwitchLabel.title = "˚C"
            updateCurrentWeather(response: response)
            dailyTableView.reloadData()
            hourlyCollectionView.reloadData()
            featureView?.reloadInputViews()
            
        case false:
            temperatureSwitchLabel.title = "˚F"
            updateCurrentWeather(response: response)
            dailyTableView.reloadData()
            hourlyCollectionView.reloadData()
            featureView?.reloadInputViews()
        }
        self.navigationItem.title = city.name
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismiss(_:)))
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        dailyTableView.allowsSelection = false
        dailyTableView.separatorColor = .clear
        dailyTableView.tableFooterView = UIView()
        //Add the custom Collection view cell to the Collection View
        let collectionNibName = UINib(nibName: "HourlyCollectionViewCell", bundle: nil)
        hourlyCollectionView.register(collectionNibName, forCellWithReuseIdentifier: "hourlyCollectionViewCell")
        //Add the custom cell to the Table View
        let tableviewNibName = UINib(nibName: "DailyTableViewCell", bundle: nil)
        dailyTableView.register(tableviewNibName, forCellReuseIdentifier: "dailyTableViewCell")
        updateCurrentWeather(response: response)
        backgroundImage.image = UIImage(named: (response.currently?.icon)!)
    }
    
    @objc func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingView.alpha = 0.0
        loadingLabel.alpha = 0.0
        //Config to make the xib width to fit with scrollview/screen width
        featureView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 500)
        currentScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (featureView?.frame.size.height)! + 30)
        currentScrollView.addSubview(featureView!)
        //Kuchiyose no jutsu lul
        timeMachineAndForecastWeatherData = SupportFunctions.forecastAndTimeMachineQuery(city: city)
        dailyTableView.reloadData()
    }
    
    //Populate the ViewWeather with Current Weather data
    func updateCurrentWeather(response: WXKDarkSkyResponse) {
        let meh = response.currently
        if (meh?.temperature) != nil {
            if SupportFunctions.isCelsius == true {
                self.featureView?.temperatureLabel.text = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: (response.currently?.temperature)!))
            } else {
                self.featureView?.temperatureLabel.text = String(format: "%.0f˚", (response.currently?.temperature)!)
            }
        } else {
            self.featureView?.temperatureLabel.text = "--"
        }
        if let icon = meh?.icon {
            self.featureView?.iconLabel.text = SupportFunctions.emojiIcons[icon]
        } else {
            self.featureView?.iconLabel.text = "--"
        }
        if let humidity = meh?.humidity {
            self.featureView?.humidityLabel.text = String(format: "%.0f", humidity*100) + "%"
        } else {
            self.featureView?.humidityLabel.text = "--"
        }
        if let feels = meh?.apparentTemperature {
            if SupportFunctions.isCelsius == true {
                self.featureView?.feelsLabel.text = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: feels))
            } else {
                self.featureView?.feelsLabel.text = String(format: "%.0f˚", feels)
            }
        } else {
            self.featureView?.feelsLabel.text = "--"
        }
        if let windSpd = meh?.windSpeed {
            if SupportFunctions.isMetric == true {
                self.featureView?.windspeedLabel.text = String(format: "%.1f kph", windSpd*1.60934)
            } else {
                self.featureView?.windspeedLabel.text = String(format: "%.1f mph", windSpd)
            }
        } else {
            self.featureView?.windspeedLabel.text = "--"
        }
        if let windGust = meh?.windGust {
            if SupportFunctions.isMetric == true {
                self.featureView?.windgustLabel.text = String(format: "%.1f kph", windGust*1.60934)
            } else {
                self.featureView?.windgustLabel.text = String(format: "%.1f mph", windGust)
            }
        } else {
            self.featureView?.windgustLabel.text = "--"
        }
        if let rainChance = meh?.precipProbability {
            self.featureView?.rainchanceLabel.text = String(format: "%.0f", rainChance*100) + "%"
        } else {
            self.featureView?.rainchanceLabel.text = "--"
        }
        if let rainIntensity = meh?.precipIntensity {
            if SupportFunctions.isMetric == true {
                self.featureView?.rainintensityLabel.text = String(format: "%.0f mm/h", rainIntensity*25.4)
            } else {
                self.featureView?.rainintensityLabel.text = String(format: "%.0f inch/h", rainIntensity)
            }
        } else {
            self.featureView?.rainintensityLabel.text = "--"
        }
        if let UVIndex = meh?.uvIndex {
            self.featureView?.uvindexLabel.text = String(UVIndex)
        } else {
            self.featureView?.uvindexLabel.text = "--"
        }
        if let cloudCover = meh?.cloudCover {
            self.featureView?.cloudcoverLabel.text = String(format: "%.0f", cloudCover*100) + "%"
        } else {
            self.featureView?.cloudcoverLabel.text = "--"
        }
        if let visibility = meh?.visibility {
            if SupportFunctions.isMetric == true {
                self.featureView?.visibilityLabel.text = String(format: "%.0f km", visibility*1.60934)
            } else {
                self.featureView?.visibilityLabel.text = String(format: "%.0f miles", visibility)
            }
        } else {
            self.featureView?.visibilityLabel.text = "--"
        }
        if let pressure = meh?.pressure {
            self.featureView?.pressureLabel.text = String(format: "%.0f hPa", pressure)
        } else {
            self.featureView?.pressureLabel.text = "--"
        }
            
    }
    
    //Collection View style
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (response.hourly?.data.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCollectionViewCell", for: indexPath) as! HourlyCollectionViewCell
        let aHour = response.hourly?.data[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentLocalTime = dateFormatter.string(from: (aHour?.time)!)
        var convertingTemperature = String()
        if SupportFunctions.isCelsius == true {
            convertingTemperature = String("\(Int(SupportFunctions.fahrenheitToCelsius(temperature: aHour!.temperature!)))˚")
        } else {
            convertingTemperature = String("\(Int(aHour!.temperature!))˚")
        }
        
        var currentTime = String()
        if indexPath.row == 0 {
            currentTime = "Now"
        } else {
            currentTime = currentLocalTime
        }
        
        cell.commonInit(time: currentTime, temperature: convertingTemperature, icon: SupportFunctions.emojiIcons[aHour!.icon!]!)
        return cell
    }
    
    //Table View style
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeMachineAndForecastWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyTableView.dequeueReusableCell(withIdentifier: "dailyTableViewCell", for: indexPath) as! DailyTableViewCell
        let aDate = timeMachineAndForecastWeatherData[indexPath.row]
        let location = CLLocationCoordinate2D(latitude: city.lat, longitude: city.long)
        let timeZone = TimezoneMapper.latLngToTimezoneString(location)
        var currentLocalTime = String()
        if indexPath.row == 7 {
            currentLocalTime = "Today"
        } else {
            currentLocalTime = SupportFunctions.localTimeAtThatLocationCustom(time: aDate.time.timeIntervalSince1970, identifier: timeZone, format: "EEEE")
        }
        featureView?.summaryLabel.text = timeMachineAndForecastWeatherData[7].summary
        var convertingTemperature = String()
        if let temperature = aDate.temperatureHigh {
            if SupportFunctions.isCelsius == true {
                convertingTemperature = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: temperature))
            } else {
                convertingTemperature = String(format: "%.0f˚", temperature)
            }
        } else {
            convertingTemperature = "--˚"
        }
        var convertingTemperatureMin = String()
        if let temperature = aDate.temperatureLow {
            if SupportFunctions.isCelsius == true {
                convertingTemperatureMin = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: temperature))
            } else {
                convertingTemperatureMin = String(format: "%.0f˚", temperature)
            }
        } else {
            convertingTemperatureMin = "--˚"
        }
        cell.commonInit(date: currentLocalTime, temperature: convertingTemperature, temperatureMin: convertingTemperatureMin, icon: SupportFunctions.emojiIcons[aDate.icon!]!)
        return cell
    }
}
