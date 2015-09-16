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

protocol SignUpProtocol : class {
    func setRegisteredEmail(name: String?)
}

class LoginController: UIViewController, SignUpProtocol, UITextFieldDelegate {
    
    var coreDataStack: CoreDataStackManager!
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
            .responseJSON { request, response, JSON, error in
                if JSON == nil {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
                
                if let success = JSON?.valueForKey("success") as? Bool {
                    if !success {
                        let message = JSON?.valueForKey("message") as? String
                        self.createAlertWithMessage(message)
                        return
                    }
                    
                    let token = JSON?.valueForKey("token") as? String
                    self.saveToken(token)
                    
                    var user: User!
                    if let userDict = JSON?.valueForKey("user") as? NSDictionary{
                        user = User.userFromJSON(userDict, andContext: self.coreDataStack.context)
                    }
                    
                    if let listsArray = JSON?.valueForKey("lists") as? NSArray {
                        for listDict in listsArray {
                            var list = List.listFromJSON(listDict as! NSDictionary, andContext: self.coreDataStack.context)
                            
                            if let tasksArray = listDict["Tasks"] as? NSArray {
                                for taskDict in tasksArray {
                                    var task = Task.taskFromJSON(taskDict as! NSDictionary, andContext: self.coreDataStack.context)
                                    
                                    var tasks = list.tasks.mutableCopy() as! NSMutableOrderedSet
                                    tasks.addObject(task)
                                    list.tasks = tasks as NSOrderedSet
                                }
                            }
                            
                            var lists = user.lists.mutableCopy() as! NSMutableOrderedSet
                            lists.addObject(list)
                            user.lists = lists as NSOrderedSet
                        }
                    }
                    
                    self.coreDataStack.saveContext()
                    self.presentListController(user)
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
        let listsController = storyboard?.instantiateViewControllerWithIdentifier("ListsController") as! ListsController
        listsController.coreDataStack = coreDataStack
        navigationController?.pushViewController(listsController, animated: true)
    }
    
    func presentListController(user : User) {
        let listsController = storyboard?.instantiateViewControllerWithIdentifier("ListsController") as! ListsController
        listsController.currentUser = user
        listsController.coreDataStack = coreDataStack
        navigationController?.pushViewController(listsController, animated: true)
    }
}
