//
//  ContentView.swift
//  RemberCore
//
//  Created by Alex Balla on 02.08.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var codes: FetchedResults<Code>
    @State private var codeNameText = ""
    @State private var isErrorLabelVisible = false
    @State private var folderNames: [String] = []
    
    init() {
            FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if codes.first == nil {
                    Text("nil")
                } else {
                    HStack {
                        Text("Create your first folder!")
                            .font(.system(size: 18, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(UIColor.lightGray))
                        Spacer()
                    }
                    
                    Spacer()
                    
                    TextField("Enter your unique code", text: $codeNameText)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal, 15)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        if codeNameText != "" {
                            let error: String? = self.checkFolderName()
                            if error != nil {
                                print(error!)
                                let ac = UIAlertController(title: "Failed to create new folder", message: "It seems that this folder is already exists.", preferredStyle: .actionSheet)
                                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                ac.addAction(UIAlertAction(title: "Log In", style: .destructive))
                                let viewController = UIApplication.shared.windows.first!.rootViewController!
                                viewController.present(ac, animated: true)
                            } else {
                                let folderName = "folder_\(codeNameText)"
                                let storage = Storage.storage()
                                let storageRef = storage.reference().child(folderName)
                                
                                // Create an empty file in the folder to ensure it gets created
                                let emptyData = Data()
                                let fileRef = storageRef.child("placeholder.txt")
                                fileRef.putData(emptyData, metadata: nil) { metadata, error in
                                    if let error = error {
                                        print("Error creating folder: \(error.localizedDescription)")
                                    } else {
                                        print("Folder \(folderName) created successfully")
                                        let code = Code(context: moc)
                                        code.id = UUID()
                                        code.name = codeNameText
                                        
                                        try? moc.save()
                                    }
                                }
                            }
                        } else {
                            isErrorLabelVisible = true
                        }
                    }) {
                        Text("New Group")
                            .foregroundColor(.white)
                    }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                        .font(.system(size: 16, weight: .semibold))
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    
                    if isErrorLabelVisible == true {
                        Text("errorLabel")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14, weight: .regular))
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Rember")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            self.fetchFolderNames()
        }
    }
    
    // MARK: Functionality of app
    
    func fetchFolderNames() {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            storageRef.listAll { (result, error) in
                if let error = error {
                    print("Error listing storage contents: \(error)")
                    return
                }
                self.folderNames = result!.prefixes.map { $0.name }
            }
        }

        func checkFolderName() -> String? {
            let textToCheck = "folder_\(codeNameText)"
            print(folderNames)
            if folderNames.contains(textToCheck) {
                return "Folder '\(textToCheck)' exists in Firebase Storage."
            } else {
                return nil
            }
        }
}

#Preview {
    ContentView()
}
