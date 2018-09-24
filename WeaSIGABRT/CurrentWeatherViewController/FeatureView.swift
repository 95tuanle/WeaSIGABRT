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
