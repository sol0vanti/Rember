//
//  RemberCoreApp.swift
//  RemberCore
//
//  Created by Alex Balla on 02.08.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct RemberCoreApp: App {
    var body: some Scene {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        WindowGroup {
            ContentView()
        }
    }
}
