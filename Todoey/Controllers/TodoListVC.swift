//
//  TodoListVC.swift
//  Todoey
//
//  Created by ClementM on 10/01/2018.
//  Copyright © 2018 ClementM. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListVC: SwipeTableVC {

    let realm = try! Realm()
    
    // MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Variables
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.bgColor else { fatalError() }
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }

    
    // MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHex: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.bgColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // Realm deletion example
                    // realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let currentCategoy = self.selectedCategory {
                do {
                    try self.realm.write {
                        // newItem.done default value is false, no need to set it (see Item class)
                        
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        
                        // Append item to category it belongs to
                        currentCategoy.items.append(newItem)
                    }
                } catch {
                    print("Error saving item: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Model Manipulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        self.tableView.reloadData()
    }
    
    // Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
}

//MARK: - Search bar methods
extension TodoListVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
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

