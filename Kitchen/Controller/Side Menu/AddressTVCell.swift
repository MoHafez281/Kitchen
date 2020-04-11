//
//  AddressTVCell.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/22/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit

class AddressTVCell: UITableViewCell {

    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var fullAddressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
