//
//  LoginController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

protocol SignUpProtocol : class {
    func setRegisteredEmail(name: String?)
}

class LoginController: UIViewController, SignUpProtocol, UITextFieldDelegate {

    var database: DatabaseProtocol?
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = UserDefaultsDatabase()
        setTapAnyWhereToDismissKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
    }
    
    //MARK: - UI Components
    
    func hideNavBar() {
        navigationController?.navigationBarHidden = true
    }
    
    func setTapAnyWhereToDismissKeyboard() {
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func login(sender: AnyObject?) {
        dismissKeyboard()
        if let email = tfEmail.text {
            if let password = tfPassword.text {
                requestLogin(email, password: password)
            }
        }
    }
    
    @IBAction func dontWantToSignUp(sender: UIButton) {
        dismissKeyboard()
        database?.setToken("not signed")
        presentListController()
    }
    
    @IBAction func signUp(sender: UIButton) {
        dismissKeyboard()
        presentSignUpController()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        dismissKeyboard()
        presentForgotPasswordController()
    }
    
    func requestLogin(email: String, password: String) {
        let params = [ "email" : email, "password" : password ]
        
        Alamofire.request(.POST, "http://localhost:8080/login", parameters: params)
            .responseObject { (response: LoginResponse?, error: NSError?) in
                if response == nil {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
                
                if let success = response?.success {
                    if !success {
                        self.createAlertWithMessage(response?.message)
                        return
                    }
                    
                    self.saveToken(response?.token)
                    self.presentListController(response?.lists)
                }
        }
    }
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func saveToken(token: String?) {
        self.database?.setToken(token)
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.nextField == nil {
            login(self)
            return true
        }
        
        textField.nextField?.becomeFirstResponder()
        return true
    }
    
    //MARK: - SignUp Protocol
    
    func setRegisteredEmail(email: String?) {
        tfEmail.text = email
        tfPassword.becomeFirstResponder()
    }
    
    //MARK: - Navigation
    func presentForgotPasswordController() {
        let forgotPasswordController = storyboard?.instantiateViewControllerWithIdentifier("ForgotPasswordController") as! ForgotPasswordController
        navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    func presentSignUpController() {
        let signUpController = storyboard?.instantiateViewControllerWithIdentifier("SignUpController") as! SignupController
        signUpController.loginController = self
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    func presentListController() {
        let tabBarController = storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    func presentListController(lists : [List]?) {
        let tabBarController = storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        let listsController = tabBarController.viewControllers?.filter({ (v) -> Bool in
            return (v is ListsController)
        })[0] as! ListsController
        listsController.list = lists!
        navigationController?.pushViewController(tabBarController, animated: true)
    }
}
