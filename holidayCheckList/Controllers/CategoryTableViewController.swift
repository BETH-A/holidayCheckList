//
//  CategoryTableViewController.swift
//  holidayCheckList
//
//  Created by Mary Arnold on 11/24/20.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryTableViewController: SwipeTableViewController {
    
    //Initialzed  new Realm
    let realm = try! Realm()
    
    //Changed from array to a collection of results
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loads all categories we have
        loadCategories()
        
        tableView.separatorStyle = .none
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controll does not exist.")
            
        }
        
        navBar.backgroundColor = UIColor(named: "862A5C")
        
        
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if categories is nil then return 1 row
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //taps into the cell from the Super Class
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(named: category.categoryColor) else {fatalError()}
            
            cell.backgroundColor = categoryColor
        
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    //when we click on any cell a segue is created to take us to a VC of the selected cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    
    //creates new instance of destinatinVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destimationVC = segue.destination as! ViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destimationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods - saveData/loadData
    func save(catergory: Category) {
        //Commit items to have to Realm DB
        do {
            try realm.write() {
                realm.add(catergory)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        //reloads List to show the added category
        self.tableView.reloadData()
    }
    
    //Reading DB so don't have to call context & saveItems - with internal & external paramater with default values
    func loadCategories() {
        
        //Set catergories to fetches content from DB
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories - using Category Intity
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once user clicked addCategoryButton on our alert
            
            //add new category to List
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(catergory: newCategory)
        }
        
        //activate alert popup
        alert.addAction(action)
        
        //add text field to alert
        alert.addTextField { (field) in
            field.placeholder = "Create a new category"
            
            //extending scope of alertTextField to addButtonPressed
            textField = field
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
