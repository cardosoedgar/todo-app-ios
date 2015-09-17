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

class ListsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LogoutProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldAddItem: UITextField!
    
    var coreDataStack : CoreDataStackManager!
    var currentUser : User!
    var database = UserDefaultsDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
        setUpTextField()
        
        if currentUser == nil {
            loadUser()
        }
    }
    
    // MARK: - UI Componentes
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addNewList()
        return true
    }
    
    func setUpTextField() {
        textFieldAddItem.delegate = self
        textFieldAddItem.placeholder = NSLocalizedString("addListPlaceholder", comment: "")
        addTextFieldObservers()
    }
    
    func addTextFieldObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissKeyboard() {
        textFieldAddItem.resignFirstResponder()
    }
    
    func loadUser() {
        currentUser = database.getUser(coreDataStack.context)
        tableView.reloadData()
    }
    
    func setUpNavBar() {
        title = NSLocalizedString("listViewTitle", comment: "")
        navigationController?.navigationBarHidden = false
        addNavBarButtons()
    }
    
    func addNavBarButtons() {
        let settingsButton = createSettingsButton()
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    func createSettingsButton() -> UIBarButtonItem {
        let icon = UIImage(named: "settings_icon")
        return UIBarButtonItem(image: icon, style: .Plain, target: self, action: "checkUserIsLoggedIn")
    }
    
    func addNewList() {
        let listName = textFieldAddItem.text!
        clearTextField()
        
        if listName == "" {
            dismissKeyboard()
            return
        }
        
        let list = List.listFromJSON(["name" : listName] as NSDictionary, andContext: self.coreDataStack.context)
        let lists = self.currentUser.lists.mutableCopy() as! NSMutableOrderedSet
        lists.addObject(list)
        self.currentUser.lists = lists as NSOrderedSet
        self.coreDataStack.saveContext()
        
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.currentUser.lists.count - 1, inSection: 0)],
            withRowAnimation: .Automatic)
        self.scrollTableViewToLastPosition()
        
        let params = ["name" : listName]
        let headers = ["x-access-token" : database.getToken()!]
        Alamofire.request(.POST, "http://localhost:8080/api/list", parameters: params, headers: headers)
            .responseJSON { (_, _, result) -> Void in
                if result.isFailure {
                    self.createAlertWithMessage("Can't connect to the server. Check your internet connection")
                    return
                }

                let JSON = result.value
                
                if let success = JSON?.valueForKey("success") as? Bool {
                    if !success {
                        let message = JSON?.valueForKey("message") as? String
                        self.createAlertWithMessage(message)
                        return
                    }
                    
                    if let listDict = JSON?.valueForKey("list") as? NSDictionary {
                        list.id = listDict["id"] as? NSNumber
                        self.coreDataStack.saveContext()
                    }
                }
        }

    }
    
    func createAlertWithMessage(message: String?) {
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message!
        alert.addButtonWithTitle("Ok")
        alert.show()
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
        dismissKeyboard()
        let settingsVC = storyboard?.instantiateViewControllerWithIdentifier("SettingsController") as! SettingsController
        settingsVC.delegate = self
        settingsVC.coreDataStack = coreDataStack
        presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    func openLoginController() {
        dismissKeyboard()
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
        let tasksLabel = NSLocalizedString("tasksLabel", comment: "")
        cell.labelNumberTasks?.text = "\(list.tasks.count) \(tasksLabel)" 
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tasksVC = storyboard?.instantiateViewControllerWithIdentifier("TasksController") as! TasksController
        tasksVC.currentList = currentUser.lists[indexPath.row] as! List
        navigationController?.pushViewController(tasksVC, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dismissKeyboard()
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
    
    func clearTextField() {
        textFieldAddItem.text = ""
    }
    
    func scrollTableViewToLastPosition() {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.currentUser.lists.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
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
