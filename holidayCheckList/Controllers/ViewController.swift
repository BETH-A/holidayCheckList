//
//  ViewController.swift
//  holidayCheckList
//
//  Created by Mary Arnold on 11/24/20.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ViewController: SwipeTableViewController {
    
    public let realm = try! Realm()
    var todoItems: Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            //Retrieve results for the category selected from Realm DB
            loadItems()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
         tableView.separatorStyle = .none
    
        //set Search Bar Delegate from Main.storyboard if app not created using Core Data template
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.categoryColor {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controll does not exist.")}
            
            if let navBarColor = UIColor(named: colorHex) {
                navBar.backgroundColor = navBarColor
                
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
               navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBar.barTintColor = navBarColor
            }
   
            
        }
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //taps into the cell from the Super Class
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            if let color = UIColor(named: selectedCategory!.categoryColor)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
            //setting accesspryType using Ternary operator ==>
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods for cell clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write{
                    
                    //                    //to delete item from Realm
                    //                    realm.delete(item)
                    
                    //Adding/Removing Checkmarks on cell clicked by setting it to opposite of what it was
                    item.done = !item.done
                }
            } catch {
                print("Error adding/removing checkmark, \(error)")
            }
        }
        
        tableView.reloadData()
        
        //highlights selected cell for just a sec & then returns to background color
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once user clicked addItemButton on our alert
            
            //add new item to List
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        //add text field to alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            
            //extending scope of alertTextField to addButtonPressed
            textField = alertTextField
        }
        
        //activate alert popup
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    //Reading DB so don't have to call context & saveItems - with internal & external paramater with default values
    func loadItems() {
        //must specify the data output type
        //sorted results by title
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
       func updateModel(at indexPath: IndexPath) {
           
           if let itemForDeletion = self.todoItems?[indexPath.row] {
               do {
                   try self.realm.write {
                       self.realm.delete(itemForDeletion)
                   }
               } catch {
                   print("Error deleting category, \(error)")
               }
           }
       }
}


//MARK: - Search Bar Methods
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
