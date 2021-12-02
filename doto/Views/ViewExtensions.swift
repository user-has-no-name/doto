//
//  ViewExtensions.swift
//  doto
//
//  Created by Oleksandr Zavazhenko on 01/12/2021.
//

import SwiftUI

/// Colors for each category
extension Color {

  static let workLabel = Color(red: 77 / 255, green: 114 / 255, blue: 246 / 255) // Blue
  static let howeWorkLabel = Color(red: 178 / 255, green: 184 / 255, blue: 81 / 255) // Olive Green
  static let shoppingListLabel = Color(red: 240 / 255, green: 147 / 255, blue: 137 / 255) // Salmon
  static let otherLabel = Color(red: 128 / 255, green: 128 / 255, blue: 128 / 255) // Charcoal

}

/// Underlined text field with customizable foregroundColor
extension View {
  func underlineTextField(color: Color) -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(color)
            .padding(.top, 8)
    }
}
