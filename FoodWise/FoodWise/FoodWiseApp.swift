//
//  FoodWiseApp.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI
import Firebase
import GoogleSignIn
import CoreData

@main
struct FoodWiseApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
//      SignInViewTest()
      
      MainView()
        .environment(\.managedObjectContext, CoreDataStack.viewContext)
      
//      SignUpView(viewModel: .init())
//      NearbyView()
//      SignInView()
//      WelcomeView()
//      NearbyMapView()
//      RootSignedInView()
//      HomeView()
//      MerchantHomeView()
//      FoodDetailsView(food: .sampleData.first!)
//      SelectLocationView(viewModel: .init(), onSave: { _, _ in })
//      SelectLocationViewTest()
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
    return true
  }
  
  func application(
    _ app: UIApplication,
    open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    CoreDataStack.save()
  }
}

private enum CoreDataStack {

  static var viewContext: NSManagedObjectContext = {
    let container = NSPersistentContainer(name: "SearchedKeyword")
    container.loadPersistentStores { _, error in
      guard error == nil else {
        fatalError("\(#file), \(#function), \(error!)")
      }
    }
    return container.viewContext
  }()

  static func save() {
    guard viewContext.hasChanges else { return }
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}
