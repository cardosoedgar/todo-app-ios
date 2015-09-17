//
//  TasksController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/15/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class TasksController: UITableViewController {

    var currentList: List!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    func setUpNavBar() {
        title = NSLocalizedString("taskViewTitle", comment: "")
        navigationController?.navigationBarHidden = false
        navigationItem.rightBarButtonItem = createNewListButton()
    }
    
    func createNewListButton() -> UIBarButtonItem{
        return UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewTask")
    }
    
    func addNewTask() {
        
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if let list = currentList {
            numRows = list.tasks.count
        }
        
        return numRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as! TaskTableViewCell
        
        let list = currentList.tasks[indexPath.row] as! Task
        cell.labelName?.text = list.name
        
        return cell
    }
}
