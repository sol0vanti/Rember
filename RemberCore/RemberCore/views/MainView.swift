//
//  MainView.swift
//  RemberCore
//
//  Created by Alex Balla on 05.08.2024.
//

import SwiftUI

struct MainView: View {
    @Binding var folderCode: String
    @State var showCreateAlert = false
    var subFolders: [String] = ["Example folder 1", "Folder 2"]
    
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
            .alert(isPresented: $showCreateAlert) {
                Alert(title: Text("New gallery"), message: Text("In order to save your images you should create new subfolder"),
                      primaryButton: .default(Text("Create")) {
                    print("Create pressed")
                }, secondaryButton: .cancel())
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showCreateAlert = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    
                }
            }
        }
    }
}
