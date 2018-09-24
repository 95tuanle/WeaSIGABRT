//
//  DailyTableViewCell.swift
//  Interface
//
//  Created by Mai Pham Quang Huy on 9/16/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(date: String, temperature: String, icon: String) {
        dateLabel.text = date
        temperatureLabel.text = temperature
        iconLabel.text = icon
    }
    
}
