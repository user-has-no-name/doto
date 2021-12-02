//
//  CustomSearchBar.swift
//  doto
//
//  Created by Oleksandr Zavazhenko on 01/12/2021.
//

import SwiftUI

/// CustomSearchBar that can be modified by providing a custom prompt
struct CustomSearchBar: View {

  @Binding var showSearchBar: Bool

  @Binding var searchQuery: String
  var prompt: String = "Znajdź swoje zadanie"
  @State private var isSearching = false

    var body: some View {

      HStack {

        HStack {
          TextField(prompt, text: $searchQuery)
            .padding([.leading, .trailing], 24)
            .padding(.vertical, -5)
        }

          .padding()
          .background(Color.gray.opacity(0.3))
          .cornerRadius(10)
          .padding(.horizontal)
          .onTapGesture {
            isSearching = true
          }
          .overlay(
            HStack {
              Image(systemName: "magnifyingglass")
                .foregroundColor(.orange)
              Spacer()

              if isSearching && !searchQuery.isEmpty {
                Button {
                  searchQuery = ""
                } label: {
                  Image(systemName: "xmark.circle")
                    .padding(.vertical)
                }
              }

            }.padding(.horizontal, 32)
              .foregroundColor(.gray)
          ).transition(.move(edge: .trailing))
          .animation(.spring())

        if isSearching {
          Button {
            withAnimation {
              isSearching = false
              searchQuery = ""
              showSearchBar = false
            }

            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          } label: {
            Text("Anuluj")
              .foregroundColor(.orange)
          }
          .padding(.trailing)
          .padding(.leading, -8)

        }
      }

    }
}

struct CustomSearchBar_Previews: PreviewProvider {
    static var previews: some View {
      CustomSearchBar(showSearchBar: .constant(true), searchQuery: .constant(""))
    }
}
