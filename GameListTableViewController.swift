//
//  GameListTableViewController.swift
//  A table view controller for the game list
//  100 Percenter
//
//  Created by Igor Magun on 2018-07-20.
//  Copyright © 2018 Igor Magun. All rights reserved.
//

import UIKit
import CoreData

class GameListTableViewController: UITableViewController {
    
    // Various strings used to access properties in UserDefaults, CoreData, or JSON - stored here for easy reuse
    let storedGameListVersionKey = "defaultListVersion"
    
    let nameKey = "name"
    let iconKey = "icon"
    let largeIconKey = "largeIcon"
    let listVersionKey = "listVersion"
    let uniqueIDKey = "uniqueID"
    let categoriesKey = "taskCategories"
    let tasksKey = "tasks"
    let completedKey = "completed"
    let defaultListName = "DefaultGameList"
    
    let coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let gameEntity = "Game"
    let categoryEntity = "TaskCategory"
    let taskEntity = "Task"
    
    // Variables to store the game list, as well as a variable for the index of the game a user selects
    var listOfGames: GameList?
    var selectedGameIndex: Int?
    
    // Function that creates the user game list on first run, using the default game list
    private func loadDefaultGameData() {
        do {
            if let defaultFile = Bundle.main.url(forResource: defaultListName, withExtension: "json") {
                let data = try Data(contentsOf: defaultFile)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                var defaultListVersion: Double = 0
                
                // Iterate through the JSON array to add each game
                if var array = json as? [Dictionary<String, Any>] {
                    listOfGames = GameList(context: coreDataContext)
                    // Store the list version, then remove it from the array, before we iterate
                    defaultListVersion = array[0][listVersionKey] as! Double
                    array.remove(at: 0)
                    
                    for game in array {
                        try addNewGame(gameDictionary: game)
                    }
                }
                // Save the database now that we're done
                if coreDataContext.hasChanges {
                    try coreDataContext.save()
                }
                UserDefaults.standard.set(defaultListVersion, forKey: storedGameListVersionKey)
            }
        }
        catch {
            print(error)
            coreDataContext.rollback()
            self.errorMessage(errorThrown: error, messageToDisplay: "Error loading in the game list, the app will not work correctly!")
        }
    }
    
