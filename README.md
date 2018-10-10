100 Percenter
==========

This app is designed to track user progress towards 100% completion in various video games. It imports a JSON list of video games and their respective 100% tasks, stores it locally using CoreData, and then tracks progression as the user checks items off the list.

It is still a **work in progress**, but is nearing completion, and thus I have decided to upload it to Github.

Anyone who wishes to can contribute to the game list, though I would not recommend doing so until I have finalized support for subcategories first - the formatting for this is not yet decided.

## TO-DO
* Fill out the initial game list - the first few games will be GTA IV, GTA III and GTA San Andreas. I am planning to add more in future releases, but will release with these three
* Create an app icon
* Support for subcategories in each individual game's list of tasks

## Future Improvements
* Split the game list out into different JSON files for each game - a single JSON file will quickly become unwieldy
* Improve the user interface. One idea I have been given is to float completed tasks down to the bottom of the list, to more easily surface remaining tasks
* Add a more visual list based on covert art for each individual game
* Add 3D Touch support, to allow users to jump right into a game screen from the app icon, or peek into a category within the app
* An Android version of the app, which could import the same game list
* Apple Watch support, maybe

## Contributing to the Game List
The current formatting for the JSON files looks something like the following. It is currently stored in one file, but will be split off into separate JSON files either before launch or shortly after.

```json
{
    "name": "Game Name",
    "icon": "GameName",
    "largeIcon": "GameNameLarge",
    "uniqueID": 123456,
    "taskCategories": [
    {
        "name": "Category Name",
        "uniqueID": 0,
        "tasks": [
            {
                "name": "Task 1",
                "completed": false,
                "uniqueID": 0
            }
        ]
    }
    ]
}
```

A couple things to note here:
* Each task has an ID unique to the entire game - this allows for tasks to be moved between categories in future updates if needed. The app will throw an error if multiple tasks have the same ID, use this to verify your list before submitting
* Each game has an ID unique to the entire list of games. Reference the existing game list to decide on an ID, but IDs will be changed prior to master commits to avoid conflicts if necessary

Note also that the game should be accompanied by two icons: a small icon for the list, and a large icon that will be used in a future update. The large icon should generally be box art for the game, while the small icon should be something square and reasonably recognizable (i.e. the icon a game uses for desktop shortcuts).
