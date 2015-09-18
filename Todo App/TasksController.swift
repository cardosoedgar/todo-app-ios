//
//  TasksController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/15/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//

import UIKit

class TasksController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var textFieldAddTask: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var currentList: List!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    func setUpNavBar() {
        title = currentList.name
        navigationController?.navigationBarHidden = false
    }
    
    func addNewTask() {
        
    }

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if let list = currentList {
            numRows = list.tasks.count
        }
        
        return numRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as! TaskTableViewCell
        
        let list = currentList.tasks[indexPath.row] as! Task
        cell.labelName?.text = list.name
        
        return cell
    }
}
