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
    @State private var folderNames: [String] = []
    @State private var showAlert = false
    @State private var navigateToDetail = false
    @State private var errorText: String? = nil
    
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
                        Text("Create your first folder")
                            .font(.system(size: 18, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(UIColor.lightGray))
                            .padding(.horizontal, 15)
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
                                showAlert = true
                            } else {
                                let folderName = "folder_\(codeNameText)"
                                
                                let storage = Storage.storage()
                                let storageRef = storage.reference().child(folderName)
                                
                                let emptyData = Data()
                                let fileRef = storageRef.child("placeholder.txt")
                                
                                fileRef.putData(emptyData, metadata: nil) { metadata, error in
                                    if let error = error {
                                        print("Error creating folder: \(error.localizedDescription)")
                                    } else {
                                        let code = Code(context: moc)
                                        code.id = UUID()
                                        code.name = codeNameText
                                        
                                        do {
                                            try moc.save()
                                        } catch {
                                            errorText = "Failed to save code.name to Core Data."
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        } else {
                            errorText = "Please, fill the text field and try again."
                        }
                    }) {
                        Text("Submit")
                            .foregroundColor(.white)
                    }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                        .font(.system(size: 16, weight: .semibold))
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Failed to create new folder"), message: Text("It seems that this folder already exists."),
                                  primaryButton: .destructive(Text("Log In")) {
                                navigateToDetail = true
                            },
                            secondaryButton: .cancel())
                        }
                    
                    NavigationLink(
                        destination: DetailView(),
                        isActive: $navigateToDetail,
                        label: { EmptyView() }
                    )
                    
                    if errorText != nil {
                        Text(errorText ?? "An internal error was reported.")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14, weight: .regular))
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Welcome to Rember")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            self.fetchFolderNames()
        }
    }
    
struct DetailView: View {
    @State private var passwordText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Enter your password in order to complete registration")
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(UIColor.lightGray))
                        .padding(.horizontal, 15)
                    Spacer()
                }
                
                Spacer()
                
                TextField("Password", text: $passwordText)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 15)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    
                }) {
                    Text("Log In")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                .font(.system(size: 16, weight: .semibold))
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(5)
                
                Spacer()
            }
            .navigationTitle("One more step")
        }
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
