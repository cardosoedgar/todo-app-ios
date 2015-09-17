//
//  ListsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
import UIKit

class ListsController: UITableViewController, LogoutProtocol {
    
    var coreDataStack : CoreDataStackManager!
    var currentUser : User!
    var database = UserDefaultsDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
        
        if currentUser == nil {
            loadUser()
        }
    }
    
    // MARK: - UI Componentes
    
    func loadUser() {
        currentUser = database.getUser(coreDataStack.context)
        tableView.reloadData()
    }
    
    func setUpNavBar() {
        title = "Lists"
        navigationController?.navigationBarHidden = false
        addNavBarButtons()
    }
    
    func addNavBarButtons() {
        let addButton = createNewListButton()
        navigationItem.rightBarButtonItem = addButton
        
        let settingsButton = createSettingsButton()
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    func createNewListButton() -> UIBarButtonItem{
        return UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewList")
    }
    
    func createSettingsButton() -> UIBarButtonItem {
        let icon = UIImage(named: "settings_icon")
        return UIBarButtonItem(image: icon, style: .Plain, target: self, action: "checkUserIsLoggedIn")
    }
    
    func addNewList() {
        
    }
    
    func checkUserIsLoggedIn() {
        let token = database.getToken()
        if token != "not signed" {
            openSettingsController()
        } else {
            openLoginController()
        }
    }
    
    func openSettingsController() {
        let settingsVC = storyboard?.instantiateViewControllerWithIdentifier("SettingsController") as! SettingsController
        settingsVC.delegate = self
        settingsVC.coreDataStack = coreDataStack
        presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    func openLoginController() {
        database.deleteToken()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - Logout Protocol
    
    func didLogout() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            navigationController?.popToRootViewControllerAnimated(true)
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if let user = currentUser {
            numRows = user.lists.count
        }
        
        return numRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListsTableViewCell
        
        let list = currentUser.lists[indexPath.row] as! List
        cell.labelName?.text = list.name
        cell.labelNumberTasks?.text = "\(list.tasks.count) tasks"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tasksVC = storyboard?.instantiateViewControllerWithIdentifier("TasksController") as! TasksController
        tasksVC.currentList = currentUser.lists[indexPath.row] as! List
        navigationController?.pushViewController(tasksVC, animated: true)

    }

//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            user.lists.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//        }
//    }
}
