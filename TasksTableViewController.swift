//
//  TasksTableViewController.swift
//  A table view controller for the list of tasks in a given task category for a given game
//  100 Percenter
//
//  Created by Igor Magun on 2018-08-11.
//  Copyright © 2018 Igor Magun. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    // Stores the category data and game name
    var categoryToDisplay: TaskCategory?
    var arrayOfTasks: [Task]?

    // Set the view title as the category title, initialize variables
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoryToDisplay?.name
        self.arrayOfTasks = categoryToDisplay?.taskBelongsToCategory?.array as? [Task]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // The number of sections is always 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Returns the number of tasks as the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Int((categoryToDisplay?.taskBelongsToCategory!.count)!)
        }
        else {
            return 0
        }
    }
    
    // Adds a section header where the number of tasks completed in the category is written
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let percentageCompleted = categoryToDisplay?.percentageCompleted
            let percentageFormatted = String(format: "%.2f", percentageCompleted!)
            let percentageString = percentageFormatted + "% complete"
            
            let completedTasks = String(categoryToDisplay!.completedTasks)
            let totalTasks = String(categoryToDisplay!.taskBelongsToCategory!.count)
            let tasksString = completedTasks + "/" + totalTasks + " tasks"

            return percentageString + ", " + tasksString
        }
        else {
            return nil
        }
    }

    // Sets the name of each cell as the name of a task, and adds a checkmark if the task is marked completed by the user
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        // Configure the cell...
        let taskIndex = indexPath.row
        let taskName = arrayOfTasks![taskIndex].name
        let taskCompleted = arrayOfTasks![taskIndex].completed
        
        cell.textLabel?.text = taskName
        
        if taskCompleted {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    // Marks the task as completed when the user taps on it, then reloads the table view to add a checkmark to it
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTaskIndex = indexPath.row
        let currentBoolean = arrayOfTasks![selectedTaskIndex].completed
        arrayOfTasks![selectedTaskIndex].completed = !currentBoolean
        
        // Update the number of completed tasks for the category and game, then update percentages
        if arrayOfTasks![selectedTaskIndex].completed {
            categoryToDisplay?.completedTasks += 1
            categoryToDisplay?.belongsToGame?.completedTasks += 1
        }
        else {
            categoryToDisplay?.completedTasks -= 1
            categoryToDisplay?.belongsToGame?.completedTasks -= 1
        }
        GameListTableViewController.updateAllPercentages(categoryToUpdate: categoryToDisplay!, gameToUpdate: (categoryToDisplay?.belongsToGame)!)
        
        // Save to CoreData, then reload the data for the table view
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.tableView.reloadData()
    }
}
