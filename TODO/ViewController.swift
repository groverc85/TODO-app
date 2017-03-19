//
//  ViewController.swift
//  TODO
//
//  Created by Grover Chen on 3/18/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    enum SortType: String {
        case detail = "detail"
        case createdAt = "createdAt"
        case status = "status"
    }
    enum SortDirection {
        case asc
        case desc
    }
    
    var currentCreateAction:UIAlertAction!
    var searchQuery = ""
    var sortType = SortType.detail
    var sortDirection = SortDirection.asc

    let realm = try! Realm()
    var todoList: Results<TodoItem> {
        get {
            // All Objects
            var objects = realm.objects(TodoItem.self)
            
            // Add Search Query
            if (!searchQuery.isEmpty) {
                objects = objects.filter("detail CONTAINS '\(searchQuery.lowercased())'")
            }
            // Add Sorting
            var ascending = false
            if sortDirection == .asc {
                ascending = true
            }
            objects = objects.sorted(byKeyPath: sortType.rawValue, ascending: ascending)
            return objects
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = todoList[indexPath.row]
        
        cell.textLabel!.text = item.detail
        cell.detailTextLabel!.text = "\(item.status)"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Change priority of each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = todoList[indexPath.row]

        try! self.realm.write({
            item.status += 1
        })
        
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("todoList: " + String(todoList.count))
        return todoList.count
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion
            let taskToBeDeleted = self.todoList[indexPath.row]
            
            try! self.realm.write{
                self.realm.delete(taskToBeDeleted)
            }
            self.tableView.reloadData()
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Edit
            let taskToBeUpdated = self.todoList[indexPath.row]
            self.displayAlertToUpdateTask(taskToBeUpdated)
        }
        return [deleteAction, editAction]
    }
    
    func displayAlertToUpdateTask(_ updatedTask:TodoItem!){
        let title = "Update Tasks List"
        let doneTitle = "Update"
        
        let alertController = UIAlertController(title: title, message: "Update task", preferredStyle: UIAlertControllerStyle.alert)
        
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            let taskName = alertController.textFields?.first?.text
            // update task
            try! self.realm.write{
                updatedTask.detail = taskName!
                updatedTask.createdAt = NSDate()
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(ViewController.taskNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.detail
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }

    // add certain row
    @IBAction func addNew(_ sender: Any) {
        let alertController : UIAlertController = UIAlertController(title: "New Todo", message: "What do you plan to do?", preferredStyle: .alert)
        
        alertController.addTextField {
            (UITextField) in
        }

        let action_cancel = UIAlertAction.init(title: "Cancel", style: .cancel) {
            (UIAlertAction) -> Void in
        }
        
        alertController.addAction(action_cancel)
        
        let action_add = UIAlertAction.init(title: "Add", style: .default) {
            (UIAlertAction) -> Void in
            
            let textField_todo = (alertController.textFields?.first)! as UITextField
            
            print("You entered \(textField_todo.text)")
            
            let todoItem = TodoItem()
            todoItem.detail = textField_todo.text!
            todoItem.status = 0
            
            try! self.realm.write({
                self.realm.add(todoItem)
                self.tableView.reloadData()
            })
        }
        
        alertController.addAction(action_add)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            // A-Z
            sortType = .detail
            sortDirection = .asc
        }
        else if sender.selectedSegmentIndex == 1 {
            // date
            sortType = .createdAt
            sortDirection = .desc
        }
        else {
            sortType = .status
            sortDirection = .desc
        }
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("loading....")
        tableView.reloadData()
        print ("loading completed")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }


}

