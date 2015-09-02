//
//  SettingsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    func setUpNavBar() {
        tabBarController?.title = "Settings"
        hideBackButton()
        addRightNavBarButton()
    }
    
    func hideBackButton() {
        let backButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        tabBarController?.navigationItem.leftBarButtonItem = backButton
    }
    
    func addRightNavBarButton() {
        let rightButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        tabBarController?.navigationItem.rightBarButtonItem = rightButton
    }


}
