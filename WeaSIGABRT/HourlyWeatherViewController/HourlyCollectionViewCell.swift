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

class HourlyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var iconLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func commonInit(time: String, temperature: String, icon: String) {
        timeLabel.text = time
        temperatureLabel.text = temperature
        iconLabel.text = icon
    }

}
