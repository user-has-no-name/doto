//
//  TaskViewModel.swift
//  Doto
//
//  Created by Oleksandr Zavazhenko on 30/11/2021.
//

import Foundation
import CoreData
import SwiftUI
import Combine

protocol TaskProtocol {

  func addTask(title: String, category: Categories, dateOfCompletion: Date)
  func deleteTask(indexSet: IndexSet)
  func saveChanges()
  func categoryLabelColors(category: Categories) -> Color
  func validateTask(title: String) -> Bool
  func accomplishTask(indexSet: IndexSet)

}

/// All tasks categories that are available to users
enum Categories: String, Equatable, CaseIterable {

  case work = "Praca 📊"
  case homeWork = "Dom 🏡"
  case shoppingList = "Zakupy 🛒"
  case other = "Inne 🗿"
  case all = "Wszystkie 🗂"

}

enum Alerts: String, CustomStringConvertible {

  // titles for alerts and confirmation dialogs
  case emptyTitle = "Wystąpił błąd"
  case askForDelete = "Usunąć zaznaczone zadanie?"
  case addedSuccessfully = "Udało się"

  // bodies for alerts 
  var description: String {

    switch self {
    case .emptyTitle:
      return "Wprowadź nazwę zadania. Musi mieć min. 3 symbole"
    case .askForDelete:
      return "Czy na pewno chcesz usunąć zadanie"
    case .addedSuccessfully:
      return "Zadanie zostało dodane domyślnie"
    }
  }
}

class TaskViewModel: ObservableObject, TaskProtocol {

  // All tasks are stored in here after application runs
  @Published var allTasks: [Task] = []

  // Value for keeping track selected category
  @Published var selectedCategory: Categories = .all

  // If there are any errors this value changes and alerts is shown for a user
  @Published var showAlert: Bool = false

  @Published var confirmationAction: Bool = false

  @Published var activeAlert: Alerts?

  @Published var searchQuery = ""

  // Whenever user completes a task this value changes,
  // so the label can change as well
  @Published var accomplished = false

  // An array for filtered tasks
  @Published var filteredTasks: [Task] = []

  let persistentContainer: NSPersistentContainer

  var searchCancellable = Set<AnyCancellable>()

  init() {

    // Creating container to DataModel from CoreData
    persistentContainer = NSPersistentContainer(name: "DataModel")

    // Trying to load data from container
    persistentContainer.loadPersistentStores { _, error in

      if let error = error {
        // If there are any errors - just prints it out into the console (not the best idea)
        // Better would be to show an alert for user, with an explanaition what to do
        // But for now it's ok, since this is a rare error
        fatalError("Core Data Store failed \(error.localizedDescription)")
      }
    }

    $searchQuery.removeDuplicates()

      // Publishing elements with the delay 0.5, to avoid memory problems
      .debounce(for: 0.5, scheduler: RunLoop.main)

      // Receiving value from searchQuery
      .sink(receiveValue: { [weak self] str in
        if !str.isEmpty {

          // Filtering tasks by a provided search query
          self?.filteredTasks = (self?.allTasks.filter({ task in

            // If category is .all, then it searches among all of them
            if self?.selectedCategory == .all {

              // If title or category contains searchQuery, returns the value
              return task.title!.lowercased().contains(str.lowercased()) ||
              task.category!.lowercased().contains(str.lowercased())
            } else {

              // In case when category is not .all, searchingin a specific category
              return task.category == self?.selectedCategory.rawValue &&
              task.title!.lowercased().contains(str.lowercased()) ||
              task.category!.lowercased().contains(str.lowercased())
            }
          }))!
        }
      })
      .store(in: &searchCancellable)

    $selectedCategory.removeDuplicates()
      .combineLatest($searchQuery)
      .sink { [weak self] (category, _) in
        self?.getFilteredTasks(category: category)
      }
      .store(in: &searchCancellable)

    getAllTasks()
  }

  /// Adds task to the CoreData
  func addTask(title: String, category: Categories, dateOfCompletion: Date) {

    let task = Task(context: persistentContainer.viewContext)

    // title of task
    task.title = title

    // task's category
    task.category = category.rawValue

    // dateOfCompletion of task
    task.dateOfCompletion = dateOfCompletion

    // saves changes
    saveChanges()
  }

  func accomplishTask(indexSet: IndexSet) {

    deleteTask(indexSet: indexSet)

    accomplished = false

  }

  /// Deletes tasks from CoreData
  func deleteTask(indexSet: IndexSet) {

//    showAlert(reason: .askForDelete)
    // getting task from an array

    let task = allTasks[indexSet.first!]

    // deletes task from CoreData
    persistentContainer.viewContext.delete(task)

    // removes the task from array that contains all of them
    allTasks.remove(atOffsets: indexSet)

    // removes from array with filtered tasks
    filteredTasks.remove(atOffsets: indexSet)

    // checks if there is any task left in the list
    if allTasks.isEmpty {
      // if not - calls alert
      showAlert = true
    }

    // calling method that saves changes
    saveChanges()
  }

  /// Saves changes to the CoreData
  func saveChanges() {

    do {
      try persistentContainer.viewContext.save()
    } catch {
      persistentContainer.viewContext.rollback()
    }

  }

  /// Fetchs all tasks from CoreData
  func getAllTasks() {

    let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

    do {
      allTasks = try persistentContainer.viewContext.fetch(fetchRequest)

      if allTasks.isEmpty {
        showAlert = true
      }

    } catch {
      print(error)
    }

    getFilteredTasks(category: selectedCategory)

  }

  /// Filters tasks by tasks' categories
  func getFilteredTasks(category: Categories) {

    if category != .all {
      filteredTasks = allTasks.filter({ task in
        task.category == category.rawValue
      })
    } else {
      filteredTasks = allTasks
    }
  }

  /// Returns color depeneding on category
  func categoryLabelColors(category: Categories) -> Color {

    switch category {
    case .work:
      return Color.workLabel
    case .homeWork:
      return Color.howeWorkLabel
    case .shoppingList:
      return Color.shoppingListLabel
    default:
      return Color.otherLabel
    }
  }

  /// Validates task
  /// If title is an empty - calls alert
  func validateTask(title: String) -> Bool {

    if title.isEmpty || title.count < 3 {
      // shows alert if the title of the task was empty or less than 3 symbols
      showAlert(reason: .emptyTitle)
      return false
    } else {
      return true
    }

  }

  /// Triggers values that are for calling alerts
  func showAlert(reason: Alerts) {

    switch reason {

    case .emptyTitle:
      activeAlert = .emptyTitle
      showAlert = true
    case .askForDelete:
      activeAlert = .askForDelete
      confirmationAction = true
    case .addedSuccessfully:
      activeAlert = .addedSuccessfully
      showAlert = true
    }

  }
}
