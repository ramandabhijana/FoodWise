//
//  SearchedKeywordObject+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import Foundation
import CoreData

extension SearchedKeywordObject {
  
  static func save(_ keyword: SearchedKeyword,
                   inViewContext viewContext: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
      entityName: String(describing: SearchedKeywordObject.self)
    )
    fetchRequest.predicate = NSPredicate(format: "value = %@", keyword.value)
    
    // Only save if it doesnt exist
    guard let results = try? viewContext.fetch(fetchRequest),
          (results.first as? SearchedKeywordObject) == nil
    else {
      return
    }
    let newObject = self.init(context: viewContext)
    newObject.id = keyword.id
    newObject.value = keyword.value
    newObject.createdDate = keyword.createdDate
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
  
}

extension Collection where Element == SearchedKeywordObject, Index == Int {

  func delete(at indices: IndexSet,
              inViewContext viewContext: NSManagedObjectContext) {
    indices.forEach { index in
      viewContext.delete(self[index])
    }
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
  
}
