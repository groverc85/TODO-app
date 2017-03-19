//
//  ViewController.swift
//  TODO
//
//  Created by Grover Chen on 3/18/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate {

    let realm = try! Realm()
    
    var todoList: Results<TodoItem>!
    var filteredTodoList: Results<TodoItem>!
    
    var currentCreateAction:UIAlertAction!
    
    override func viewWillAppear(_ animated: Bool) {
        readTasksAndUpdateUI()
    }
    
    func readTasksAndUpdateUI(){
        todoList = realm.objects(TodoItem.self)
        self.tableView.setEditing(false, animated: true)
        self.tableView.reloadData()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var item = todoList[indexPath.row]
        
        if tableView == searchDisplayController?.searchResultsTableView {
//            if filteredTodoList != nil{
                item = filteredTodoList[indexPath.row]
//            }
        }
        
        cell.textLabel!.text = item.detail
        cell.detailTextLabel!.text = "\(item.status)"
        
        return cell
    }
    
    // change priority of each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = todoList[indexPath.row]
        
        if tableView == searchDisplayController?.searchResultsTableView {
            item = filteredTodoList[indexPath.row]
        }

        try! self.realm.write({
            item.status += 1
        })
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == searchDisplayController?.searchResultsTableView {
            if filteredTodoList == nil
            {
                return 0
            }
            else
            {
                print ("filtseredTodoList" + String(filteredTodoList.count))
                return filteredTodoList.count
            }
        }
        else {
            print("todoList: " + String(todoList.count))
            return todoList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion
            var listToBeDeleted = self.todoList[indexPath.row]
            
            if tableView == self.searchDisplayController?.searchResultsTableView {
                listToBeDeleted = self.filteredTodoList[indexPath.row]
            }
            
            try! self.realm.write{
                self.realm.delete(listToBeDeleted)
                self.readTasksAndUpdateUI()
            }
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Edit
            var listToBeUpdated = self.todoList[indexPath.row]
            
            if tableView == self.searchDisplayController?.searchResultsTableView {
                listToBeUpdated = self.filteredTodoList[indexPath.row]
            }
            
            self.displayAlertToAddTaskList(listToBeUpdated)
            
        }
        return [deleteAction, editAction]
    }
    
    
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        
        
//        let searchPredicate = NSPredicate(format: "detail CONTAINS[c] %@", searchString!)
//        let searchPredicate = NSPredicate()
        
//        filteredTodoList = realm.objects(TodoItem.self).filter(searchPredicate)
        

        var todos = realm.objects(TodoItem.self)
        todos = todos.filter("detail CONTAINS '\(searchString)'")
        
//        objects = objects.filter("text CONTAINS '\(searchQuery)'")
        
        print("searchDisplayController\n")

        return true
    }
    

    func displayAlertToAddTaskList(_ updatedList:TodoItem!){
        let title = "Update Tasks List"
        let doneTitle = "Update"
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: UIAlertControllerStyle.alert)
        
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            // update mode
            try! self.realm.write{
                updatedList.detail = listName!
                updatedList.createdAt = NSDate()
                self.readTasksAndUpdateUI()
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.detail
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    func listNameFieldDidChange(_ textField:UITextField){
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
//                self.tableView.insertRows(at: [IndexPath.init(row: self.todoList.count-1, section: 0)], with: .automatic)
                self.readTasksAndUpdateUI()
            })
        }
        
        alertController.addAction(action_add)
        present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            // A-Z
            self.todoList = self.todoList.sorted(byKeyPath: "detail")
        }
        else if sender.selectedSegmentIndex == 1 {
            // date
            self.todoList = self.todoList.sorted(byKeyPath: "createdAt", ascending:false)
        }
        else {
            self.todoList = self.todoList.sorted(byKeyPath: "status", ascending:false)
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


}

