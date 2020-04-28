//
//  FavouritesCell.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 3/27/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit

class FavouritesCell: UITableViewCell {

    @IBOutlet weak var favouritesImage: UIImageView!
    @IBOutlet weak var favouritesNameLabel: UILabel!
    @IBOutlet weak var favouritesPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
