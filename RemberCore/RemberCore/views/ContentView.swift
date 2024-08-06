//
//  ContentView.swift
//  RemberCore
//
//  Created by Alex Balla on 02.08.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

struct ContentView: View {
    @State private var codeNameText = ""
    @State private var folderNames: [String] = []
    @State private var showAlert = false
        @State private var navigateToDetail = false
    @State private var errorText: String? = nil
    @State private var passwordText = ""
    @State private var selectedName: String = ""
    @State private var isSuccessful = false
    @State private var documentExists: Bool = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Enter your password", text: $passwordText)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 15)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button(action: {
                    let folderName = "folder_\(codeNameText)"
                    
                    if codeNameText != "" && passwordText != "" {
                        checkDocumentExists(name: folderName) { message in
                            if message != nil {
                                showAlert = true
                            } else {
                                let db = Firestore.firestore()
                                db.collection("codes").document(folderName).setData(["password": passwordText]) { error in
                                    if let error = error {
                                        errorText = "Failed to save to Firestore."
                                        print(error.localizedDescription)
                                    } else {
                                        isSuccessful = true
                                    }
                                }
                            }
                        }
                    } else {
                        errorText = "Please, fill all text fields and try again."
                    }
                }) {
                    Text("Create folder")
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
                        checkPassword()
                    },
                          secondaryButton: .cancel())
                }
                
                if errorText != nil {
                    Text(errorText ?? "An internal error was reported.")
                        .foregroundColor(Color.red)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.vertical, 10)
                }
                
                // MARK: Navigation
                // Navigate to main view
                NavigationLink(
                    destination: MainView(folderCode: $codeNameText),
                    isActive: $isSuccessful,
                    label: { EmptyView() }
                )
                Spacer()
            }
            .navigationTitle("Welcome to Rember")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func checkDocumentExists(name: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("codes").document(name).getDocument { (document, error) in
            if let document = document, document.exists {
                completion("The code is already existing")
            } else {
                completion(nil)
            }
        }
    }
    
    private func checkPassword() {
        let db = Firestore.firestore()
        let docRef = db.collection("codes").document("folder_\(codeNameText)")
            
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let storedPassword = document.get("password") as? String ?? ""
                if storedPassword == passwordText {
                    isSuccessful = true
                } else {
                    errorText = "Incorrect password"
                }
            } else {
                errorText = "Code does not exist"
            }
        }
    }
}

#Preview {
    ContentView()
}
