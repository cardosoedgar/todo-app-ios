//
//  SettingsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

protocol LogoutProtocol: class {
    func didLogout()
}

class SettingsController: UIViewController {

    var database = UserDefaultsDatabase()
    var coreDataStack: CoreDataStackManager!
    var delegate: LogoutProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    //MARK: - UI Components
    
    func setUpNavBar() {
        title = "Settings"
        navigationController?.navigationBarHidden = false
        
    }

    @IBAction func closeSettings(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logout(sender: AnyObject) {
        deleteUser()
        database.deleteToken()
        delegate.didLogout()
    }
    
    func deleteUser() {
        let user = database.getUser(coreDataStack.context)
        coreDataStack.context.deleteObject(user)
        coreDataStack.saveContext()
    }
}
