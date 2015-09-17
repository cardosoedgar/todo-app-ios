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
    lazy var coreDataStack = CoreDataStackManager()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let token = database.getToken()
        
        if token != nil && token != "" {
            let listsVC = storyboard?.instantiateViewControllerWithIdentifier("ListsController") as! ListsController
            listsVC.coreDataStack = coreDataStack
            navigationController?.pushViewController(listsVC, animated: true)
        } else {
            let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
            loginVC.coreDataStack = coreDataStack
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}
