//
//  ViewWeatherViewController.swift
//  WeaSIGABRT
//
//  Created by Mai Pham Quang Huy on 9/24/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit
import CoreLocation
import LatLongToTimezone

class ViewWeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var city: City!
    var hourlyForecastData = [HourlyWeather]()
    var dailyForecastData = [DailyWeather]()
    var summaryData = [DailyWeather]()
    var featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView
    
//    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var currentScrollView: UIScrollView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureEntryData(entry: city)
//        navItem.title = city.name
        self.navigationItem.title = city.name
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismiss(_:)))
        
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        dailyTableView.allowsSelection = false
    }
    
    
    @objc func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Config to make the xib width to fit with scrollview/screen width
        featureView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 500)
        currentScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (featureView?.frame.size.height)! + 30)
        currentScrollView.addSubview(featureView!)
        
        //Summon function up
        updateCurrentWeatherLocation(lat: city.lat, long: city.long)
        
        //Add the custom Collection view cell to the Collection View
        let collectionNibName = UINib(nibName: "HourlyCollectionViewCell", bundle: nil)
        hourlyCollectionView.register(collectionNibName, forCellWithReuseIdentifier: "hourlyCollectionViewCell")
        //Summon the function up, put into view did appear is to let the data to fetch from the web before display it - or it will out of range
        updateHourlyWeatherLocation(location: city.name!)
        
        //Add the custom cell to the Table View
        let tableviewNibName = UINib(nibName: "DailyTableViewCell", bundle: nil)
        dailyTableView.register(tableviewNibName, forCellReuseIdentifier: "dailyTableViewCell")
        //Kuchiyose no jutsu lul
        updateDailyWeatherLocation(location: city.name!)
        
    }
    
    //Populate the ViewWeather with Current Weather data
    func updateCurrentWeatherLocation(lat: Double, long: Double) {
//        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
//            if error == nil {
//                if let location = placemarks?.first?.location {
//
//                }
//            }
//        }
        ForecastService(APIKey: SupportFunctions.apiKey).getCurrentWeather(latitude: lat, longitude: long, completion: { (currentWeather) in
            print("AHYAGASD")
            print(lat)
            print(long)
            if let currentWeather = currentWeather {
                if let temperature = currentWeather.temperature {
                    if SupportFunctions.isCelsius == true {
                        self.featureView?.temperatureLabel.text = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: SupportFunctions.getCurrentTemperature(latitude: lat, longitude: long)))
                    } else {
                        self.featureView?.temperatureLabel.text = String(format: "%.0f", SupportFunctions.getCurrentTemperature(latitude: lat, longitude: long))
                    }
                } else {
                    self.featureView?.temperatureLabel.text = "--"
                }
                if let icon = currentWeather.icon {
                    self.featureView?.iconLabel.text = SupportFunctions.emojiIcons[icon]
                } else {
                    self.featureView?.iconLabel.text = "--"
                }
                if let humidity = currentWeather.humidity {
                    self.featureView?.humidityLabel.text = String("\(humidity)%")
                } else {
                    self.featureView?.humidityLabel.text = "--"
                }
                if let feels = currentWeather.apparentTemperature {
                    if SupportFunctions.isCelsius == true {
                        self.featureView?.feelsLabel.text = String(format: "%.0f˚", SupportFunctions.fahrenheitToCelsius(temperature: feels))
                    } else {
                        self.featureView?.feelsLabel.text = String(format: "%.0f˚", feels)
                    }
                } else {
                    self.featureView?.feelsLabel.text = "--"
                }
                if let windSpd = currentWeather.windSpeed {
                    if SupportFunctions.isMetric == true {
                        self.featureView?.windspeedLabel.text = String(format: "%.1f kph", windSpd*1.60934)
                    } else {
                        self.featureView?.windspeedLabel.text = String(format: "%.1f mph", windSpd)
                    }
                } else {
                    self.featureView?.windspeedLabel.text = "--"
                }
                if let windGust = currentWeather.windGust {
                    if SupportFunctions.isMetric == true {
                        self.featureView?.windgustLabel.text = String(format: "%.1f kph", windGust*1.60934)
                    } else {
                        self.featureView?.windgustLabel.text = String(format: "%.1f mph", windGust)
                    }
                } else {
                    self.featureView?.windgustLabel.text = "--"
                }
                if let rainChance = currentWeather.rainChance {
                    self.featureView?.rainchanceLabel.text = String(format: "%.0f", rainChance*100) + "%"
                } else {
                    self.featureView?.rainchanceLabel.text = "--"
                }
                if let rainIntensity = currentWeather.rainIntensity {
                    if SupportFunctions.isMetric == true {
                        self.featureView?.rainintensityLabel.text = String(format: "%.0f mm/h", rainIntensity*25.4)
                    } else {
                        self.featureView?.rainintensityLabel.text = String(format: "%.0f inch/h", rainIntensity)
                    }
                } else {
                    self.featureView?.rainintensityLabel.text = "--"
                }
                if let UVIndex = currentWeather.uvIndex {
                    self.featureView?.uvindexLabel.text = String(UVIndex)
                } else {
                    self.featureView?.uvindexLabel.text = "--"
                }
                if let cloudCover = currentWeather.cloudCover {
                    self.featureView?.cloudcoverLabel.text = String(format: "%.0f", cloudCover*100) + "%"
                } else {
                    self.featureView?.cloudcoverLabel.text = "--"
                }
                if let visibility = currentWeather.visibility {
                    if SupportFunctions.isMetric == true {
                        self.featureView?.visibilityLabel.text = String(format: "%.0f km", visibility*1.60934)
                    } else {
                        self.featureView?.visibilityLabel.text = String(format: "%.0f miles", visibility)
                    }
                } else {
                    self.featureView?.visibilityLabel.text = "--"
                }
                if let pressure = currentWeather.pressure {
                    self.featureView?.pressureLabel.text = String(format: "%.0f hPa", pressure)
                } else {
                    self.featureView?.pressureLabel.text = "--"
                }
            }
        })
    }
    
    //Populate the CollectionView in ViewWeather with Hourly Weather Data
    func updateHourlyWeatherLocation(location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    HourlyWeather.forecast(withKey: SupportFunctions.apiKey, withLocation: "\(location.coordinate.latitude),\(location.coordinate.longitude)", completion: { (results:[HourlyWeather]?) in
                        if let weatherData = results {
                            self.hourlyForecastData = weatherData
                            DispatchQueue.main.async {
                                self.hourlyCollectionView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    //Collection View style
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCollectionViewCell", for: indexPath) as! HourlyCollectionViewCell
        
        let location = CLLocationCoordinate2D(latitude: city.lat, longitude: city.long)
        let timeZone = TimezoneMapper.latLngToTimezoneString(location)
        let currentLocalTime = SupportFunctions.localTimeAtThatLocationCustom(time: hourlyForecastData[indexPath.row].time, identifier: timeZone, format: "HH:mm")
                
        var convertingTemperature = String()
        if SupportFunctions.isCelsius == true {
            convertingTemperature = String("\(Int(SupportFunctions.fahrenheitToCelsius(temperature: hourlyForecastData[indexPath.row].temperature)))˚")
        } else {
            convertingTemperature = String("\(Int(hourlyForecastData[indexPath.row].temperature))˚")
        }
        
        cell.commonInit(time: currentLocalTime, temperature: convertingTemperature, icon: SupportFunctions.emojiIcons[hourlyForecastData[indexPath.row].icon]!)
        
        return cell
    }
    
    //Populate the Table View in ViewWeather with Daily Weather data
    func updateDailyWeatherLocation(location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    DailyWeather.forecast(withKey: SupportFunctions.apiKey, withLocation: "\(location.coordinate.latitude),\(location.coordinate.longitude)", completion: { (results: [DailyWeather]?) in
                        if let weatherData = results {
                            self.dailyForecastData = weatherData
                            DispatchQueue.main.async {
                                self.dailyTableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    //Table View style
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecastData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyTableView.dequeueReusableCell(withIdentifier: "dailyTableViewCell", for: indexPath) as! DailyTableViewCell
        
        let location = CLLocationCoordinate2D(latitude: city.lat, longitude: city.long)
        let timeZone = TimezoneMapper.latLngToTimezoneString(location)
        let currentLocalTime = SupportFunctions.localTimeAtThatLocationCustom(time: dailyForecastData[indexPath.row].time, identifier: timeZone, format: "EEE dd-MM-yyyy")
        
        featureView?.summaryLabel.text = dailyForecastData[0].summary
        
        var convertingTemperature = String()
        if SupportFunctions.isCelsius == true {
            convertingTemperature = String("\(Int(SupportFunctions.fahrenheitToCelsius(temperature: dailyForecastData[indexPath.row].temperature)))˚")
        } else {
            convertingTemperature = String("\(Int(dailyForecastData[indexPath.row].temperature))˚")
        }
        
        cell.commonInit(date: currentLocalTime, temperature: convertingTemperature, icon: SupportFunctions.emojiIcons[dailyForecastData[indexPath.row].icon]!)
        
        return cell
    }
    
    func configureEntryData(entry: City) {
        guard let text = entry.name else {
            return
        }
        self.title = text
    }
    
}
