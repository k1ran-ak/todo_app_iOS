//
//  CategoryViewControllers.swift
//  ToDoCoreData
//
//  Created by Kiran on 06/10/2021.
//  Copyright © 2021 Kiran. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewControllers: UITableViewController {
    var tasks = [Tasks]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // To delete from core data we need to fetch the object we are looking for
            //
            if let name = tasks[indexPath.row].name {
                let request: NSFetchRequest<Tasks> = Tasks.fetchRequest()
                request.predicate = NSPredicate(format: "name MATCHES %@", name)

                if let tasks = try? context.fetch(request) {
                    for task in tasks {
                        context.delete(task)
                    }
                    // Save the context so our changes persist and We also have to delete the local copy of the data
                    //
                    self.tasks.remove(at: indexPath.row)
                    saveTasks()
                    tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration.init(actions: [
            UIContextualAction.init(style: .normal, title: "Edit", handler: { (_, view, _) in
                self.editRow(indexPath: indexPath)
            })
        ])
    }
    

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ToDoListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedTask = tasks[indexPath.row]
            }
        }
    }

    func editRow(indexPath : IndexPath) {
        let alert = UIAlertController.init(title: "Edit", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter new value"
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            
            if let text = alert.textFields?.first?.text {
                if let name = self.tasks[indexPath.row].name {
                        let request: NSFetchRequest<Tasks> = Tasks.fetchRequest()
                        request.predicate = NSPredicate(format: "name MATCHES %@", name)
                        //request.predicate = NSPredicate(format: "name==\(category)")

                    if let tasks = try? self.context.fetch(request) {
                            for task in tasks {
                                task.name = text
                            }
                        self.saveTasks()
                        self.tableView.reloadData()
                        }
                    }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(save)
        alert.addAction(cancel)
    }

    
    @IBAction func addBarButonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)

              alert.addTextField { textField in
                  textField.placeholder = "Category placeholder"
              }

              let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
              let action = UIAlertAction(title: "Add Task", style: .default) { _ in
                  if let textField = alert.textFields?.first {
                      if textField.text != "", let text = textField.text {
                          let newTask = Tasks(context: self.context)
                          newTask.name = text

                          self.tasks.append(newTask)
                          self.saveTasks()
                          self.tableView.reloadData()
                      }
                  }
              }
        
              alert.addAction(action)
              alert.addAction(cancel)

              self.present(alert, animated: true)
    }
    
    
    private func loadTasks(with request: NSFetchRequest<Tasks> = Tasks.fetchRequest()) {
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    private func saveTasks() {
           do {
               try context.save()
           } catch {
               print("Error saving context: \(error)")
           }
       }
}
