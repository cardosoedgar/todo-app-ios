//
//  ListsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class ListsController: UITableViewController {
    
    var list : [List] = []
    var database = UserDefaultsDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    // MARK: - UI Componentes
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func setUpNavBar() {
        tabBarController?.title = "Lists"
        hideBackButton()
        addRightNavBarButton()
    }
    
    func hideBackButton() {
        let backButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        tabBarController?.navigationItem.leftBarButtonItem = backButton
    }
    
    func addRightNavBarButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewList:")
        tabBarController?.navigationItem.rightBarButtonItem = addButton
    }
    
    func addNewList(sender: AnyObject?) {
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = list[indexPath.row].name

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            list.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
        }
    }
}
