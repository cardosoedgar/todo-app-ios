//
//  SettingsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/2/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var switchAutoBackup: UISwitch!

    var database = UserDefaultsDatabase()
    var coreDataStack: CoreDataStackManager!
    var delegate: LogoutProtocol!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpSwitchAutoBackup()
        setUpNavBar()
    }
    
    func setUpSwitchAutoBackup() {
        switchAutoBackup.on = database.isAutoBackupOn()
        switchAutoBackup.addTarget(self, action: "switchAutoBackupValueChanged:", forControlEvents: .ValueChanged)
    }
    
    func switchAutoBackupValueChanged(sender: UISwitch) {
        if sender.on {
            database.toggleAutoBackup(true)
        } else {
            database.toggleAutoBackup(false)
        }
    }
    
    //MARK: - UI Components
    @IBAction func closeSettings(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        deleteUser()
        database.deleteToken()
        delegate.didLogout()
    }
    
    //MARK: Helper Methods
    func deleteUser() {
        let user = database.getUser(coreDataStack.context)
        coreDataStack.context.deleteObject(user!)
        coreDataStack.saveContext()
    }
    
    //MARK: - set Navigation Bar
    func setUpNavBar() {
        title = "Settings"
        navigationController?.navigationBarHidden = false
        
    }
}
