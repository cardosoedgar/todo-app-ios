//
//  ListsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
import UIKit

class ListsController: UITableViewController {
    
    var coreDataStack : CoreDataStackManager!
    var currentUser : User!
    var database = UserDefaultsDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
        if currentUser == nil {
            getUser()
        }
    }
    
    // MARK: - UI Componentes
    
    func getUser() {
        let userFetch = NSFetchRequest(entityName: "User")
        var error: NSError?
        
        let result = coreDataStack.context.executeFetchRequest(userFetch, error: &error) as! [User]?
        
        if let users = result {
            currentUser = users.first
            tableView.reloadData()
        } else {
            println("error")
        }
    }
    
    func setUpTableView() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func setUpNavBar() {
        title = "Lists"
        navigationController?.navigationBarHidden = false
        hideBackButton()
        addRightNavBarButtons()
    }
    
    func hideBackButton() {
        let backButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    func addRightNavBarButtons() {
        let addButton = createNewListButton()
        let settingsButton = createSettingsButton()
        navigationItem.rightBarButtonItems = [settingsButton, addButton]
    }
    
    func createNewListButton() -> UIBarButtonItem{
        return UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewList:")
    }
    
    func createSettingsButton() -> UIBarButtonItem {
        let icon = UIImage(named: "settings_icon")
        return UIBarButtonItem(image: icon, style: .Plain, target: self, action: "presentSettingsController")
    }
    
    func addNewList(sender: AnyObject?) {
        
    }
    
    func presentSettingsController() {
        var settingsVC = storyboard?.instantiateViewControllerWithIdentifier("SettingsController") as! SettingsController
        settingsVC.modalPresentationStyle = .FullScreen
        settingsVC.modalTransitionStyle = .CoverVertical
        presentViewController(settingsVC, animated: true, completion: nil)

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
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        let list = currentUser.lists[indexPath.row] as! List
        cell.textLabel?.text = list.name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tasksVC = storyboard?.instantiateViewControllerWithIdentifier("TasksController") as! TasksController
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
