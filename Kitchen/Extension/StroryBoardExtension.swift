//
//  File.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 3/26/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import UIKit

enum storyBoardName: String {
    case main = "Main"
}

enum storyBoardVCIDs: String {
    case home = "HomeVC"
    case login = "loginVC"
    case profile = "profileVC"
    case register = "registerVC"
    case fav = "FavVC"
    case settings = "SettingsVC"
    case terms = "TermsVC"
    case MyOrders = "MyOrdersVC"
    case profileMenu = "ProfileMenuVC"
    case sideBar = "SideBarVC"
    case registerNav = "registerNav"
}



extension UIStoryboard {
    class func instantiateInitialViewController(_ board: storyBoardName) -> UIViewController {
        let story = UIStoryboard(name: board.rawValue, bundle: nil)
        return story.instantiateInitialViewController()!
    }
}
