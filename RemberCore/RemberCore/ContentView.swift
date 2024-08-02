//
//  ContentView.swift
//  RemberCore
//
//  Created by Alex Balla on 02.08.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext)
    var moc
    @FetchRequest(sortDescriptors: [])
    var codes: FetchedResults<Code>
    @State private var codeNameText = ""
    @State private var isErrorLabelVisible = false
    
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
                            let code = Code(context: moc)
                            code.id = UUID()
                            code.name = codeNameText
                            
                            try? moc.save()
                        } else {
                            isErrorLabelVisible = true
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
                    
                    if isErrorLabelVisible == true {
                        Text("errorLabel")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14, weight: .regular))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("New Group clicked")
                    }) {
                        Text("New Group")
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
