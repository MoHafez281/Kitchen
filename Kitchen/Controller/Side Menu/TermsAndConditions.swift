//
//  TermsAndConditions.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SideMenuSwift
import SVProgressHUD

class TermsAndConditions: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sideBarButtonPressed(_ sender: Any) {
        
        self.sideMenuController?.revealMenu()
    }
}
