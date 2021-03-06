//
//  ForgotPasswordController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var textFieldEmail: CustomTextField!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarVisible()
        setNavBarTransparent()
        setTapAnyWhereToDismissKeyboard()
    }
    
    //MARK: - UI Components
    @IBAction func submitRequest(sender: AnyObject) {
//        if let email = textFieldEmail.text {
//            //TODO Alamofire request
//        }
    }
    
    //MARK: - Helper Methods
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
}