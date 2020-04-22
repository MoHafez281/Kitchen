//
//  TermsAndConditions.swift
//  Kitchen
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
        
//      For dismissing loading view if coming back from view that ladoing data
        SVProgressHUD.dismiss()
    }
    
    @IBAction func sideBarTapped(_ sender: Any) {
        
        self.sideMenuController?.revealMenu()
    }

}
