//
//  LoginController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
import UIKit
import Alamofire

class LoginController: UIViewController, SignUpProtocol, UITextFieldDelegate {
    
    var coreDataStack: CoreDataStackManager!
    var database = UserDefaultsDatabase()
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapAnyWhereToDismissKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
    }
    
    //MARK: - Core Methods
    func requestLogin(email: String, password: String) {
        let params = [ "email" : email, "password" : password ]
        
        Alamofire.request(.POST, "http://localhost:8080/login", parameters: params)
            .responseJSON { (_, _, result) -> Void in
                if result.isFailure {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
                
                if let success = result.value?.valueForKey("success") as? Bool {
                    if !success {
                        let message = result.value?.valueForKey("message") as? String
                        self.createAlertWithMessage(message)
                        return
                    }
                    
                    let token = result.value?.valueForKey("token") as? String
                    self.saveToken(token)
                    
                    if let userDict = result.value?.valueForKey("user") as? NSDictionary{
                        let user = User.fromJSON(userDict, andContext: self.coreDataStack.context)
                    
                        if let listsArray = result.value?.valueForKey("lists") as? NSArray {
                            for listDict in listsArray {
                                let list = user.addList(listDict as! NSDictionary, context: self.coreDataStack.context)
                            
                                if let tasksArray = listDict["Tasks"] as? NSArray {
                                    for taskDict in tasksArray {
                                        list.addTask(taskDict as! NSDictionary, context: self.coreDataStack.context)
                                    }
                                }
                            }
                        }
                    
                        self.coreDataStack.saveContext()
                        self.presentListController(user)
                    }
                }
        }
    }
    
    //MARK: - UI Components
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
        database.setToken("not signed")
        
        var user = database.getUser(self.coreDataStack.context)
        if user == nil {
            user = createGenericUser()
        }
        
        presentListController(user!)
    }
    
    @IBAction func signUp(sender: UIButton) {
        dismissKeyboard()
        presentSignUpController()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        dismissKeyboard()
        presentForgotPasswordController()
    }
    
    //MARK: - Helper Methods
    func createGenericUser() -> User? {
        let genericUser = ["id":"genericid", "name":"generic", "email" : "generic@gmail.com", "password":"generic"]
        let user = User.fromJSON(genericUser, andContext: coreDataStack.context)
        coreDataStack.saveContext()
        return user
    }
    
    func hideNavBar() {
        navigationController?.navigationBarHidden = true
    }
    
    func setTapAnyWhereToDismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func saveToken(token: String?) {
        self.database.setToken(token)
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
    
    func presentListController(user : User) {
        let listsController = storyboard?.instantiateViewControllerWithIdentifier("ListsController") as! ListsController
        listsController.currentUser = user
        listsController.coreDataStack = coreDataStack
        navigationController?.pushViewController(listsController, animated: true)
    }
}
