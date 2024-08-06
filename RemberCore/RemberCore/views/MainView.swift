//
//  MainView.swift
//  RemberCore
//
//  Created by Alex Balla on 05.08.2024.
//

import SwiftUI
import FirebaseFirestore

struct MainView: View {
    @Binding var folderCode: String
    @State private var showCreateAlert = false
    @State private var alertTextFieldText = ""
    @State private var subFolders: [String] = []
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("All memories") {
                    ForEach(subFolders, id: \.self) { subFolder in
                        Text(subFolder)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(folderCode)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                getSubFolders()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showCreateAlert = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }.alert(
                        Text("New gallery"),
                        isPresented: $showCreateAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Create") {
                            if !alertTextFieldText.isEmpty {
                                subFolders.append(alertTextFieldText)
                                alertTextFieldText = ""
                                let folderName: String = "folder_\(folderCode)"
                                db.collection("codes").document(folderName).updateData(["subFolders":subFolders]) { error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        print("subFolders were successfully saved")
                                        getSubFolders()
                                    }
                                }
                            }
                        }

                        TextField("Title", text: $alertTextFieldText)
                            .textContentType(.creditCardNumber)
                    } message: {
                       Text("Please create new subfolder")
                    }
                }
            }
        }
    }
    
    private func getSubFolders() {
        let folderName: String = "folder_\(folderCode)"
        db.collection("codes").document(folderName).getDocument(){ (document, error) in
            if let document = document, document.exists {
                let storedSubFolders = document.get("subFolders") as? [String] ?? []
                subFolders = storedSubFolders
            }
        }
    }
}

/* MARK: For future use
 MARK: Cannot use mutating member on immutable value: 'self' is immutable
 Fix:
 If it is a property of struct - put @State before
 Else if it is function, put the word mutating before
 */
