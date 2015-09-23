//
//  TasksController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 9/15/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import Alamofire
import UIKit

class TasksController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textFieldAddTask: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var database = UserDefaultsDatabase()
    var currentList: List!
    var coreDataStack: CoreDataStackManager!
    var delegate: UpdateTaskCountProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setTapAnyWhereToDismissKeyboard()
        setUpTextField()
        setUpNavBar()
    }
    
    func setUpNavBar() {
        title = currentList.name
        navigationController?.navigationBarHidden = false
    }
    
    func addNewTask() {
        let taskName = textFieldAddTask.text!
        clearTextField()
        
        if taskName == "" {
            dismissKeyboard()
            return
        }
        
        let params = ["name" : taskName]
        let task = currentList.addTask(params, context: coreDataStack.context)
        coreDataStack.saveContext()
        
        addTaskToTableViewLastPosition()
        scrollTableViewToLastPosition()
        delegate.updateTaskCountInList(currentList)
        
        if !database.isUserLoggedIn() {
            return
        }
        
        addTaskToCloud(params, andUpdateList: task)
    }
    
    func addTaskToCloud(params: [String:String], andUpdateList task:Task) {
        let url = "http://localhost:8080/api/list/\(currentList.id!)/task"
        Alamofire.request(.POST, url, parameters: params, headers: database.getHeader())
            .responseJSON { (_, _, result) -> Void in
                if result.isFailure {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
                
                if let success = result.value?.valueForKey("success") as? Bool {
                    if !success {
                        let message = result.value?.valueForKey("message") as? String
                        self.createAlertWithMessage(message)
                        return
                    }
                    
                    if let taskDict = result.value?.valueForKey("task") as? NSDictionary {
                        task.updateId(taskDict)
                        self.coreDataStack.saveContext()
                    }
                }
        }
    }
    
    func markTaskDoneAtCloud(task: Task) {
        let url = "http://localhost:8080/api/list/\(currentList.id!)/task/\(task.id!)"
        Alamofire.request(.PUT, url, parameters: ["done":task.done], headers: database.getHeader())
            .responseJSON { (_,_, result) -> Void in
                if result.isFailure {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
        }
    }
    
    func deleteTaskAtCloud(task: Task) {
        let url = "http://localhost:8080/api/list/\(currentList.id!)/task/\(task.id!)"
        Alamofire.request(.DELETE, url, headers: database.getHeader())
            .responseJSON { (_,_, result) -> Void in
                if result.isFailure {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }
        }

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
        
        if(list.done) {
            cell.markAsDone()
        } else {
            cell.markAsUndone()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let task = self.currentList.tasks[indexPath.row] as! Task
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { (action, index) -> Void in
            if self.database.isUserLoggedIn() {
                self.deleteTaskAtCloud(task)
            }
            
            self.deleteTask(task)
            self.coreDataStack.saveContext()
            self.deleteRowAtIndex(indexPath)
            self.delegate.updateTaskCountInList(self.currentList)
        }
        delete.backgroundColor = UIColor.redColor()
        
        let rename = UITableViewRowAction(style: .Normal, title: "Edit") { (action, index) -> Void in
            
        }
        rename.backgroundColor = UIColor.orangeColor()
        
        let markDone = UITableViewRowAction(style: .Normal, title: markDoneTitle(task)) { (action, index) -> Void in
            if task.done {
                self.markTaskUndone(task)
            } else {
                self.markTaskDone(task)
            }
            
            self.coreDataStack.saveContext()
            self.reloadRowAtIndex(indexPath)
        }
        markDone.backgroundColor = UIColor(red: 255/255, green: 184/255, blue: 162/255, alpha: 1)
        
        return [delete, rename, markDone]
    }
    
    //MARK: - Text Field Helpers
    func setUpTextField() {
        textFieldAddTask.delegate = self
        textFieldAddTask.placeholder = NSLocalizedString("addListPlaceholder", comment: "")
        addTextFieldObservers()
    }
    
    func addTextFieldObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setTapAnyWhereToDismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - Helper Methods
    func markTaskUndone(task: Task) {
        task.markUndone()
        if database.isUserLoggedIn() {
            self.markTaskDoneAtCloud(task)
        }
    }
    
    func markTaskDone(task: Task) {
        task.markAsDone()
        if database.isUserLoggedIn() {
            self.markTaskDoneAtCloud(task)
        }
    }
    
    func deleteTask(task: Task) {
        let tasks = currentList.tasks as! NSMutableOrderedSet
        tasks.removeObject(task)
        currentList.tasks = tasks as NSOrderedSet
        coreDataStack.context.deleteObject(task)
    }
    
    func deleteRowAtIndex(indexPath: NSIndexPath) {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func reloadRowAtIndex(indexPath: NSIndexPath) {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func markDoneTitle(task: Task) -> String{
        if task.done {
            return "Undone"
        } else {
            return "Done"
        }
    }
    
    func clearTextField() {
        textFieldAddTask.text = ""
    }
    
    func dismissKeyboard() {
        textFieldAddTask.resignFirstResponder()
    }
    
    func scrollTableViewToLastPosition() {
        let listCount = currentList.tasks.count
        if listCount > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: currentList.tasks.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func addTaskToTableViewLastPosition() {
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: currentList.tasks.count - 1, inSection: 0)],
            withRowAnimation: .Automatic)
    }
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    //MARK: - UITextFieldProtocol
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addNewTask()
        return true
    }
    
    //MARK: - TableView Keyboard Animations
    func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var contentInsets : UIEdgeInsets
            
            if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            } else {
                contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.width, right: 0)
            }
            
            let rate = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            UIView.animateWithDuration(rate.doubleValue) {
                self.tableView.contentInset = contentInsets
                self.tableView.scrollIndicatorInsets = contentInsets
            }
            
            self.scrollTableViewToLastPosition()
        }
    }
    
    func keyboardWillHide(note: NSNotification) {
        let rate = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        UIView.animateWithDuration(rate.doubleValue) {
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
}
