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
import MapKit
import CoreData

class AddCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    var results:[String] = []
    var internalResults:[MKLocalSearchCompletion] = []
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        return searchCompleter
    }()
    
    @IBOutlet weak var searchCity: UISearchBar!
    @IBOutlet weak var resultTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Config UI
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Enter city"
        self.view.backgroundColor = UIColor.black
        resultTable.backgroundColor = UIColor.black
        resultTable.tableFooterView = UIView()
        resultTable.dataSource = self
        resultTable.delegate = self
        searchCity.delegate = self
        searchCity.returnKeyType = UIReturnKeyType.search
        searchCity.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchCity.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchCity.resignFirstResponder()
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Taking the location and save it to Core Data
        MKLocalSearch(request: MKLocalSearch.Request(completion: internalResults[indexPath.row])).start { (response, error) in
            let mapItem = response?.mapItems[0]
            let coordinate = mapItem?.placemark.coordinate
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
            let predicate = NSPredicate(format: "name == %@", (mapItem?.name)!)
            request.predicate = predicate
            request.fetchLimit = 1
            do {
                let count = try SupportFunctions.createContext().count(for: request)
                DispatchQueue.main.async {
                    if count == 0 {
                        let newCity = SupportFunctions.createNewCity()
                        newCity.name = mapItem?.name
                        newCity.lat = (coordinate?.latitude)!
                        newCity.long = (coordinate?.longitude)!
                        newCity.timeZone = mapItem?.timeZone
                        SupportFunctions.saveContext()
                        self.performSegue(withIdentifier: "Added", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "Added", sender: nil)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.resultTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = self.results[indexPath.row]
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //change searchCompleter depends on searchBar's text
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        //get result, transform it to our needs and fill our dataSource
        self.internalResults = completer.results
        self.results = internalResults.map { $0.title }
        DispatchQueue.main.async {
            self.resultTable.reloadData()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
    }
}