    // Check for updates to the game list
    private func checkForListUpdates() {
        var listVersion = UserDefaults.standard.double(forKey: storedGameListVersionKey)
        var listUpdated = false
        
        do {
            if let defaultFile = Bundle.main.url(forResource: defaultListName, withExtension: "json") {
                let data = try Data(contentsOf: defaultFile)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Read the array of games to check for updates
                if var array = json as? [Dictionary<String, Any>] {
                    // Check the version number
                    if array[0][listVersionKey] as! Double != listVersion {
                        listUpdated = true
                        listVersion = array[0][listVersionKey] as! Double
                    }
                    
                    // If we detect a new version of the list, start searching for changes
                    if listUpdated {
                        // Remove the version number from the array, which will only leave games to iterate through
                        array.remove(at: 0)
                        // Prepare some fetch requests, variables and predicates that we will be using in our loops
                        let gameFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: gameEntity)
                        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: categoryEntity)
                        let taskFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
                        // Set the CoreData merge conflict policy to prefer in-memory changes - this resolves some conflicts
                        coreDataContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                        
                        // Iterate through each game to check for changes
                        for game in array {
                            let gameID = game[uniqueIDKey] as! Int64
                            var gamePercentageChanged = false
                            
                            let coreDataGamePredicate = NSPredicate(format: "%K == %d", uniqueIDKey, gameID)
                            gameFetchRequest.predicate = coreDataGamePredicate
                            gameFetchRequest.fetchLimit = 1
                            
                            let storedGame = try? coreDataContext.fetch(gameFetchRequest) as! [Game]
                            
                            // If the game already exists in the user game list, we check for updates
                            if storedGame?.count != 0 {
                                let gameToCompare = storedGame!.first!
                                let updatedName = game[nameKey] as? String
                                let updatedIcon = game[iconKey] as? String
                                let updatedLargeIcon = game[largeIconKey] as? String
                                
                                if gameToCompare.name != updatedName {
                                    gameToCompare.name = updatedName
                                }
                                if gameToCompare.icon != updatedIcon {
                                    gameToCompare.icon = updatedIcon
                                }
                                if gameToCompare.largeIcon != updatedLargeIcon {
                                    gameToCompare.largeIcon = updatedLargeIcon
                                }
                                
                                let updatedCategories = game[categoriesKey] as! [Dictionary<String, Any>]
                                var arrayOfCategoryIDs: [Int64] = []
                                var arrayOfTaskIDs: [Int64] = []
                                var categoriesWithDeletedTasks: [TaskCategory] = []
                                
                                // Check game categories for updates
                                for categoryIndex in updatedCategories.indices {
                                    let category = updatedCategories[categoryIndex]
                                    let categoryID = category[uniqueIDKey] as! Int64
                                    // Check for duplicate categories - this should not happen in release versions
                                    if !arrayOfCategoryIDs.contains(categoryID) {
                                        arrayOfCategoryIDs.append(categoryID)
                                    }
                                    else {
                                        // If for any reason there are duplicate categories, we stop attempting to update the list
                                        coreDataContext.rollback()
                                        errorMessage(errorThrown: nil, messageToDisplay: "There are duplicate categories in the updated game list, list will remain out-of-date.")
                                        return
                                    }
                                    
                                    var categoryPercentageChanged = false
                                    
                                    let coreDataCategoryPredicate = NSPredicate(format: "%K == %d AND belongsToGame == %@", uniqueIDKey, categoryID, gameToCompare)
                                    categoryFetchRequest.predicate = coreDataCategoryPredicate
                                    categoryFetchRequest.fetchLimit = 1
                                    
                                    let fetchedCategory = try? coreDataContext.fetch(categoryFetchRequest) as! [TaskCategory]
                                    var storedCategory: TaskCategory? = nil
                                    
                                    // If there is an element in the fetched category array, we know it exists - check for updates
                                    if fetchedCategory?.count != 0 {
                                        storedCategory = fetchedCategory!.first!
                                        let updatedName = category[nameKey] as! String
                                        
                                        if storedCategory!.name != updatedName {
                                            storedCategory!.name = updatedName
                                        }
                                    }
                                    // If the category was not found, we insert it
                                    else {
                                        try insertNewCategory(categoryDictionary: category, indexInGame: categoryIndex, categoryGame: gameToCompare)
                                        let newCategoryFetched = try coreDataContext.fetch(categoryFetchRequest) as! [TaskCategory]
                                        storedCategory = newCategoryFetched.first
                                        gamePercentageChanged = true
                                    }
                                    
                                    let tasksArray = category[tasksKey] as! [Dictionary<String, Any>]
                                    
                                    // Check the tasks in this category
                                    for taskIndex in tasksArray.indices {
                                        let task = tasksArray[taskIndex]
                                        let taskID = task[uniqueIDKey] as! Int64
                                        // Check for duplicate tasks - should not happen in release versions
                                        if !arrayOfTaskIDs.contains(taskID) {
                                            arrayOfTaskIDs.append(taskID)
                                        }
                                        else {
                                            // If for any reason there are duplicate tasks, we stop attempting to update the list
                                            coreDataContext.rollback()
                                            errorMessage(errorThrown: nil, messageToDisplay: "There are duplicate tasks in the updated game list, list will remain out-of-date.")
                                            return
                                        }
                                        
                                        let coreDataTaskPredicate = NSPredicate(format: "%K == %d AND belongsToCategory == %@", uniqueIDKey, taskID, storedCategory!)
                                        taskFetchRequest.predicate = coreDataTaskPredicate
                                        taskFetchRequest.fetchLimit = 1
                                        
                                        let fetchedTask = try? coreDataContext.fetch(taskFetchRequest) as! [Task]
                                        
                                        if fetchedTask?.count != 0 {
                                            let taskToCompare = fetchedTask!.first!
                                            let updatedName = task[nameKey] as! String
                                            
                                            if taskToCompare.name != updatedName {
                                                taskToCompare.name = updatedName
                                            }
                                        }
                                        else {
                                            try insertNewTask(taskDictionary: task, taskCategory: storedCategory!, indexInCategory: taskIndex, taskGame: gameToCompare)
                                            categoryPercentageChanged = true
                                            gamePercentageChanged = true
                                        }
                                    }
                                    if categoryPercentageChanged {
                                        GameListTableViewController.updateCategoryPercentages(categoryToUpdate: storedCategory!)
                                    }
                                }
                                // Search for any deleted categories
                                let coreDataCategoryPredicate = NSPredicate(format: "NOT (%K IN %@) AND belongsToGame == %@", uniqueIDKey, arrayOfCategoryIDs, gameToCompare)
                                categoryFetchRequest.predicate = coreDataCategoryPredicate
                                categoryFetchRequest.fetchLimit = 0
                                
                                let deletedCategories = try? coreDataContext.fetch(categoryFetchRequest) as! [TaskCategory]
                                if deletedCategories?.count != 0 {
                                    // First delete any tasks in the deleted categories
                                    let tasksToDeletePredicate = NSPredicate(format: "belongsToCategory IN %@", deletedCategories!)
                                    taskFetchRequest.predicate = tasksToDeletePredicate
                                    taskFetchRequest.fetchLimit = 0
                                    let taskDeleteRequest = NSBatchDeleteRequest(fetchRequest: taskFetchRequest)
                                    try coreDataContext.execute(taskDeleteRequest)
                                    
                                    let categoryDeleteRequest = NSBatchDeleteRequest(fetchRequest: categoryFetchRequest)
                                    try coreDataContext.execute(categoryDeleteRequest)
                                    gamePercentageChanged = true
                                }
                                
                                // Search for any deleted tasks outside of deleted categories
                                let coreDataTaskPredicate = NSPredicate(format: "NOT (%K IN %@) AND belongsToGame == %@", uniqueIDKey, arrayOfTaskIDs, gameToCompare)
                                taskFetchRequest.predicate = coreDataTaskPredicate
                                taskFetchRequest.fetchLimit = 0
                                
                                let deletedTasks = try? coreDataContext.fetch(taskFetchRequest) as! [Task]
                                if deletedTasks?.count != 0 {
                                    for task in deletedTasks! {
                                        categoriesWithDeletedTasks.append(task.belongsToCategory!)
                                        if task.completed {
                                            task.belongsToCategory?.completedTasks -= 1
                                            gameToCompare.completedTasks -= 1
                                        }
                                    }
                                    let taskDeleteRequest = NSBatchDeleteRequest(fetchRequest: taskFetchRequest)
                                    try coreDataContext.execute(taskDeleteRequest)
                                    gamePercentageChanged = true
                                }
                        
                                // If any of our changes affect the game percentages, we update those
                                if gamePercentageChanged {
                                    GameListTableViewController.updateGamePercentages(gameToUpdate: gameToCompare)
                                }
                                // If we have deleted tasks from any remaining categories, we update the percentages in those categories
                                if categoriesWithDeletedTasks.count != 0 {
                                    for category in categoriesWithDeletedTasks {
                                        GameListTableViewController.updateCategoryPercentages(categoryToUpdate: category)
                                    }
                                }
                            }
                            
                            // If the game was not found in the user game list, we add it
                            else {
                                try addNewGame(gameDictionary: game)
                            }
                        }
                        // Save the CoreData context now that everything is updated
                        if coreDataContext.hasChanges {
                            try coreDataContext.save()
                        }
                        // Update the stored list version
                        UserDefaults.standard.set(listVersion, forKey: storedGameListVersionKey)
                    }
                }
            }
        }
        catch {
            print(error)
            coreDataContext.rollback()
            self.errorMessage(errorThrown: error, messageToDisplay: "Error checking for list updates, your game list may remain out-of-date.")
        }
    }
    
    // Updates the percentage completed for a given game
    static func updateGamePercentages(gameToUpdate: Game) {
        gameToUpdate.percentageCompleted = Double(gameToUpdate.completedTasks) / Double((gameToUpdate.taskBelongsToGame?.count)!) * Double(100)
    }
    
    // Updates the percentage completed for a given category
    static func updateCategoryPercentages(categoryToUpdate: TaskCategory) {
        categoryToUpdate.percentageCompleted = Double(categoryToUpdate.completedTasks) / Double((categoryToUpdate.taskBelongsToCategory?.count)!) * Double(100)
    }
    
    // Updates the percentage completed, and percentage value of each task, for a given game and category
    static func updateAllPercentages(categoryToUpdate: TaskCategory, gameToUpdate: Game) {
        updateCategoryPercentages(categoryToUpdate: categoryToUpdate)
        updateGamePercentages(gameToUpdate: gameToUpdate)
    }
    
    // Insert a new task to a given game and category
    // This function does not update category nor game percentages, nor save the context, for efficiency reasons
    private func insertNewTask(taskDictionary: Dictionary<String, Any>, taskCategory: TaskCategory, indexInCategory: Int, taskGame: Game) throws {
        // This first part checks if we are trying to add a task that already exists
        // If we are, then we move the task to the new category specified
        // We also update task numbers and percentages for the old category before moving
        if UserDefaults.standard.double(forKey: storedGameListVersionKey) != 0 {
            let coreDataFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
            let taskPredicate = NSPredicate(format: "%K == %d AND belongsToGame == %@", uniqueIDKey, taskDictionary[uniqueIDKey] as! Int64, taskGame)
            coreDataFetchRequest.predicate = taskPredicate
            coreDataFetchRequest.fetchLimit = 1
            do {
                let existingTask = try coreDataContext.fetch(coreDataFetchRequest) as! [Task]
                
                if existingTask.count != 0 {
                    let task = existingTask.first!
                    let oldCategory = task.belongsToCategory!
                    // If the task is already marked as completed, update the number of completed tasks for the old and new category
                    if task.completed {
                        oldCategory.completedTasks -= 1
                        taskCategory.completedTasks += 1
                    }
                    // If the index equals or exceeds the number of tasks in the category, we are appending to the category
                    // We must do this to avoid an NSRangeException
                    if (indexInCategory >= taskCategory.taskBelongsToCategory!.count) {
                        taskCategory.addToTaskBelongsToCategory(existingTask.first!)
                    }
                    else {
                        taskCategory.insertIntoTaskBelongsToCategory(existingTask.first!, at: indexInCategory)
                    }
                    
                    // Check for changes to the task name
                    if task.name != taskDictionary[nameKey] as? String {
                        task.name = taskDictionary[nameKey] as? String
                    }
                    
                    // Note we only update category percentages for the old category here, for efficiency reasons
                    GameListTableViewController.updateCategoryPercentages(categoryToUpdate: oldCategory)
                    return
                }
            }
            catch {
                throw error
            }
        }
        
        let newTask = Task(context: coreDataContext)
        newTask.uniqueID = taskDictionary[uniqueIDKey] as! Int64
        newTask.name = taskDictionary[nameKey] as? String
        newTask.completed = taskDictionary[completedKey] as! Bool
        
        // A negative indexInCategory is used to append to the end of the category - we check for this here
        // We also check if the index equals or exceeds the number of tasks in the category, as this has the same effect
        if (indexInCategory >= 0 && indexInCategory < taskCategory.taskBelongsToCategory!.count) {
            taskCategory.insertIntoTaskBelongsToCategory(newTask, at: indexInCategory)
        }
        else {
            newTask.belongsToCategory = taskCategory
        }
        taskGame.addToTaskBelongsToGame(newTask)
        
        // If the task is marked as completed, update the completed tasks count
        if newTask.completed {
            taskCategory.completedTasks += 1
            taskGame.completedTasks += 1
        }
    }
    
    // Insert a new category to given game
    // This function only updates category percentages, not game percentages, for efficiency reasons
    private func insertNewCategory(categoryDictionary: Dictionary<String, Any>, indexInGame: Int, categoryGame: Game) throws {
        let newCategory = TaskCategory(context: coreDataContext)
        newCategory.uniqueID = categoryDictionary[uniqueIDKey] as! Int64
        newCategory.name = categoryDictionary[nameKey] as? String
        
        if (indexInGame < 0) {
            categoryGame.addToCategoryBelongsToGame(newCategory)
        }
        else {
            categoryGame.insertIntoCategoryBelongsToGame(newCategory, at: indexInGame)
        }
        
        let tasksInCategory = categoryDictionary[tasksKey] as! [Dictionary<String, Any>]
        
        // Adds all tasks to the category
        for task in tasksInCategory {
            try insertNewTask(taskDictionary: task, taskCategory: newCategory, indexInCategory: -1, taskGame: categoryGame)
        }
        
        GameListTableViewController.updateCategoryPercentages(categoryToUpdate: newCategory)
    }
    
    // Add a new game to the database
    // All percentages are updated by this function
    private func addNewGame(gameDictionary: Dictionary<String, Any>) throws {
        let newGame = Game(context: coreDataContext)
        newGame.uniqueID = gameDictionary[uniqueIDKey] as! Int64
        newGame.name = gameDictionary[nameKey] as? String
        newGame.icon = gameDictionary[iconKey] as? String
        newGame.largeIcon = gameDictionary[largeIconKey] as? String
        listOfGames?.addToOrderedListOfGames(newGame)
        
        let categoriesInGame = gameDictionary[categoriesKey] as! [Dictionary<String, Any>]
        
        // Add all categories to the game
        for category in categoriesInGame {
            try insertNewCategory(categoryDictionary: category, indexInGame: -1, categoryGame: newGame)
        }
        
        GameListTableViewController.updateGamePercentages(gameToUpdate: newGame)
    }
    
    // Display an error message to the user when necessary
    private func errorMessage(errorThrown: Error?, messageToDisplay: String) {
        let bugReportMessage = "Please report this bug at bugs.igormagun.com"
        let alert = UIAlertController(title: "Error", message: messageToDisplay + " " + bugReportMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.parent?.present(alert, animated: true)
    }
    
    // Set up the game list for the view controller, then load the view
    override func viewDidLoad() {
        // Check for the presence of a game list version number stored in UserDefaults, indicating we have loaded the default game list in before
        if UserDefaults.standard.double(forKey: storedGameListVersionKey) != 0 {
            // First, fetch the existing game list
            let listFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameList")
            listFetchRequest.fetchLimit = 1
            do {
                let fetchResult = try coreDataContext.fetch(listFetchRequest) as! [GameList]
                listOfGames = fetchResult.first
            }
            catch {
                print(error)
                errorMessage(errorThrown: error, messageToDisplay: "Could not retrieve the game list when loading the view. Please report this bug to bugs.igormagun.com")
            }
            self.checkForListUpdates()
        }
        // If we have not loaded the default game list before, now we do
        else {
            self.loadDefaultGameData()
        }
        
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    // Overrides the viewWillAppear function so that the games are marked as completed if necessary
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source

    // Number of sections is always set to 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Returns the number of games found in the array as the number of rows needed
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (listOfGames?.orderedListOfGames?.count)!
        }
        else {
            return 0
        }
    }

    // Retrieves each game's name, icon and completion status to label the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameListCell", for: indexPath)
        
        // Configure the cell...
        let game = listOfGames?.orderedListOfGames?.array[indexPath.row] as! Game
        
        cell.textLabel?.text = game.name
        cell.imageView?.image = UIImage(named: game.icon!)
        
        if game.completedTasks == game.taskBelongsToGame!.count {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    // Prepares for a segue to a new view controller when a user selects a game
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Assigns the selected game to a global variable that we can then send to the destination view controller
        selectedGameIndex = indexPath.row
        performSegue(withIdentifier: "GameSelected", sender: self)
    }
    
    // Disables the delete button when editing
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // Override to support rearranging the table view, update the game list accordingly
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let gameToMove = listOfGames?.orderedListOfGames?.array[fromIndexPath.row] as! Game
        listOfGames?.removeFromOrderedListOfGames(gameToMove)
        listOfGames?.insertIntoOrderedListOfGames(gameToMove, at: to.row)
        do {
            if coreDataContext.hasChanges {
                try coreDataContext.save()
            }
        }
        catch {
            print(error)
            errorMessage(errorThrown: error, messageToDisplay: "Error saving data. Device may be out of storage, else this is a bug.")
        }
        tableView.reloadData()
    }

    // MARK: - Navigation

    // Sends the selected game the GameTasksTableViewController so that we can display all tasks for the game
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameScreen = segue.destination as? TaskCategoriesTableViewController {
            gameScreen.selectedGame = listOfGames?.orderedListOfGames?.array[selectedGameIndex!] as? Game
        }
    }

}
