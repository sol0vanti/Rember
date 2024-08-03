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
    
    init() {
            FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if codes.first != nil {
                    Text("not nil")
                } else {
                    Spacer()
                    
                    TextField("Enter your unique code", text: $codeNameText)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal, 15)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        if codeNameText != "" {
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
                    
                    Button(action: {
                        print("New Group clicked")
                    }) {
                        Text("Log In")
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 15)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                    .font(.system(size: 16, weight: .semibold))
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(Color(UIColor.link))
                    .cornerRadius(5)
                }
            }
            .padding()
            .navigationTitle("Rember")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
