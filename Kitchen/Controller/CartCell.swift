//
//  CartCell.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 3/15/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit


class CartCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var incremetButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}
