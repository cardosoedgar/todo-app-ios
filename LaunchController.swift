//
//  LaunchControllerViewController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/1/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {

    let database = UserDefaultsDatabase()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        database.setToken("")
        var token = database.getToken()
        
        if token != "" {
            let tabBarController = storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            navigationController?.pushViewController(tabBarController, animated: true)
        } else {
            var loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}
