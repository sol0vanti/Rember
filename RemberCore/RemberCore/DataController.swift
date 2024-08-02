//
//  DataController.swift
//  RemberCore
//
//  Created by Alex Balla on 02.08.2024.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Rember")
    
    init(){
        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                print("CoreData error to load, \(error.localizedDescription)")
            }
        })
    }
}
