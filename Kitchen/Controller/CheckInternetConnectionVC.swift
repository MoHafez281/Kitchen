//
//  CheckInternetConnectionVC.swift
//  Kershoman
//
//  Created by Mohamed Hafez on 11/23/19.
//  Copyright © 2019 Mohamed Hafez. All rights reserved.
//

import UIKit

class CheckInternetConnectionVC: UIViewController , UIAdaptivePresentationControllerDelegate {

       override func viewDidLoad() {
        
            super.viewDidLoad()
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(statusManager),
                             name: .flagsChanged,
                             object: nil)
            updateUserInterface()
        
        presentationController?.delegate = self
        
        }
    
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if Network.reachability.isConnectedToNetwork {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
        } else {
//           Walking thorugh the app while network is down
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
        func updateUserInterface() {
            switch Network.reachability.status {
            case .unreachable:
                view.backgroundColor = .white
            case .wwan:
                view.backgroundColor = .white
            case .wifi:
                view.backgroundColor = .white
            }
            print("Reachability Summary")
            print("Status:", Network.reachability.status)
            print("HostName:", Network.reachability.hostname ?? "nil")
            print("Reachable:", Network.reachability.isReachable)
            print("Wifi:", Network.reachability.isReachableViaWiFi)
        }
        @objc func statusManager(_ notification: Notification) {
            updateUserInterface()
        }
    @IBAction func reloadButtonPressed(_ sender: Any) {

        if Network.reachability.isConnectedToNetwork {
//           _ = navigationController?.popToRootViewController(animated: true)
            dismiss(animated: true) {
                //https://stackoverflow.com/questions/41618182/trigger-function-in-vc-when-modal-view-is-dismissed/41619015
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
            }
            
        } else {
            displayAlertMessage(title: "Alert", messageToDisplay:  "Your Device is not connected with internet")
        }
    }
}
