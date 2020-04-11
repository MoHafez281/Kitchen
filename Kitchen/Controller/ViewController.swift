//
//  ViewController.swift
//  Kitchen
//
//  Created by Mohamed Hafez on 12/26/18.
//  Copyright © 2018 Mohamed Hafez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ObjectMapper

class ViewController: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.layer.cornerRadius = self.view.frame.height * 0.082 * 0.5
        
    }
    
    @IBAction func skipButtonClicked(_ sender: UIButton) {

        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        //https://stackoverflow.com/questions/41144523/swap-rootviewcontroller-with-animation
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .allowAnimatedContent
        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.3
        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
        { completed in
            // maybe do something on completion here
            appDelegate.setRoot(storyBoard: .main, vc: .home)
        })
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
            login()
    }
}

extension ViewController {
    
    func login() {
        
        DispatchQueue.main.async {
            
            let params  = ["email" : self.emailTextField.text! ,"password" : self.passwordTextField.text! ] as [String: AnyObject]
            let manager = Manager()
            manager.perform(serviceName: .login, parameters: params) { (JSON, error) -> Void in
                
                if(error != nil){
                    
                    self.dismissSVProgress()
                    self.noInternetConnection()

                } else {
                    
                    let jsonDict = JSON as? NSDictionary
                    let loginResponse = jsonDict!["error"]
                    let loginMessage = jsonDict?["message"]
                    
                    if (loginResponse as? Int == 1) {
                        
                        self.dismissSVProgress()
                        self.displayAlertMessage(title: "Error", messageToDisplay: loginMessage as! String)
                        
                    } else {
                        
                        self.dismissSVProgress()
                        let user: User = Mapper<User>().map(JSONObject: JSON)!
                        User.shared.setIsRegister(registered: true)
                        User.shared.fillUserModel(model: user)
                        User.shared.saveData()
                        self.performSegue(withIdentifier: "goToKitchen", sender: self)
                    }
                }
            }
        }
    }
}








