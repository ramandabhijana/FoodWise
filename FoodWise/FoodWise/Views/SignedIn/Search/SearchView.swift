//
//  SearchView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import SwiftUI

struct SearchView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Binding var searchText: String
  @Binding var showing: Bool
  var onSubmit: () -> Void
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(
      keyPath: \SearchedKeywordObject.createdDate,
      ascending: false
    )],
    animation: .default
  ) private var keywordsHistory: FetchedResults<SearchedKeywordObject>
  
  var body: some View {
    NavigationView {
      List {
        Text("Search History")
          .font(.headline)
          .bold()
          .listRowSeparator(.hidden)
        ForEach(keywordsHistory, id: \.id) {
          Text($0.value ?? "N/A")
        }
        .onDelete { indices in
          self.keywordsHistory.delete(at: indices,
                                      inViewContext: viewContext)
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("\(Image(systemName: "chevron.backward"))", action: dismiss)
        }
        
        ToolbarItem(placement: .principal) {
          TextField(
            "Search for foods or eateries",
            text: $searchText
          )
          .onSubmit(didPressEnter)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .introspectTextField { textField in
            textField.becomeFirstResponder()
          }
        }
      }
      .onAppear {
        NotificationCenter.default.post(
          name: .tabBarHiddenNotification,
          object: nil)
      }
      .introspectNavigationController { controller in
        let a2 = UINavigationBarAppearance()
        a2.configureWithOpaqueBackground()
        a2.backgroundColor = .white
        controller.navigationBar.standardAppearance = a2
        controller.navigationBar.scrollEdgeAppearance = a2
      }
    }
  }
  
  private func didPressEnter() {
    if !searchText.isEmpty {
      SearchedKeywordObject.save(.init(value: searchText),
                                 inViewContext: viewContext)
    }
    onSubmit()
  }
  
  private func dismiss() {
//    searchText = ""
    withAnimation(.easeIn) { showing.toggle() }
  }
}

//struct SearchView_Previews: PreviewProvider {
//  static var previews: some View {
//    SearchView()
//  }
//}
