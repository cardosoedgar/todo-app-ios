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

class LoginController: UIViewController {

    var database: DatabaseProtocol?
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = UserDefaultsDatabase()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
    }
    
    func hideNavBar() {
        navigationController?.navigationBarHidden = true
    }
    
    @IBAction func login(sender: UIButton) {
        if let email = tfEmail.text {
            if let password = tfPassword.text {
                requestLogin(email, password: password)
            }
        }
    }
    
    @IBAction func dontWantToSignUp(sender: UIButton) {
        database?.setToken("not signed")
        presentListController()
    }
    
    func requestLogin(email: String, password: String) {
        let params = [ "email" : email, "password" : password ]
        
        Alamofire.request(.POST, "http://localhost:8080/login", parameters: params)
            .responseObject { (response: LoginResponse?, error: NSError?) in
                if response == nil {
                    self.createAlertWithMessage("Não foi possível conectar-se ao servidor.")
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
    
    func saveToken(token: String?) {
        self.database?.setToken(token)
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
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Erro"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
}
