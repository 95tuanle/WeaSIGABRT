//
//  HourlyCollectionViewCell.swift
//  Interface
//
//  Created by Mai Pham Quang Huy on 9/15/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

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
