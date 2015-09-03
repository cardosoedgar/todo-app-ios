//
//  ForgotPasswordController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class ForgotPasswordController: UIViewController {

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
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}