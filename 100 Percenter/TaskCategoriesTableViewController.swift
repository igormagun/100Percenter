//
//  TaskCategoriesTableViewController.swift
//  A table view controller for the list of a chosen game's task categories
//  100 Percenter
//
//  Created by Igor Magun on 2018-08-03.
//  Copyright © 2018 Igor Magun. All rights reserved.
//

import UIKit

class TaskCategoriesTableViewController: UITableViewController {
    
    // Variables for the game we are displaying, and the category a user selects, if applicable
    var selectedGame: Game?
    var selectedCategoryIndex: Int?
    var arrayOfCategories: [TaskCategory]?

    // Sets the title of the view as the game name, set up the array of categories to load names from
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedGame?.name
        self.arrayOfCategories = selectedGame?.categoryBelongsToGame?.array as? [TaskCategory]
    }
    
    // Overrides the viewWillAppear function so that the game progress header is updated when returning from a task category
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Specifies the number of sections - always 1 in this view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Adds a section header where the percentage of the game completed is written
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let percentageCompleted = selectedGame?.percentageCompleted
            let percentageFormatted = String(format: "%.2f", percentageCompleted!)
            let percentageString = percentageFormatted + "% complete"
            
            let completedTasks = String(selectedGame!.completedTasks)
            let totalTasks = String(selectedGame!.taskBelongsToGame!.count)
            let tasksString = completedTasks + "/" + totalTasks + " tasks"
            
            return percentageString + ", " + tasksString
        }
        else {
            return nil
        }
    }

    // Specifies the number of rows as the number of categories
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selectedGame!.categoryBelongsToGame!.count
        }
        else {
            return 0
        }
    }

    // Retrieve the name and completion status of each category to label each row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let categoryIndex = indexPath.row
        let category = arrayOfCategories![categoryIndex]
        
        // Configure the cell...
        cell.textLabel?.text = category.name
        
        if category.completedTasks == category.taskBelongsToCategory!.count {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // Prepare for a segue to a new controller by storing data for the selected category
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.row
        performSegue(withIdentifier: "CategorySelected", sender: self)
    }
    
    // MARK: - Navigation

    // Sends the selected category to TasksTableViewController so that we can display all tasks in the category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameScreen = segue.destination as? TasksTableViewController {
            gameScreen.categoryToDisplay = self.arrayOfCategories?[selectedCategoryIndex!]
        }
    }
    

}
