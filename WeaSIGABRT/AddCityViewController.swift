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
import MapKit
import CoreData

class AddCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var searchCity: UISearchBar!
    @IBOutlet weak var resultTable: UITableView!
    
    var results:[String] = []
    var internalResults:[MKLocalSearchCompletion] = []
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        return searchCompleter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTable.tableFooterView = UIView()
        resultTable.dataSource = self
        resultTable.delegate = self
        searchCity.delegate = self
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(abc))
        searchCity.returnKeyType = UIReturnKeyType.search
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Enter city"
        searchCity.becomeFirstResponder()
    }
    
//    @objc func abc() {
//        self.searchCity.text = "My Location"
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchCity.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchCity.resignFirstResponder()
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let searchRequest = MKLocalSearch.Request(completion: internalResults[indexPath.row])
        //        let search = MKLocalSearch(request: searchRequest)
        //        search.start { (response, error) in
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
