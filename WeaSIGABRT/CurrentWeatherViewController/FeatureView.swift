//
//  FeatureView.swift
//  Implement UIView
//
//  Created by Mai Pham Quang Huy on 9/23/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit

class FeatureView: UIView {
 
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var feelsLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    @IBOutlet weak var windgustLabel: UILabel!
    @IBOutlet weak var rainchanceLabel: UILabel!
    @IBOutlet weak var rainintensityLabel: UILabel!
    @IBOutlet weak var uvindexLabel: UILabel!
    @IBOutlet weak var cloudcoverLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    func commonInit(summary: String) {
        summaryLabel.text = summary
    }
}
