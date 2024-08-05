//
//  MainView.swift
//  RemberCore
//
//  Created by Alex Balla on 05.08.2024.
//

import SwiftUI

struct MainView: View {
    @Binding var folderCode: String
    @State private var showCreateAlert = false
    @State private var alertTextFieldText = ""
    @State private var subFolders: [String] = ["Example folder 1", "Folder 2"]
    
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
}

/* MARK: For future use
 MARK: Cannot use mutating member on immutable value: 'self' is immutable
 Fix:
 If it is a property of struct - put @State before
 Else if it is function, put the word mutating before
 */
