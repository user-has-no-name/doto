//
//  dotoApp.swift
//  doto
//
//  Created by Oleksandr Zavazhenko on 30/11/2021.
//

import SwiftUI

@main
struct dotoApp: App {
  @StateObject var taskViewModel = TaskViewModel()
  @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {

            MainView()
              .environmentObject(taskViewModel)
              .preferredColorScheme(isDarkMode ? .dark : .light)
          
        }
    }
}
