//
//  AddTaskView.swift
//  Doto
//
//  Created by Oleksandr Zavazhenko on 01/12/2021.
//

import SwiftUI

/// A view that allows to add a task
/// Values:
/// - title
/// - dateOfCompletion
/// - selectedCategory 
struct AddTaskView: View {

  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var taskViewModel: TaskViewModel
  @State private var title = ""
  @State private var dateOfCompletion = Date()
  @State private var selectedCategory = Categories.work

  // Returns a color based on the selected category
  var interfaceColor: Color {
    return taskViewModel.categoryLabelColors(category: selectedCategory)
  }

  var body: some View {

    NavigationView {

      Form {

        TextField("Nazwa zadania", text: $title)
          .underlineTextField(color: interfaceColor)

        VStack(alignment: .leading) {

          Text("Wybierz kategorię: ")
            .foregroundColor(interfaceColor)

          Picker(selection: $selectedCategory,
                 label: Text("Wybierz kategorię")) {
            ForEach(Categories.allCases, id: \.self) { category in
              if category != .all {
                Text(category.rawValue)
              }
            }
          }.pickerStyle(WheelPickerStyle())
        }

        DatePicker(selection: $dateOfCompletion, in: Date()...) {
          Text("Data ⏰")
        }.foregroundColor(.orange)
      }

        .toolbar {

          ToolbarItem(placement: .principal, content: {
            Text("Dodaj zadanie")
              .fontWeight(.medium)
          })

          ToolbarItem(placement: .navigationBarLeading) {
            Button("Anuluj") {
              presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.orange)
            .padding(6)

          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Dodaj") {

              if taskViewModel.validateTask(title: title) {

                // adding task in here
                taskViewModel.addTask(title: title,
                                      category: selectedCategory,
                                      dateOfCompletion: dateOfCompletion)

                // showing an alert to notify a user about successfully added task
                taskViewModel.showAlert(reason: .addedSuccessfully)

              }

            }
            .foregroundColor(title.count < 3 ? .gray : .orange)
          }
        }

        .alert(isPresented: $taskViewModel.showAlert) {

          if taskViewModel.activeAlert == .addedSuccessfully {
           return Alert(
              title: Text(taskViewModel.activeAlert?.rawValue ?? ""),
              message: Text(taskViewModel.activeAlert?.description ?? ""),
              primaryButton: .default(Text("OK"), action: {

                // getting all tasks, so the list will be updated
                taskViewModel.getAllTasks()
                presentationMode.wrappedValue.dismiss()
              }),
              secondaryButton: .cancel(Text("Dodaj kolejne zadanie")) {
                title.removeAll() // removing a title in case, when user wants to add the next task
              }
            )
          } else {
            return Alert(
               title: Text(taskViewModel.activeAlert?.rawValue ?? ""),
               message: Text(taskViewModel.activeAlert?.description ?? ""),
               dismissButton: .cancel(Text("OK"), action: {
               })
             )
          }
        }

        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
