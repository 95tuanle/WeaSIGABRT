//
//  AddCityViewController.swift
//  WeaSIGABRT
//
//  Created by Tuan Le on 9/24/18.
//  Copyright © 2018 Tuan Le. All rights reserved.
//

import UIKit
import MapKit

class AddCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    @IBOutlet weak var searchCity: UISearchBar!
    
    @IBOutlet weak var resultTable: UITableView!
    var results:[String] = []
    var internalResults:[MKLocalSearchCompletion] = []
    var temp1:String = ""
    var temp2:String = ""
    var temp3:[NSValue] = []
    var temp4:[NSValue] = []
    
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
        searchCity.returnKeyType = UIReturnKeyType.done
        self.navigationItem.largeTitleDisplayMode = .never
        self.title = "Enter city"
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
        self.performSegue(withIdentifier: "", sender: nil)
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
