//
//  SignupController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/3/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit
import Alamofire

class SignupController: UIViewController, UITextFieldDelegate {

    var loginController: SignUpProtocol?
    @IBOutlet weak var tfName: CustomTextField!
    @IBOutlet weak var tfEmail: CustomTextField!
    @IBOutlet weak var tfPassword: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarVisible()
        setNavBarTransparent()
        setTapAnyWhereToDismissKeyboard()
    }
    
    //MARK: - UI Components
    
    func setNavBarVisible() {
        navigationController?.navigationBarHidden = false
    }
    
    func setNavBarTransparent() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
    }
    
    func setTapAnyWhereToDismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submitSignUp(sender: AnyObject?) {
        dismissKeyboard()
        if let email = tfEmail.text {
            if let password = tfPassword.text {
                if let name = tfName.text {
                    requestSignUp(email, password: password, name: name)
                }
            }
        }
    }
    
    func requestSignUp(email: String, password: String, name: String) {
        let params = [ "email" : email, "password" : password, "name" : name ]
        
        Alamofire.request(.POST, "http://localhost:8080/signup", parameters: params)
            .responseJSON { (_, _, result) in
                if result.isFailure {
                    self.createAlertWithTitle("Ops!", andMessage: "Can't connect to the server. Check your internet connection")
                    return
                }
                
                let JSON = result.value
                
                if let success = JSON?.valueForKey("success") as? Bool {
                    if !success {
                        let message = JSON?.valueForKey("message") as? String
                        self.createAlertWithTitle("Ops!", andMessage: message)
                        return
                    }
                    
                    self.loginController?.setRegisteredEmail(email)
                    self.navigationController?.popViewControllerAnimated(true)
                }
        }
    }
    
    func createAlertWithTitle(title: String?, andMessage message: String?) {
        let alert = UIAlertView()
        alert.title = title!
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.nextField == nil {
            submitSignUp(self)
            return true
        }
        
        textField.nextField?.becomeFirstResponder()
        return true
    }
}
