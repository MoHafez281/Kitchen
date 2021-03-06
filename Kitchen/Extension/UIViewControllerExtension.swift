//
//  UIViewControllerExtension.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 7/2/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension UIViewController {
    
    func displayAlertMessage(title: String , messageToDisplay: String) {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func showSVProgress() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
    }
    
    func dismissSVProgress() {
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()

    }
    
    func placeholder (textFields: UITextField , placeHolderName: String , color: UIColor) {
        
        textFields.attributedPlaceholder = NSAttributedString(string: placeHolderName, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func noInternetConnection() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckInternetConnectionVC") as? CheckInternetConnectionVC
        self.present(vc!, animated: true, completion: nil)
//        self.show(vc!, sender: self)
    }
    
    func animationWithAppDelegate() {
        //https://stackoverflow.com/questions/41144523/swap-rootviewcontroller-with-animation
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.3
        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil.
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
        { completed in
            // maybe do something on completion here
        })
    }
//  For making Tableview reload with animation
//    func animateYableViewRows() {
//        let cells = tableView.visibleCells
//        for cell in cells {
//            cell.transform = CGAffineTransform(translationX: 0, y: tableView.frame.height)
//        }
//        var delay = 0.0
//        for cell in cells {
//            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//                cell.transform = .identity
//            })
//            delay += 0.05
//        }
//    }
}
