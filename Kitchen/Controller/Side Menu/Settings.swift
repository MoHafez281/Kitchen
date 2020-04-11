//
//  Settings.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SideMenuSwift

class Settings: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sideBarTapped(_ sender: Any) {
        
        self.sideMenuController?.revealMenu()
    }
}
