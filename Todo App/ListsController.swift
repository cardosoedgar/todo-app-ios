//
//  ListsController.swift
//  Todo App
//
//  Created by Edgar Cardoso on 8/31/15.
//  Copyright (c) 2015 Edgar Cardoso. All rights reserved.
//
import CoreData
import UIKit
import Alamofire

class ListsController: UIViewController, UITableViewDataSource,
                    UITableViewDelegate, UITextFieldDelegate, LogoutProtocol, UpdateTaskCountProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldAddItem: UITextField!
    
    var coreDataStack : CoreDataStackManager!
    var currentUser : User!
    var database = UserDefaultsDatabase()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
        setUpTextField()
        setTapAnyWhereToDismissKeyboard()
        addTextFieldObservers()
        
        if currentUser == nil {
            loadUser()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeTextFieldObservers()
    }
    
    // MARK: - Core Methods
    func loadUser() {
        currentUser = database.getUser(coreDataStack.context)
        tableView.reloadData()
    }
    
    func addNewList() {
        let listName = textFieldAddItem.text!
        clearTextField()
        
        if listName == "" {
            dismissKeyboard()
            return
        }
        
        let params = ["name" : listName]
        let list = currentUser.addList(params, context: coreDataStack.context)
        coreDataStack.saveContext()
        
        addListToTableViewLastPosition()
        scrollTableViewToLastPosition()
        
        if !database.isUserLoggedIn() {
            return
        }
        
        addListToCloud(params, andUpdateList: list)
    }
    
    func addListToCloud(params: [String:String], andUpdateList list:List) {
        Alamofire.request(.POST, "http://localhost:8080/api/list", parameters: params, headers: database.getHeader())
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
                    
                    if let listDict = result.value?.valueForKey("list") as? NSDictionary {
                        list.updateId(listDict)
                        self.coreDataStack.saveContext()
                    }
                }
        }
    }

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if let user = currentUser {
            numRows = user.lists.count
        }
        
        return numRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListsTableViewCell
        
        let list = currentUser.lists[indexPath.row] as! List
        cell.labelName?.text = list.name
        let tasksNumberLabel = NSLocalizedString("tasksLabel", comment: "")
        cell.labelNumberTasks?.text = "\(list.tasks.count) \(tasksNumberLabel)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tasksVC = storyboard?.instantiateViewControllerWithIdentifier("TasksController") as! TasksController
        let currentList = currentUser.lists[indexPath.row] as! List
        tasksVC.delegate = self
        tasksVC.currentList = currentList
        tasksVC.coreDataStack = coreDataStack
        navigationController?.pushViewController(tasksVC, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { (action, index) -> Void in
            print("delete action")
        }
        delete.backgroundColor = UIColor.redColor()
        
        let rename = UITableViewRowAction(style: .Normal, title: "Edit") { (action, index) -> Void in
            print("edit")
        }
        rename.backgroundColor = UIColor.orangeColor()
        
        let markDone = UITableViewRowAction(style: .Normal, title: "Done") { (action, index) -> Void in
            print("Done")
        }
        markDone.backgroundColor = UIColor(red: 255/255, green: 184/255, blue: 162/255, alpha: 1)
        
        return [delete, rename, markDone]
    }
    
    // MARK: - Logout Protocol
    func didLogout() {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    //MARK: - Setup Navigation Bar
    func setUpNavBar() {
        title = NSLocalizedString("listViewTitle", comment: "")
        navigationController?.navigationBarHidden = false
        addNavBarButton()
    }
    
    func addNavBarButton() {
        let settingsButton = createSettingsButton()
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    func createSettingsButton() -> UIBarButtonItem {
        let icon = UIImage(named: "settings_icon")
        return UIBarButtonItem(image: icon, style: .Plain, target: self, action: "settingsButtonPressed")
    }
    
    //MARK: - UITextFieldProtocol
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addNewList()
        return true
    }
    
    //MARK: - UpdateTaskCountProtocol
    func updateTaskCountInList(list: List) {
        var index = 0
        for var i=0; i < currentUser.lists.count; i++ {
            let aux = currentUser.lists[i] as! List
            if list.id == aux.id {
                index = i
            }
        }
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)],
                                                                withRowAnimation: .None)
    }
    
    //MARK: - Helper Methods
    func clearTextField() {
        textFieldAddItem.text = ""
    }
    
    func setUpTextField() {
        textFieldAddItem.delegate = self
        textFieldAddItem.placeholder = NSLocalizedString("addListPlaceholder", comment: "")
    }
    
    func addTextFieldObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeTextFieldObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setTapAnyWhereToDismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        textFieldAddItem.resignFirstResponder()
    }
    
    func settingsButtonPressed() {
        if database.isUserLoggedIn() {
            openSettingsController()
        } else {
            openLoginController()
        }
    }
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func scrollTableViewToLastPosition() {
        let listCount = self.currentUser.lists.count
        if listCount > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.currentUser.lists.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func addListToTableViewLastPosition() {
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.currentUser.lists.count - 1, inSection: 0)],
            withRowAnimation: .Automatic)
    }
    
    //MARK: - Navigation
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
