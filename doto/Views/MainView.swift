//
//  MainView.swift
//  Doto
//
//  Created by Oleksandr Zavazhenko on 30/11/2021.
//

import SwiftUI

struct MainView: View {

  @EnvironmentObject var taskViewModel: TaskViewModel
  @State private var addTask = false
  @State private var selectedCategory: Categories = .all
  @State private var showSearchBar = false
  @AppStorage("isDarkMode") private var isDarkMode = false

  var body: some View {

    NavigationView {

      VStack {

        if showSearchBar {
          CustomSearchBar(showSearchBar: $showSearchBar,
                          searchQuery: $taskViewModel.searchQuery)
            .padding()
        }

        ListView(searchQuery: $taskViewModel.searchQuery,
                 selectedCategory: selectedCategory)
          .environmentObject(taskViewModel)
      }

      .sheet(isPresented: $addTask) {
        AddTaskView()
          .environmentObject(taskViewModel)
      }

      .toolbar {

        ToolbarItem(placement: .navigationBarLeading) {
          navigationBarLeadingButton
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          navigationBarTrailingItem
        }

        ToolbarItem(placement: .principal) {
          Text("Twoje zadania")
            .fontWeight(.medium)
        }

        ToolbarItem(placement: .bottomBar) {
          Spacer()
        }

        ToolbarItem(placement: .status) {
          bottomBarLeadingItem
        }

        ToolbarItem(placement: .bottomBar) {
          bottomBarTrailingItem
        }
      }

    .alert(isPresented: $taskViewModel.showAlert) {
      Alert(
        title: Text("Nie masz zaplanowanych zadań"),
        message: Text("Dodaj pierwsze zadanie"),
        dismissButton: .default(Text("Dodaj"), action: {addTask.toggle()})
      )
    }
    .navigationBarTitleDisplayMode(.inline)
}
}

/// Button to open search bar
var navigationBarTrailingItem: some View {

  Button {
    withAnimation {
      showSearchBar.toggle()
    }
  } label: {
    Image(systemName: "magnifyingglass")
      .foregroundColor(.orange)
  }
}

/// Toggle which allows to change
var bottomBarTrailingItem: some View {
  Button(action: {addTask.toggle()}, label: {
    Image(systemName: "note.text.badge.plus")
  })
    .foregroundColor(.orange)
}

/// Menu with a filter by category
var bottomBarLeadingItem: some View {

  Menu(taskViewModel.selectedCategory.rawValue) {

    ForEach(Categories.allCases, id: \.self) { category in

      Button {
        taskViewModel.selectedCategory = category
      } label: {
        Text(category.rawValue)
      }
    }
  }
  .foregroundColor(.orange)
}

/// Menu with a setting button
var navigationBarLeadingButton: some View {

  Menu {
    Toggle(isOn: $isDarkMode) {
      HStack {
        Image(systemName: "moon.fill")
        Text("Tryb nocny")
      }
    }

  } label: {
    Image(systemName: "gearshape")
      .foregroundColor(.orange)
  }

}
}

/// A view that displays the list with tasks
struct ListView: View {

  @EnvironmentObject var taskViewModel: TaskViewModel
  @Binding var searchQuery: String
  @State var offsets: IndexSet?
  var selectedCategory: Categories

  var body: some View {

    List {
      ForEach(Array(taskViewModel.filteredTasks.enumerated()), id: \.element) { index, element in
        ListRow(task: element,
                taskIndex: IndexSet(integer: index))
          .environmentObject(taskViewModel)
          .contextMenu {
            Button {
              delete(at: IndexSet(integer: index))
            } label: {
              Label("Usuń zadanie", systemImage: "trash")
            }
          }
      }
      .onDelete(perform: delete) // works with a weird animation 
      .alert(isPresented: $taskViewModel.confirmationAction) {
        // if user allows to delete, then it removes from CoreData
        Alert(title: Text(taskViewModel.activeAlert?.rawValue ?? ""),
              primaryButton: .destructive(Text("Usuń")) {

          if let offsets = self.offsets {

              taskViewModel.deleteTask(indexSet: offsets)

          }

        }, secondaryButton: .cancel())}
    }
  }

  func delete(at offsets: IndexSet) {

    DispatchQueue.main.async {
      Thread.sleep(forTimeInterval: 0.01)
      taskViewModel.showAlert(reason: .askForDelete)
    }
    // showing an alert to ask user permission to delete

    self.offsets = offsets
  }

}

/// A view that displays list's row with a single task
struct ListRow: View {

  var task: Task
  var taskIndex: IndexSet
  @EnvironmentObject var taskViewModel: TaskViewModel

  var body: some View {

    HStack {

      Image(systemName: taskViewModel.accomplished ? "checkmark.circle" : "circle")
        .font(.title3)
        .onTapGesture {
          withAnimation {
            taskViewModel.accomplished = true
            taskViewModel.accomplishTask(indexSet: taskIndex)
          }
        }

      VStack(spacing: 0) {

        // Horizontal stack with a title
        HStack {

          Text(task.title ?? "Title")
            .font(.headline)
            .padding(.vertical)

          Spacer()
        }

        // Horizontal stack with a date of completion and task category
        HStack {

          HStack {
            Text(task.dateOfCompletion ?? Date(), style: .date)
            Text(task.dateOfCompletion ?? Date(), style: .time)
          }.foregroundColor(.gray)
            .font(.subheadline)

          Spacer()

          Text(task.category ?? "Category")
            .font(.footnote.weight(.medium))
            .padding(8)
            .foregroundColor(.white)
            .background(taskViewModel.categoryLabelColors(category:
                                                            Categories(rawValue:
                                                                        task.category ?? "")
                                                          ?? .other))
            .cornerRadius(8)
        }.padding(.bottom, 5)
      }.padding(.top, -10)
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
