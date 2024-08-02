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
    
    var body: some View {
        VStack {
            if codes.first != nil {
                Text("not nil")
            } else {
                TextField("Enter your unique code", text: $codeNameText)
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .padding(.horizontal, 15)
                Button(action: {
                    let code = Code(context: moc)
                    code.id = UUID()
                    code.name = codeNameText
                    
                    try? moc.save()
                }) {
                   Text("Add")
                        .foregroundColor(.white)
                }
                .frame(width: UIScreen.main.bounds.width - 30, height: 35)
                .background(Color.blue)
                .cornerRadius(5)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
