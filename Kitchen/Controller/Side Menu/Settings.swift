//
//  Settings.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 4/6/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit
import SideMenuSwift
import SVProgressHUD

class Settings: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AddressesVC.dismissBackButtonAddressesVC = 1 //If user go to AddressesVC from InformationConfirmatioVC, AddressesVC will appear as presenation style so this var to let back button act as dismiss else act normally
    }
    
    @IBAction func sideBarButtonPressed(_ sender: Any) {
        self.sideMenuController?.revealMenu()
    }
}
