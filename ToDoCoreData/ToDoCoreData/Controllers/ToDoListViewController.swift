//
//  ToDoListViewController.swift
//  ToDoCoreData
//
//  Created by Kiran on 06/10/2021.
//  Copyright © 2021 Kiran. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var selectedTask: Tasks? {
           didSet {
               self.title = selectedTask?.name
           }
       }
       
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       var itemArray = [Item]()
        let titleForRows = ["Text", "Audio", "Image"]
    override func viewDidLoad() {
        super.viewDidLoad()
         loadItems()
        self.tableView.register(UINib(nibName: "TodoListTVC", bundle: nil), forCellReuseIdentifier: "TodoListTVC")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListTVC", for: indexPath) as! TodoListTVC
        cell.titleLabel.text =  itemArray[indexPath.row].title != nil ? titleForRows[0] : itemArray[indexPath.row].audio != nil ? titleForRows[1] : titleForRows[2]
        cell.valueLabel?.text = itemArray[indexPath.row].title ?? itemArray[indexPath.row].audio ?? itemArray[indexPath.row].image
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // deselect
            tableView.deselectRow(at: indexPath, animated: true)
    //        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            itemArray[indexPath.row].done.toggle()
            self.saveItems()
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // To delete from core data we need to fetch the object we are looking for
            guard let taskName = selectedTask?.name else {return}
            if  let itemName = itemArray[indexPath.row].title {
                deleteData(taskName: taskName, itemName: itemName, itemType: "title", index: indexPath.row)
            } else if let itemAudio = itemArray[indexPath.row].audio {
                deleteData(taskName: taskName, itemName: itemAudio, itemType: "audio", index: indexPath.row)
            } else if let itemImage = itemArray[indexPath.row].image {
                deleteData(taskName: taskName, itemName: itemImage, itemType: "image", index: indexPath.row)
            }
        }
    }


    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }

    
    //MARK: - Button Actions
    @IBAction func addItemPressed(_ sender: Any) {
        if itemArray.count <= 3 {
        let alert = UIAlertController(title: "Add New Data", message: "", preferredStyle: .actionSheet)


        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        let action = UIAlertAction(title: "Add Text", style: .default) { _ in
            
            let alert2 = UIAlertController(title: "Enter Text", message: "", preferredStyle: .alert)

            alert2.addTextField { textField in
                textField.placeholder = "Your task"
            }
            let action2 = UIAlertAction(title: "Add Text", style: .default) { _ in
                
                if let textField = alert2.textFields?.first {
                    if textField.text != "", let title = textField.text {
                        let newItem = Item(context: self.context)
                        newItem.title = title
                        newItem.done = false
                        newItem.parentCategory = self.selectedTask
                        self.itemArray.append(newItem)
                        self.tableView.reloadData()
                        self.saveItems()
                    }
                }
            }
            alert2.addAction(action2)
            alert2.addAction(cancel)
            
            self.present(alert2, animated: true)
        }
        
        let imgAction = UIAlertAction(title: "Add Image", style: .default) { _ in
            
            let alert2 = UIAlertController(title: "Enter Image Url", message: "", preferredStyle: .alert)

            alert2.addTextField { textField in
                textField.placeholder = "Your image url"
            }
            let action2 = UIAlertAction(title: "Add Image", style: .default) { _ in
                
                if let textField = alert2.textFields?.first {
                    if textField.text != "", let text = textField.text {
                        let newItem = Item(context: self.context)
                        newItem.image = text
                        newItem.done = false
                        newItem.parentCategory = self.selectedTask
                        self.itemArray.append(newItem)
                        self.tableView.reloadData()
                        self.saveItems()
                    }
                }
            }
            alert2.addAction(action2)
            alert2.addAction(cancel)
            
            self.present(alert2, animated: true)
        }
        
        
        let audioAction = UIAlertAction(title: "Add Audio", style: .default) { _ in
            
            let alert2 = UIAlertController(title: "Enter Audio Url", message: "", preferredStyle: .alert)

            alert2.addTextField { textField in
                textField.placeholder = "Your Audio url"
            }
            let action2 = UIAlertAction(title: "Add Audio", style: .default) { _ in
                
                if let textField = alert2.textFields?.first {
                    if textField.text != "", let text = textField.text {
                        let newItem = Item(context: self.context)
                        newItem.audio = text
                        newItem.done = false
                        newItem.parentCategory = self.selectedTask
                        self.itemArray.append(newItem)
                        self.tableView.reloadData()
                        self.saveItems()
                    }
                }
            }
            alert2.addAction(action2)
            alert2.addAction(cancel)
            
            self.present(alert2, animated: true)
        }

        alert.addAction(action)
        alert.addAction(imgAction)
        alert.addAction(audioAction)
        alert.addAction(cancel)

        self.present(alert, animated: true)
        } else {
            
        }
    }
    
//MARK: - CoreData Functions
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
           if let name = selectedTask?.name {
               let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)

               if let additionalPredicate = predicate {
                   request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
               } else {
                   request.predicate = categoryPredicate
               }

               do {
                   itemArray = try context.fetch(request)
               } catch {
                   print("Error fetching data from context: \(error)")
               }
               tableView.reloadData()
           }
       }
        
        
        private func saveItems() {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    
    private func deleteData(taskName : String, itemName : String,itemType: String,index : Int) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let taskPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", taskName)
        let itemPredicate = NSPredicate(format: "\(itemType) MATCHES %@", itemName)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [taskPredicate, itemPredicate])
        if let results = try? context.fetch(request) {
            for object in results {
                context.delete(object)
            }
            itemArray.remove(at: index)
            saveItems()
            tableView.reloadData()
        }
    }
}

//extension ToDoListViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.isEmpty == true {
//            // User just cleared the search bar reload everything so their previous search is gone
//            //
//            loadItems()
//            searchBar.resignFirstResponder() // останавливаем и выходим из searchBar
//        } else {
//            let request: NSFetchRequest<Item> = Item.fetchRequest()
//            // [cd] makes the search case and diacritic insensitive http://nshipster.com/nspredicate/
//            //
//            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//            loadItems(with: request, predicate: searchPredicate)
//
//            tableView.reloadData()
//        }
//    }
//}
