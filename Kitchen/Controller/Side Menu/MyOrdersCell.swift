//
//  MyOrdersCell.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 6/16/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit

class MyOrdersCell: UITableViewCell {

    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
